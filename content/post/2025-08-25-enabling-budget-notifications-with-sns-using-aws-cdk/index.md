---
title: Enabling AWS Budget Notifications with SNS using AWS CDK
date: 2025-08-25T16:31:00+02:00
image: https://images.unsplash.com/photo-1633158829875-e5316a358c6f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3MTc5ODl8MHwxfHNlYXJjaHwyfHxjb3N0JTIwc2F2aW5nfGVufDB8fHx8MTc1NTc3NTg3NXww&ixlib=rb-4.1.0&q=80&w=1080
draft: false
description: Learn how to set up AWS Budget notifications with SNS using AWS CDK in TypeScript, including gotchas around IAM and KMS policies.
tags:
  - aws
  - typescript
  - aws-cdk
  - finops
categories:
  - AWS
  - Cloud Engineering
---
Keeping track of AWS spend is very important. Especially since it's so easy to create resources. You might forget to turn off an EC2 instance or container you started, or remove a CDK stack for a specific experiment. Costs can creep up fast if you don’t put guardrails in place.

Recently, I had to set up budgets across multiple AWS accounts for my team. Along the way, I learned a few gotchas (especially around SNS and KMS policies) that weren't immediately clear to me as I started out writing AWS CDK code. In this post, we'll go through how to:

- Create AWS Budgets with AWS CDK
- Send notifications via email and SNS
- Handle cases like encrypted topics and configuring resource policies

If you’re setting up AWS Budgets for the first time, I hope this post will save you some trial and error.

## What are AWS Budgets?

[AWS Budgets](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html) is part of AWS Billing and Cost Management. It lets you set **guardrails** for spend and usage limits. You can define a budget around cost, usage, or even commitment plans (like Reserved Instances and Savings Plans) and trigger alerts when you cross a threshold. You can think of Budgets as your **planned** spend tracker. Budgets are great for:

- Alerting when costs hit predefined thresholds (e.g., 80% of your budgeted spend)
- Driving team accountability by tying alerts to product or account owners
- Enforcing a cap on monthly spend triggering an action and shutting down compute (EC2), if you go over budget (be careful with this)

Keep in mind that budgets and their notifications are not instant. AWS billing data is processed multiple times a day, but you might trigger your budget a couple of hours after you've passed your threshold. This is clearly stated in the AWS [documentation](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-best-practices.html) as:

> AWS billing data, which Budgets uses to monitor resources, is updated at least once per day. Keep in mind that budget information and associated alerts are updated and sent according to this data refresh cadence.

## Defining Budgets with AWS CDK

You can create different kinds of budgets, depending on your requirements. Some examples are:

- **Fixed budgets**: Set one amount to monitor every budget period.
- **Planned budgets**: Set different amounts to monitor each budget period.
- **Auto-adjusting budgets**: Set a budget amount to be adjusted automatically based on the spending pattern over a time range that you specify.

