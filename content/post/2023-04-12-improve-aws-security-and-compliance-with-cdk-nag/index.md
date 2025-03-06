---
canonical_url: https://www.luminis.eu/blog/cloud-en/improve-aws-security-and-compliance-with-cdk-nag/
comments: false
date: "2023-04-12T00:00:00Z"
image: /assets/2023/niv-singer-LkD_IH8_K8k-unsplash.jpg
categories:
- Cloud Engineering
- AWS
tags:
- aws
- aws-cdk
- security
title: Improve AWS security and compliance with cdk-nag
---

[AWS Cloud Development Kit (AWS CDK)](https://aws.amazon.com/cdk/) is a powerful tool that allows developers to define cloud infrastructure in code using familiar programming languages like TypeScript, Python, and Java. However, as with any infrastructure-as-code tool, it's important to ensure that the resulting infrastructure adheres to security and compliance best practices. This is where cdk-nag comes in.

## What is cdk-nag ?

[cdk-nag](https://github.com/cdklabs/cdk-nag) is an open-source tool that provides automated checks for AWS CDK code and the resulting Cloudformation templates to help ensure that they adhere to security and compliance best practices.

After adding cdk-nag to your project it checks for a variety of known security and compliance issues including overly-permissive IAM policies, missing access logs and unintended public s3 buckets. cdk-nag also checks for common mistakes that can lead to security vulnerabilities, such as the use of plain text passwords and the use of default security groups.

The great thing about cdk-nag is that it allows you to catch mistakes at a very early stage in the process. Ideally, you can catch them while developing your infrastructure as code in CDK on your local machine. As an alternative, you can add cdk-nag to your CI/CD pipeline and make the build fail in case of any issues.

## Adding cdk-nag to your project

Using cdk-nag is simple. First, add it as a dependency to your AWS CDK project. If you're using Java you can add it to your pom.xml file.

```xml
<dependency>
  <groupId>io.github.cdklabs</groupId>
  <artifactId>cdknag</artifactId>
  <version>2.25.2</version>
</dependency>
```

After you've added the dependency you will need to explicitly enable cdk-nag utilizing a [CDK aspect](https://docs.aws.amazon.com/cdk/v2/guide/aspects.html). You can apply cdk-nag in the scope of your entire CDK application or just in the scope of a single CDK stack.

cdk-nag works with rules which are defined in packs. Those packs are based on AWS Config conformance pack. If you've never looked at AWS Config, the [Operational Best Practices for HIPAA Security](https://docs.aws.amazon.com/config/latest/developerguide/operational-best-practices-for-hipaa_security.html) page is a nice page to look at in the context of these cdk-nag conformance packs. By default, cdk-nag comes with several rule packs out of the box.

1. [AWS Solutions](https://github.com/cdklabs/cdk-nag/blob/main/RULES.md#awssolutions)
    
2. [HIPAA Security](https://github.com/cdklabs/cdk-nag/blob/main/RULES.md#hipaa-security)
    
3. [NIST 800-53 rev 4](https://github.com/cdklabs/cdk-nag/blob/main/RULES.md#nist-800-53-rev-4)
    
4. [NIST 800-53 rev 5](https://github.com/cdklabs/cdk-nag/blob/main/RULES.md#nist-800-53-rev-5)
    
5. [PCI DSS 3.2.1](https://github.com/cdklabs/cdk-nag/blob/main/RULES.md#pci-dss-321)
    

Based on your requirements you can enable one or more rule packs. Let's take a look at how to apply such a rule pack.

```java
public class AwsCdkNagDemoApp {
    public static void main(final String[] args) {
        App app = new App();

        new AwsCdkNagDemoStack(app, "AwsCdkNagDemoStack", 
            StackProps
                .builder()
                .env(Environment.builder()
                .account(System.getenv("CDK_DEFAULT_ACCOUNT"))
                .region(System.getenv("CDK_DEFAULT_REGION"))
                .build())
            .build()
        );

         Aspects.of(app)
           .add(
                AwsSolutionsChecks.Builder
                .create()
                .verbose(true)
                .build()
           );
        app.synth();
    }
}
```

As you can see in the above code fragment we've enabled the **AwsSolutionsChecks** rules for the scope of the entire CDK app. In this example, we've explicitly enabled *verbose* mode as it will generate more descriptive messages.

Now let's take a look at an example stack and see how cdk-nag responds to that. The stack below is a very simple stack which contains an AWS Lambda function processing messages from an SQS queue.

```java
public AwsCdkNagDemoStack(final Construct scope, 
  final String id, final StackProps props) {
      
  super(scope, id, props);

  final Queue queue = Queue.Builder.create(this, "demo-queue")
                 .visibilityTimeout(Duration.seconds(300))
                 .build();

  final Function function = Function.Builder
    .create(this, "demo-function")
    .handler("com.jeroenreijn.demo.aws.cdknag.FunctionHandler")
    .code(Code.fromAsset("function.jar"))
    .runtime(Runtime.JAVA_11)
    .events(List.of(
      SqsEventSource.Builder.create(queue).build())
    )
    .build();

  queue.grantConsumeMessages(function);
}
```

## Analyzing results

Now when you run `cdk synth` from the command-line, it will trigger cdk-nag and it will automatically scan your resources in the resulting templates and check them for security and compliance issues. Once the scan is done, cdk-nag will either return successfully or return an error message and output a list of violations in a format that is easy to understand. After running `cdk synth` we will get the following messages in our output.

```plaintext
[Error at /AwsCdkNagDemoStack/demo-queue/Resource] AwsSolutions-SQS3: 
The SQS queue is not used as a dead-letter queue (DLQ) and does not have a DLQ enabled. 
Using a DLQ helps maintain the queue flow and avoid losing data by detecting and mitigating failures and service disruptions on time.

[Error at /AwsCdkNagDemoStack/demo-queue/Resource] AwsSolutions-SQS4: 
The SQS queue does not require requests to use SSL. Without HTTPS (TLS), a network-based attacker can eavesdrop on network traffic or manipulate it, using an attack such as man-in-the-middle. 
Allow only encrypted connections over HTTPS (TLS) using the aws:SecureTransport condition in the queue policy to force requests to use SSL.

[Error at /AwsCdkNagDemoStack/demo-function/ServiceRole/Resource] AwsSolutions-IAM4[Policy::arn:<AWS::Partition>:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole]: 
The IAM user, role, or group uses AWS managed policies. 
An AWS managed policy is a standalone policy that is created and administered by AWS. Currently, many AWS managed policies do not restrict resource scope. Replace AWS managed policies with system specific (customer) managed policies.This is a granular rule that returns individual findings that can be suppressed with 'appliesTo'. 
The findings are in the format 'Policy::<policy>' for AWS managed policies. Example: appliesTo: ['Policy::arn:<AWS::Partition>:iam::aws:policy/foo'].


Found errors
```

As you can see cdk-nag spotted some errors and explains what we can do to improve our infrastructure. Usually, it's quite easy to fix these errors. [Level 2 CDK constructs](https://aws.amazon.com/blogs/devops/leverage-l2-constructs-to-reduce-the-complexity-of-your-aws-cdk-application/) already incorporate some of the best practices, so when using them you will probably find fewer errors compared to using Level 1 constructs.

The messages depend on the rule pack you select. For instance, when we switch to the **HIPAASecurityChecks** rule pack we will get some duplicates but also some additional error messages.

```plaintext
[Error at /AwsCdkNagDemoStack/demo-function/Resource] HIPAA.Security-LambdaConcurrency: 
The Lambda function is not configured with function-level concurrent execution limits - (Control ID: 164.312(b)). Ensure that a Lambda function's concurrency high and low limits are established. This can assist in baselining the number of requests that your function is serving at any given time.

[Error at /AwsCdkNagDemoStack/demo-function/Resource] HIPAA.Security-LambdaDLQ: 
The Lambda function is not configured with a dead-letter configuration - (Control ID: 164.312(b)). Notify the appropriate personnel through Amazon Simple Queue Service (Amazon SQS) or Amazon Simple Notification Service (Amazon SNS) when a function has failed.

[Error at /AwsCdkNagDemoStack/demo-function/Resource] HIPAA.Security-LambdaInsideVPC: 
The Lambda function is not VPC enabled - (Control IDs: 164.308(a)(3)(i), 164.308(a)(4)(ii)(A), 164.308(a)(4)(ii)(C), 164.312(a)(1), 164.312(e)(1)). Because of their logical isolation, domains that reside within an Amazon VPC have an extra layer of security when compared to domains that use public endpoints.

...
```

The **HIPAASecurityChecks** also finds issues related to Lambda function concurrency and running your Lambda function inside a VPC. As you can see different packs look at different things, so it's worthwhile to explore the different packs and see how they can help you improve. It's worth mentioning that cdk-nag does not implement all rules defined in these AWS Config conformance packs. You can check which rules are excluded in the [cdk-nag excluded rules documentation](https://github.com/cdklabs/cdk-nag/blob/main/RULES.md#excluded-rules).

## Summary

Overall, cdk-nag is a powerful tool for ensuring that your AWS CDK code and templates adhere to security and compliance best practices. By catching security issues early in the development process, cdk-nag can help you build more secure and reliable infrastructure. I've used it in many projects over the last couple of years and it's adding value. Especially if you work in a team that does not have a lot of AWS experience it shines. If you're using AWS CDK, I highly recommend giving cdk-nag a try. The [example code](https://github.com/jreijn/demos-aws-cdk/tree/develop/aws-cdk-cdk-nag) in this post and a working project can be found on [GitHub](https://github.com/jreijn/demos-aws-cdk/tree/develop/aws-cdk-cdk-nag).