---
title: Amazon ECS Express Mode from an IaC perspective
date: 2025-12-20T22:10:00+01:00
image: https://images.unsplash.com/photo-1590497008432-598f04441de8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3MTc5ODl8MHwxfHNlYXJjaHw4fHxjb250YWluZXJzfGVufDB8fHx8MTc2NTIxMDU0N3ww&ixlib=rb-4.1.0&q=80&w=1080
draft: false
description: Amazon recently launched a new feature for Amazon ECS called ECS Express Mode. While reading the announcement, I got curious as I use ECS on a regular basis. In this post, we'll look at what ECS Express Mode is, how you can use it from Infrastructure as Code by means of AWS CDK, and what the limitations are.
tags:
  - aws
  - ecs
  - cdk
  - iac
categories:
  - AWS
  - Cloud Engineering
featured_image: ''
---
Most posts I’ve seen look at ECS Express Mode from an AWS Console (ClickOps) or AWS CLI perspective. The AWS Console is an easy way to get going, but in my experience, most engineers in larger organizations use Infrastructure as Code (IaC) tools like AWS CDK or Terraform for creating resources in AWS. Before we dive into the IaC part, let’s first take a closer look at ECS Express Mode.

## What is ECS Express Mode?

[Amazon Elastic Container Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) (Amazon ECS) is a fully managed container orchestration service that helps you easily deploy, manage, and scale containerized applications. With ECS you can run all kinds of container based workloads. You can run container instances for data processing, web applications or spin up containers based on events.