We'll start with a simple example of how you can create a budget in the CDK. We'll go for a **fixed** budget of about $100. The AWS CDK currently only has [Level 1 constructs](https://docs.aws.amazon.com/cdk/v2/guide/constructs.html) available for budgets, which means that the classes in the CDK are a 1 to 1 mapping to the CloudFormation resources. Because of this you will have to explicitly define all required properties (constructs, IAM policies, resource policies, etc), which otherwise could be taken care of by a CDK L2 construct. It also means your CDK code will be a bit more verbose. We'll start by using the **CfnBudget** construct.

```typescript
new cdk.aws_budgets.CfnBudget(this, 'fixed-monthly-cost-budget', {
    budget: {
        budgetType: 'COST',
        budgetLimit: {amount: 100, unit: 'USD'},
        budgetName: 'Monthly Costs Budget',
        timeUnit: 'MONTHLY'
    }
}
```

In the above example we've created a budget with a limit of **$100 per month**. A budget alone isn’t very useful. You’d still have to check into the AWS console manually to see what your spend is compared to your budget. The important thing is that we want to get notified in case we reach our budget or our forecasted budget will reach our threshold, so let's add a notification and a subscriber.

```typescript
new cdk.aws_budgets.CfnBudget(this, 'fixed-monthly-cost-budget', {
  budget: {
    budgetType: 'COST',
    budgetLimit: {amount: 100, unit: 'USD'},
    budgetName: 'Monthly Costs Budget',
    timeUnit: 'MONTHLY'
  },
  notificationsWithSubscribers: [{
    notification: {
      comparisonOperator: 'GREATER_THAN',
      notificationType: 'FORECASTED',
      threshold: 100,
      thresholdType: 'PERCENTAGE'
    },
    subscribers: [{
      subscriptionType: 'EMAIL',
      address: '<your-email-address>'
    }]
  }]
});
```

Based on the notification settings, interested parties are notified when the spend is **forecasted** to exceed 100% of our defined budget limit. You can put a notification on forecasted or actual percentages. When that happens an email is send to the designated email address. Subscribers, at the time of writing,  can be either email recipients or a Simple Notification Service (SNS) topic. In the above code example we use email subscribers for which you can add up to 10 recipients.

Depending on your team or organization it might be beneficial to switch to using an SNS topic. The advantage of using an SNS topic over a set of email subscribers is that you can add different kind of subscribers (email, chat, custom lambda functions) to your SNS topic. With an SNS topic you have a single place to configure subscribers and if you change your mind you can do so in one place instead of updating all budgets. Using an SNS Topic also allows you to push budget notifications to for instance a chat client like MS Teams or Slack.

![](/assets/2025/budget-sns.jpg)

In this case we wil make use of SNS in combination with email subscribers. Let's start by defining an SNS topic with the AWS CDK.

```typescript
// Create a topic for email notifications
let topic = new Topic(this, 'budget-notifications-topic', {
      topicName: 'budget-notifications-topic'
});
```

Now let's add an email subscriber, as this is the most simple way to receive budget notifications.

```typescript
// Add email subscription
topic.addSubscription( new EmailSubscription("your-email-address"));
```

This looks pretty straight forward and you might think you're done, but there is one important step to take next, which I initially forgot.
The AWS budgets service will need to be granted permissions to publish messages to the topic. To be able to do this, we will need to add a resource policy to the topic which allows the budgets service to call the _SNS:Publish_ action for our topic.

```typescript
// Add resource policy to allow the budgets service to publish to the SNS topic
topic.addToResourcePolicy(new PolicyStatement({
  actions:["SNS:Publish"],
  effect: Effect.ALLOW,
  principals: [new ServicePrincipal("budgets.amazonaws.com")],
  resources: [topic.topicArn],
  conditions: {
    ArnEquals: {
     'aws:SourceArn': `arn:aws:budgets::${Stack.of(this).account}:*`,
   },
    StringEquals: {
      'aws:SourceAccount': Stack.of(this).account,
    },
  },
}))
```

Now let's assign the SNS topic as a subscriber in our CDK code.

```typescript
// Define a fixed budget with SNS as subscriber
new cdk.aws_budgets.CfnBudget(this, 'fixed-monthly-cost-budget', {
    budget: {
        budgetType: 'COST',
        budgetLimit: {amount: 100, unit: 'USD'},
        budgetName: 'Monthly Costs Budget',
        timeUnit: 'MONTHLY'
    },
    notificationsWithSubscribers: [{
        notification: {
            comparisonOperator: 'GREATER_THAN',
            notificationType: 'FORECASTED',
            threshold: 100,
            thresholdType: 'PERCENTAGE'
        },
        subscribers: [{
            subscriptionType: 'SNS',
            address: topic.topicArn
        }]
    }]
});
```

## Working with Encrypted Topics

If you have an SNS topic with **encryption enabled** (via KMS) you will need to make sure that the corresponding service has access to the KMS key. If you don't, you will not get any messages and as far as I could tell you will see no errors (at least I could find none in CloudTrail). I actually wasted a couple of hours trying to figure this part out.

![](https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNDBnMnA1ZXdhazdhZ2pzcmwyMXRwNXQzNGEyN3dqMzdjMWV6M2J0aCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/ySMINwPzf50IM/giphy.gif)

I should have [read the documentation](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-sns-policy.html#configure-kms-perm) as it is explicitly stated to do so. I guess I should start with the docs instead of diving right into the AWS CDK code.

```typescript
// Create KMS key used for encryption
let key = new Key(this,'sns-kms-key', {
   alias: 'sns-kms-key',
   enabled: true,
   description: 'Key used for SNS topic encryption'
});

// Create topic and assign the KMS key
let topic = new Topic(this, 'budget-notifications-topic', {
    topicName: 'budget-notifications-topic',
    masterKey: key
});
```

Now let's add the resource policy to the key and try to trim down the permissions as much as possible.

```typescript
// Allow access from budgets service
key.addToResourcePolicy(new PolicyStatement({
    effect: Effect.ALLOW,
    actions: ["kms:GenerateDataKey*","kms:Decrypt"],
    principals: [new ServicePrincipal("budgets.amazonaws.com")],
    resources: ["*"],
    conditions: {
        StringEquals: {
            'aws:SourceAccount': Stack.of(this).account,
        },
        ArnLike: {
            "aws:SourceArn": "arn:aws:budgets::" + Stack.of(this).account +":*"
        }
    }
}));
```

## Putting it all together

If you've configured everything correctly and deployed your stack to your target account you should be good to go. Once you cross your threshold you should be notified by email that your budget is exceeding one of your thresholds (depending on the threshold set).

![](/assets/budget-alert.png)

## Summary

In this post, we explored how to create AWS Budgets with AWS CDK and send notifications through email or SNS.  Along the way, we covered some important topics like:

- Budgets alone aren’t useful until you add notifications.
- SNS topics need a resource policy so the Budgets service can publish.
- Encrypted topics require KMS permissions for the Budgets service.

With these pieces in place, you'll have a setup that alerts your team when costs exceed thresholds via email, chat, or custom integrations.

A fully working CDK application with the code mentioned in this blogpost can be found in the [following GitHub repo](https://github.com/jreijn/demos-aws-cdk/tree/develop/aws-cdk-budget-notifications).

> Photo by <a href="https://unsplash.com/@towfiqu999999?utm_source=sveltia-cms&amp;utm_medium=referral">Towfiqu barbhuiya</a> on <a href="https://unsplash.com/?utm_source=sveltia-cms&amp;utm_medium=referral">Unsplash</a>
