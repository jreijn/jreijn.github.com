---
comments: false
date: "2022-07-17T00:00:00Z"
image: /assets/2022/mehmet-ali-peker-hfiym43qBpk-unsplash-grey.jpg
subtitle: An introduction to AWS CDK Custom Resources
categories:
- Cloud Engineering
- AWS
tags:
- aws
- aws-cdk
- aws-lambda
- java
- iac
title: Invoking an AWS Lambda function during CDK deployment
---


In general, AWS Lambda functions are triggered by some sort event. Most common use cases are an event from [EventBridge](https://aws.amazon.com/eventbridge/), [SQS](http://amazon.com/sqs/), or an event created by a call to [API Gateway](https://aws.amazon.com/api-gateway/) in case you have a REST/HTTP API based on an AWS Lambda function.
However, the other day I was looking for an option to **execute my Lambda function immediately after it was created and/or updated** while deploying my Infrastructure as Code with [AWS CDK](https://aws.amazon.com/cdk/). I wanted it to work without manually executing a CLI command or calling an HTTP endpoint. It needed to be based on the CDK / CloudFormation deployment. A couple of use cases we had was triggering an import process or running a liquibase/ flyway script to populate a database.

## Looking for options

While researching options, I initially looked for a method on the [Function](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_lambda.Function.html) CDK Construct. I wondered if had specific lifecycle methods, but that did not seem the case. Secondly I started looking at an EventBridge rule that could listen to AWS CloudFormation events, but it seems there are almost no events are coming out of CloudFormation into EventBridge.

AWS CDK is based on CloudFormation, so I searched within the documentation for both technologies to see what kind of hooks or lifecycle events were available. 
First thing I found was CloudFormation [Hooks](https://docs.aws.amazon.com/cloudformation-cli/latest/userguide/hooks.html), however that only seemed related to proactive validation and automatic enforcement at the pre-deployment phase. While searching I did find a suggestion to look into using a Custom Resource and that seemed like a good solution.

## Using Custom Resources in CDK 

What are Custom Resource in CDK?

> AWS CloudFormation [custom resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html) are *extension points* to the **provisioning engine**. When CloudFormation needs to create, update or delete a custom resource, it sends a lifecycle event notification to a custom resource provider.

With custom resources you can hook into the provisioning engine and create a handler for the create, update and delete events. This will allow you to: 

- Create AWS resources that are not (yet) supported by CDK/CloudFormation
- Create Non AWS resources (remote managed databases like ElasticCloud or MongoDB Atlas)
- Perform all kinds of other operations as you can write your own custom logic ( database seeding, database migrations, API calls, SDK calls)

 
AWS CDK supports Custom Resources and gives you two options to implement them:

1. **Leverage the Custom Resource [Provider](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.custom_resources-readme.html) Framework** - Create your own lambda functions to handle the cloud formation events
2. **Leverage the Custom Resources for AWS APIs** - Use the [AWSCustomResource](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.custom_resources.AwsCustomResource.html) construct and provide a single AWS SDK API call

### Using a custom resource provider

So what is a custom resource provider in CDK / CloudFormation? 

> When CloudFormation needs to create, update or delete a custom resource, it sends a lifecycle event notification to a custom resource provider. The provider handles the event (e.g. creates a resource) and sends back a response to CloudFormation. Providers are implemented through AWS Lambda functions that are triggered by the provider framework in response to lifecycle events. 

The [CDK documentation on Custom Resources](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.custom_resources-readme.html) has some extensive documentation on implementing such a Lambda function as a custom provider. At the minimum, you will need to define the onEvent handler, which is invoked by the provider framework for all resource lifecycle events (*create, update *and *delete*) and you need to return a result which is then submitted to CloudFormation. 

The framework offers a high-level API which makes it easier to implement robust and powerful custom resources and includes the following capabilities:

- Handles responses to AWS CloudFormation and protects against blocked deployments
- Validates handler return values to help with correct handler implementation
- Supports asynchronous handlers to enable operations that require a long waiting period for a resource, which can exceed the AWS Lambda timeout
- Implements default behavior for physical resource IDs.

The following code shows how the Provider construct is used in conjunction with a CustomResource and a user-provided AWS Lambda function which implements the actual handler.

```java
Function onEvent;
Function isComplete;
Role myRole;
 
Provider myProvider = Provider.Builder.create(this, "MyProvider")
        .onEventHandler(onEvent)
         .isCompleteHandler(isComplete) // optional async "waiter"
         .logRetention(RetentionDays.ONE_DAY) // default is INFINITE
         .role(myRole)
         .build();
 
CustomResource.Builder.create(this, "Resource1").serviceToken(myProvider.getServiceToken()).build(); 
```

When writing such an eventHandler you can use the [AWS Lambda PowerTools for Java Custom Resources utility library](https://awslabs.github.io/aws-lambda-powertools-java/utilities/custom_resources/).

A skeleton of such a function when used with Lambda PowerTools will look like:

```java
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.events.CloudFormationCustomResourceEvent;
import software.amazon.lambda.powertools.cloudformation.AbstractCustomResourceHandler;
import software.amazon.lambda.powertools.cloudformation.Response;

public class ProvisionEventHandler extends AbstractCustomResourceHandler {

    @Override
    protected Response create(CloudFormationCustomResourceEvent createEvent, Context context) {
        doProvisioning();
        return Response.success();
    }

    @Override
    protected Response update(CloudFormationCustomResourceEvent updateEvent, Context context) {
        return null;
    }

    @Override
    protected Response delete(CloudFormationCustomResourceEvent deleteEvent, Context context) {
        return null;
    }
}
```

As you can see from the code snippet, Lambda power tools adds a level of abstraction for you so you don’t have to handle events and offers direct methods for create, update and delete of a resource. The solution itself looks very powerful and flexible for a lot of different use cases. You can add multiple operations inside such a block which makes it a powerful solution for complex operations.  Creating the code for such a Lambda function looks straight forward, but still it's quite a bit of work and more code to maintain, so after reading about the *AWSCustomResource* construct, I had the gut feeling it was all I needed and it looks much simpler to achieve my goal.

### Using the AWSCustomResource construct

So what does the AWSCustomResource construct do? 

> Defines a custom resource that is materialized using specific AWS API calls.
These calls are created using a singleton Lambda function.

> You can specify exactly which calls are invoked for the 'CREATE', 'UPDATE' and 'DELETE' life cycle events.

That sounds pretty cool! Besides the AWS CDK code it sounds like we don't have to write any code to be able to leverage this. So we don't have to write the Lambda function or manage the IAM policies. All we need to do is provide de Sdk call. The rest seems to be handled by the construct. Sweet!

Let's first define the Lambda Function that will run our own business logic and needs to be triggered during the deployment.

```java
Function function = new Function(this, "java-based-function", FunctionProps.builder()
                .runtime(Runtime.JAVA_11)
                .code(Code.fromAsset("../app/target/app.jar"))
                .handler("com.jeroenreijn.aws.samples.lambdatrigger.FunctionHandler")
                .memorySize(512)
                .timeout(Duration.seconds(10))
                .logRetention(RetentionDays.ONE_WEEK)
                .build());
```

Now that our business logic function is defined, we will need to define which AWS SDK call we want to make. In our case we want to invoke a Lambda function from inside our custom resource. Let's create the SDK call to the AWS Lambda service and provide our parameters. 

```java
AwsSdkCall lambdaExecutionCall = AwsSdkCall.builder()
                .service("Lambda")
                .action("invoke")
                .physicalResourceId(PhysicalResourceId.of(LocalDateTime.now().toString()))
                .parameters(Map.of(
                        "FunctionName", function.getFunctionName(),
                        "InvocationType", "Event",
                        "Payload", "{" + "\"body\":\"{\\\"message\\\": \\\"Hello World\\\"}\"" + "}"
                ))
                .build();
```

If we look at the above snippet, we can see an example of how to invoke a specific lambda function by name. The Payload parameter is optional, so if your function is not expecting a payload you can leave that out. 

With the AWS SDK call in place we wil need to create our AwsCustomResource construct. Since we want our function logic to happen when we create our update our CDK stack we will need to add our AWS SDK call to the *onCreate* and *onUpdate* handlers.

Last but not least, to follow the least privilege principle we make sure that our Custom resource can only call our specific function by adding it to the Policy.

```java
AwsCustomResource lambdaTriggerResource = AwsCustomResource.Builder.create(this, "custom-resource")
                .logRetention(RetentionDays.FIVE_DAYS)
                .onCreate(lambdaExecutionCall)
                .onUpdate(lambdaExecutionCall)
                .policy(
                        AwsCustomResourcePolicy.fromStatements(List.of(
                                PolicyStatement.Builder
                                        .create()
                                        .actions(List.of("lambda:InvokeFunction"))
                                        .effect(Effect.ALLOW)
                                        .resources(List.of(function.getFunctionArn()))
                                        .build())))
                .installLatestAwsSdk(false)
                .build();
```

To make sure our business function is deployed before making the call we can add an explicit dependency. By doing so, CDK / CloudFormation will know there is a specific order in which it needs to create our resources.
 
```java
lambdaTriggerResource.getNode().addDependency(function);
```

When you deploy the above solution AWS CDK / CloudFormation will actually create a second Lambda function for us containing the SDK call to the function that holds our actual business logic. That was exactly what I was trying to do and CDK seems to make it really simple to implement this.

![Image showing the process from CDK deploy to the actual invocation](/assets/2022/custom-resource-cdk.jpg)

## Summary

As you can see Custom Resources in AWS CDK are quite powerful. It gives you a lot of flexibility and when you need more than a single API call you can leverage the Provider framework. For single API calls using the `AwsCustomResource` is quite straightforward and it allowed me to invoke my lambda function on deployment.