[ECS Express Mode](https://aws.amazon.com/blogs/aws/build-production-ready-applications-without-infrastructure-complexity-using-amazon-ecs-express-mode/)[ is a new feature](https://aws.amazon.com/blogs/aws/build-production-ready-applications-without-infrastructure-complexity-using-amazon-ecs-express-mode/) of Amazon ECS with the promise to go from container image to a fully operational ‘production grade’ web application without thinking too much about infrastructure. The intended promise is to let application development teams focus on the application and let AWS apply the best practices around container infrastructure, scaling, and deployments. It will simplify the process of getting started with ECS and all the different components outside of ECS you will need to set up to run, for instance, a public accessible web-application.

ECS Express Mode is focused on deploying web applications and APIs. It provides a fully integrated set of AWS resources out of the box. Resources that you would normally have to define, configure, and wire together manually using infrastructure as code. If you’re an experienced ECS user, you’ll immediately appreciate how much heavy lifting Express Mode handles for you.

When you create your first Express Mode service, ECS automatically provisions and configures the following resources:

- **ECS Cluster** - A **default** cluster based on Fargate is created for you if you don’t provide an existing cluster.
- **ECS Task Definition** - Defines the container image, resource requirements, environment variables, and runtime configuration.
- **ECS Service** - Manages task lifecycle, placement, and health checks.
- **Rollback alarm** - When the service starts throwing a larger amount of 40X or 50X response codes after a new deployment, it can revert the deployment
- **Canary Deployment** strategy - By default, the service uses a canary deployment mechanism to deploy the service.
- **Application Load Balancer (ALB)** - Provides HTTP-based load balancing for your service. A single ALB will serve up to 25 ECS express services; when that limit is exceeded, Express Mode automatically provisions an additional ALB.
- **ALB Target Groups** - Route traffic from the load balancer to the running tasks of your service.
- **Route 53 Records (AWS-managed)** - Express Mode assigns an AWS-managed domain name that is not visible in your account but is automatically wired to your load balancer.
- **ACM Certificates** - An SSL/TLS certificate is created for each service to enable HTTPS. These certificates are managed in your account.
- **Security Groups -** Security groups are created for each layer of the network stack (load balancer, tasks, etc.). They follow the principle of least privilege—you only configure the application port once, and Express Mode manages the rest.
- **Application Auto Scaling -** A default auto scaling policy is created along with the necessary CloudWatch alarms. By default, scaling is based on CPU utilization, but you can switch to memory utilization or request count.
- **Cloudwatch Logs** - A new CloudWatch log group is created for your service. You can configure the log group and change the prefix if you want.

One of the great benefits is that ECS deploys all these resources in **your** account, which means you can see all individual components, view the configuration, and make changes to the existing configuration if required.

As you can see from the above list, that’s quite a list of things to configure if you had to do this manually. If you are a user new to ECS and see a lot of unknown elements in the above list, ECS Express mode might be a great fit for you. To get started with ECS Express Mode, you only need three things:

1. **An existing container image**
2. **An infrastructure role** - an IAM role that lets the ECS provision (non-ECS) resources in your account.
3. **A task execution role** - an IAM role that gives the container permissions to interact with other AWS services

## Creating an ECS Express Mode service in AWS CDK

ECS Express mode has support for CloudFormation and therefor also support in AWS CDK. The ECS Express Mode service takes care of provisioning all of the resources for you, so there is only a few CloudFormation resources for the express mode service itself. Let's take a look at what using AWS CDK to provision an ECS Express Mode service looks like.

### IAM roles and permissions

Let's first start with creating a task executions role with the required permissions for our task. In this post, we will use a simple nginx service to show how the service works, so we don't need a lot of permissions. You can get started with the default provided managed policy for ECS tasks: **AmazonECSTaskExecutionRolePolicy**.

```typescript
const taskExecutionRole = new Role(this, 'executionRole', {
    roleName: 'cdk-ecs-express-demo-execution-role',
    assumedBy: new ServicePrincipal('ecs-tasks.amazonaws.com'),
    description: 'ECS Task Execution Role',
    managedPolicies: [ManagedPolicy.fromAwsManagedPolicyName('service-role/AmazonECSTaskExecutionRolePolicy')]
});
```

The next role we create will be for the ECS service to create the resources in our account. Luckily AWS, has provided a default managed policy which we can use: **AmazonECSInfrastructureRoleforExpressGatewayServices**.

```typescript
const infrastructureRole = new Role(this,'infrastructureRole', {
    roleName: 'cdk-ecs-express-demo-infrastructure-role',
    assumedBy: new ServicePrincipal('ecs.amazonaws.com'),
    description: 'ECS Task Infrastructure Role',
    managedPolicies: [ManagedPolicy.fromAwsManagedPolicyName('service-role/AmazonECSInfrastructureRoleforExpressGatewayServices')]
});
```

Upon closer inspection, you can imagine this policy contains quite a list of permissions as it needs to cover a lot of services. It's worth inspecting the policy when your first start to use it. I won't copy it here as it contains about 280 lines or JSON at the moment.

### Defining the ECS Gateway Service

Now that we've set up the roles with the correct permissions, we can move to the final step, which is to create the ECS Express Mode Service. Currently (as of the beginning of december there is a level 1 CDK construct available, which maps directly to the CloudFormation resource. The resource is named **`CfnExpressGatewayService`**.

```typescript
let cfnExpressGatewayService = new CfnExpressGatewayService(this, 'ExpressServiceNginx1', {
    primaryContainer: {
        image: 'nginx:latest',
    },
    executionRoleArn: taskExecutionRole.roleArn,
    infrastructureRoleArn: infrastructureRole.roleArn,
});
```

In general, that's it. That's all you need to run your web app container service in ECS, which I think is pretty great. Now, how can you reach the service?

### Accessing the service

The ECS express mode service will handle DNS for you. The DNS records are the only thing that are not created within your own account, as far as I could tell (the ACM certificates are though). According to the [documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/express-service-getting-started.html#express-service-access-application), the _service name_ and _region_ should be enough to determine the URL of the service.

So if we define the service as:

```typescript
let cfnExpressGatewayService = new CfnExpressGatewayService(this, 'ExpressServiceNginx1', {
    serviceName: 'demo-express-service'
    primaryContainer: {
        image: 'nginx:latest',
    },
    executionRoleArn: taskExecutionRole.roleArn,
    infrastructureRoleArn: infrastructureRole.roleArn,
});
```

and we follow the pattern mentioned in the docs:

```plain
https://<service-name>.ecs.<region>.on.aws/
```

should have resulted in the service being accessible from https://demo-express-service.ecs.eu-west-1.on.aws/.

That made me wonder if the service name is unique, just like with an S3 bucket name, but when I tried specifying the **serviceName** property of the CfnExpressGatewayService the resulting URL would return a 404. The only way I've found to determine the correct URL for the service is by using  the **Endpoint** return value from the CloudFormation resource.

```typescript
new CfnOutput(this,"service1url", {
    key: 'service1url',
    value: 'https://'+ cfnExpressGatewayService.getAtt("Endpoint").toString()
})
```

Which results in the following output:

```bash
https://ng-e6840bdfebb54e28bb5c3c9bd7c1f5fa.ecs.eu-west-1.on.aws
```

As you can see there, is no mention of the service name in the generated endpoint. It does seem the first two letters of the domain are coming from the service name, but that might be a coincidence.

Once the service is up and running, you can inspect all the different components.

![Resources overview from the AWS Console](ecs-express-resources.jpeg)

### Configuring alternative settings

We've looked at the minimum configuration. Now let's take a look as some more configuration options.

### Specifying your own ECS cluster

By default, the service creates an ECS cluster in your default VPC with the cluster name **default**. If you don't have a default VPC or want to have more control over your cluster, you can configure your own cluster.

```typescript
const cluster = new Cluster(this, 'Cluster', {
    vpc: vpc,
    clusterName: 'cdk-ecs-express-demo-cluster',
})

let cfnExpressGatewayService2 = new CfnExpressGatewayService(this, 'ExpressServiceNginx2', {
    cluster: cluster.clusterName,
    primaryContainer: {
      image: 'nginx:latest',
    },
    executionRoleArn: taskExecutionRole.roleArn,
    // other optional configuration options
    healthCheckPath: "/",
    serviceName: 'express-service-nginx-2',
    infrastructureRoleArn: infrastructureRole.roleArn,
    // Autoscaling configuration
    scalingTarget: {
        minTaskCount: 1,
        maxTaskCount: 3,
    },
    // cpu: '512',
    // memory: '512',
});
```

According to the [CloudFormation documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ecs-expressgatewayservice.html), you can specify either the cluster name or the cluster ARN. However, when I tried the ARN, CloudFormation returned with an error.

```plain
Resource handler returned message: "Invalid request provided:
Invalid identifier: Unexpected number of separators (Service: Ecs, Status Code: 400, Request ID: ee074322-e841-4256-8bb7-2b2014b9c76e) (SDK Attempt Count: 1)" (RequestToken: ec5bfa00-2c43-db0f-3b7c-6374d0a33f5a, HandlerErrorCode: InvalidRequest)
```

I'm not sure if that's a problem in the documentation or if I misconfigured something. I advise you to stick to the clusterName, which seems to work.

### Alternative configuration options

The express mode service we created previously uses AWS best practices. If you have slightly different requirements, you can change specific parts of the configuration. For your container you can change for instance the cpu and memory requirements.

By default the ECS server will run in the default VPC and in a public subnet. You can specify alternative network settings for your service depending on your requirements. For instance your can switch to a different VPC and subnet. Because you can change the ECS cluster, you can probably also use Fargate Spot or EC2 based compute instead. I have not tested that though, and it might be something for another blog post.

Some settings can't be configured right now. Canary deployment for instance is the only supported deployment strategy. I think it's a great default, but I hope they will add linear or blue/green deployment as these strategies are now [ECS supported deployment strategies](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_service-options.html).

ECS Express mode only allows you to configure a single container. If you're currently using ECS and are using a sidecar container for for instance observability purposes, you won't be able to do that during creation with ECS express mode. You might want to consider using an Open Telemetry library, which integrates with your application framework. If you really need a sidecar container you can import the task defintion into your stack, once it has been created. Express Mode will keep 'manual' changes during additional deployments / updates.

### Configuring a WAF for your ECS service

In all cases where I use ECS with a public ALB, I always add a Web Application Firewall (WAF). I also tried this for the ECS Express mode service, but while trying this, I learned there things to consider. There is currently no out-of-the box experience for attaching the WAF to the load balancer created by the ECS service. The CloudFormation resource **AWS::ECS::ExpressGatewayService** does expose some [return values](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-ecs-expressgatewayservice.html#aws-resource-ecs-expressgatewayservice-return-values) after the resource has been created, which you can use to get the load balancer ARN.

With the return value for the ALB ARN, you can assign the WebACL to the created Load balancer.

```typescript
const cfnWebACLAssociation = new CfnWebACLAssociation(this, 'ALBWebACLAssociation', {
    resourceArn: cfnExpressGatewayService.getAtt("ECSManagedResourceArns.IngressPath.LoadBalancerArn").toString(),
    webAclArn: wafV2.attrArn,
});

// Don't forget to add a dependency, otherwise this association might happen before the service has been created.
cfnWebACLAssociation.addDependency(cfnExpressGatewayService);
```

There is a tricky problem I foresee, which is when you hit the 25 services limit and a new Application Load Balancer is created. ECS Express Mode handles this by itself, and if you don't have all 25 services defined in the same CDK stack, it gets hard to track if you'll need to create a new WebACL Association.

## Resource state management

After playing with ECS Express Mode for a while, it made me think. Who is in control of the resources created in your account? Who is responsible for its state? According to the ECS team they are not using CloudFormation internally, but are working with the direct APIs and use their own internal state for managing all resources. If you want to change specific parts of the default generated solution, you can import resources into CloudFormation/CDK and change them, but the ECS service will always be the owner of the resources. In an enterprise context where I see a lot of infrastructure as code, I wonder about the developer experience and aspects like compliance rules.

### CDK L3 constructs vs ECS Express Mode

If you're an experienced ECS and AWS CDK user you might question how Express Mode compares with, for instance, the **ApplicationLoadBalancedFargateService** construct. I think it comes quite close to what ECS express mode delivers. However, express mode also adds autoscaling, deployment rollbacks, canary deployment, smart load balancer sharing, default HTTPS, and domain management out of the box. If you're an experienced CDK user, you can get very far with the CDK provided L3 construct(s). You might even consider creating one that does something similar. The advantage of that would be that you have all AWS resources defined in your in CDK/CloudFormation and you have full control over all your resources. The ExpressGatewayService is a single AWS resource, which means it's tool agnostic and delivers the same level of business value if you use CDK, CloudFormation, Pulumi, Terraform, or any other kind of IaC tool. You're not depending on Terraform modules, CDK L3 constructs, or any other kind of configuration elements when working with IaC tools.

## Closing Thoughts

I like what the ECS team has created with ECS Express Mode. It's really great to go from a container image to a production like environment in a matter of minutes. This is going to work great for demo's and quick PoCs. Looking at this from an infrastructure as code perspective it feels a bit unnatural though as the ExpressGatewayService hides a lot of other AWS resources. If you're already a heavy CDK user, you might feel you have too little control over your resources. You can get a similar experience with creating your own L3 construct or using an existing one like the **ApplicationLoadBalancedFargateService.**
There are still some cases I want to explore further to see how ECS express mode compares to a set of L2/L3 constructs and how to handle changes to the individual components created by the express gateway service. The service is quite new, therefor I hope it will get some nice updates in the near future, like more deployment strategies, and perhaps custom domain support. If you've not looked at ECS Express Mode before I think it's definitely worth to take a look and see if it works for your specific use case.

## Further resources

- [Build production-ready applications with Amazon ECS Express Mode](https://www.youtube.com/watch?v=z9JUEQjpGgY) (Containers from the Couch)
- [Build production-ready applications without infrastructure complexity using Amazon ECS Express Mode](https://aws.amazon.com/blogs/aws/build-production-ready-applications-without-infrastructure-complexity-using-amazon-ecs-express-mode/) (AWS Blog)
- [From image to HTTPS endpoint in one step with ECS Express Mode](https://dev.to/aws-builders/from-image-to-https-endpoint-in-one-step-with-ecs-express-mode-1oi2)
- [GitHub repository](https://github.com/jreijn/demos-aws-cdk/tree/develop/aws-cdk-ecs-express) containing an ECS Express Mode sample CDK application with code mentioned in this blogpost.

> Photo by <a href="https://unsplash.com/@timelabpro?utm_source=sveltia-cms&amp;utm_medium=referral">Timelab</a> on <a href="https://unsplash.com/?utm_source=sveltia-cms&amp;utm_medium=referral">Unsplash</a>
