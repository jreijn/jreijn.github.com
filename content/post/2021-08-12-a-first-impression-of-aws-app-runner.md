---
comments: false
date: "2021-08-12T00:00:00Z"
image: /assets/2021/blue-containers-banner.jpg
categories:
- Cloud Engineering
- AWS
tags:
- aws
- aws-apprunner
title: A first impression of AWS App Runner
---

About three months ago AWS released a new service named [AWS App Runner](https://aws.amazon.com/apprunner/). After reading the [introduction blog post](https://aws.amazon.com/blogs/containers/introducing-aws-app-runner/), I got pretty excited to check it out. AWS App Runner is a new service that provides organizations with a fast, simple, and secure way to deploy containerized applications on the AWS platform without managing any infrastructure. AWS already offers a wide range of container based services like AWS Fargate, ECS, Elastic BeanStalk, and AWS EKS, so why did they come up with App Runner?

## What makes App Runner different from the other services?

Let’s see how AWS describes App Runner.

> AWS App Runner is a fully managed service that makes it easy for developers to quickly deploy containerized web applications and APIs, at scale and with no prior infrastructure experience required. Start with your source code or a container image. App Runner automatically builds and deploys the web application and load balances traffic with encryption. App Runner also scales up or down automatically to meet your traffic needs. With App Runner, rather than thinking about servers or scaling, you have more time to focus on your applications.

To me the key selling point for App Runner is the fact that it’s very easy to use and a secure and **fully managed** service. It’s an opinionated architecture that makes it really easy to run containerized applications in AWS. App Runner offers another level of abstraction for the complex ecosystem of container runtime and orchestration options. Compared to the existing AWS container services there is almost no learning curve as you only need to point to a GitHub repo or a container image in ECR and provide some configuration settings for security, a default number of instances and required resources for a single instance, and it will create a secure, fully load-balanced and autoscaling service.

![Screenshot of the AWS Console show the different source and deployment options for an App Runner service.](/assets/2021/app-runner-source-settings.png)

<p><small>Screenshot of the AWS Console showing the different source and deployment options for an App Runner service.</small></p>


![Screenshot of the AWS Console showing the different service settings for an App Runner service.](/assets/2021/app-runner-service-settings.png)

<p><small>Screenshot of the AWS Console showing the different service settings for an App Runner service.</small></p>

## What’s hiding under the hood of AWS App Runner?

App Runner is built upon a wide range of different AWS services:

*   [AWS CodeBuild](https://aws.amazon.com/codebuild/) – For building, testing, and packaging the application. Only used if you choose to build from source. Supported languages are Node.js and Python.
*   [AWS Fargate](https://aws.amazon.com/fargate/) & [AWS ECS](https://aws.amazon.com/ecs/) – Used for the underlying managed container orchestration platform.
*   [AWS Auto Scaling](https://aws.amazon.com/autoscaling/) – Makes sure that the application scales based on the number of concurrent requests.
*   [AWS Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/) – Makes sure that the load is evenly distributed amongst the different instances of the service.
*   [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) – Used for storing App Runner Logs (events, deployments, and application) and metrics.
*   [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) – Used to provide out-of-the-box SSL/TLS certificates for the service endpoint.
*   [AWS KMS](https://aws.amazon.com/kms/) – Used to encrypt copies of the source repository and service logs.

Next to that, you can also configure/register your own (sub-) domain for the service, which presumably is using Route53 (could not find that anywhere).

As you can see that’s a whole bunch of services, configuration, provisioning, and management you don’t have to think about. AWS App Runner hides/abstracts this from you and lets you focus on your application and business problems. Pretty neat, huh?

## So what’s missing?

It’s a new service so some features are not (yet) available which you might find in similar services. While experimenting with App Runner I noticed a couple of them, so let’s take a look.

*   No native support for Parameter Store or Secrets Manager when configuring an App Runner service. You can still use those services via the SDK within your application, but you can’t use them for instance to configure some environment variables for your container.
*   As far as I could see App Runner does not (yet) allow you to work with resources inside a private VPC (for instance an RDS instance).
*   If you’re a fan of AWS CDK, you will have to keep in mind that CDK only offers L1 constructs for creating an App Runner service for now. No L2 support yet, but it seems that’s [on the roadmap](https://github.com/aws/apprunner-roadmap/issues/7).
*   App Runner only supports the blue/green deployment model, so other options like rolling, canary or traffic split are not an option right now.
*   No other container repositories besides ECR are supported.
*   No other git repositories besides GitHub are currently supported. I expect them to add CodeCommit pretty soon.
*   As with most new services App Runner is currently only available in a few regions: Europe (Ireland), Asia Pacific (Tokyo), US East (N. Virginia), US East (Ohio), US West (Oregon).
*   There is no support yet for languages like Java, Go, Rust, Ruby, etc. So if one of those is your favorite programming language you will have to create a container image before you can launch the service in App Runner.
*   App Runner does not allow you to scale to zero instances. You will always have a single instance running and will be charged for the allocated resources.

## Pricing

When you look at the [pricing](https://aws.amazon.com/apprunner/pricing/) mentioned on the AWS App Runner page you might think it’s pretty cheap with $ 5 dollar a month, but there is more to it. They mention that it costs about $ 5 a month, but while reading the small letters it says that that’s the case for an app running a single instance that is paused for about 22 hours a day. With App Runner, you are charged for the compute and memory resources used by your application. From what I noticed while running a service is that from a CPU perspective you seem to be only charged for the actual CPU resources spent. If your application is not being used, you are not consuming CPU and therefore are not billed for CPU usage. Memory on the other hand will stay reserved for your application and you will be billed accordingly. You will also be charged for additional App Runner features like building from source code or automating your deployments. Pricing therefore might not be straightforward at first, but also not too complicated to figure out. Before you start migrating your apps to App Runner be sure to try and estimate your bill as it might not be worthwhile to migrate from a micro EC2 instance to App Runner.

![](/assets/2021/app-runner-billing.png)

## Final thoughts

The first time I read the announcement about App Runner it made me think about Google Cloud Run. I see App Runner as the AWS response to Google Cloud Run. It has a strong opinionated architecture and built on top of other great AWS services. The ease of use is really great and without having a lot of experience with containers you can get started really quickly. I’ve tested App Runner with a bunch of Spring Boot applications and it was really easy to get an application up and running within a couple of minutes. I think App Runner can be very useful for creating small applications with use cases such as REST APIs or web applications. I think it’s great for rapid prototyping and deploying PoCs and MVPs.  
There is a [public roadmap](https://github.com/aws/apprunner-roadmap) that starts to take shape with some great features. Popular tools used by the AWS community are actively adding support for App Runner. I’m looking forward to seeing where App Runner will be in a year from now.

## Additional resources

*   [AWS App Runner Workshop](http://apprunnerworkshop.com/) – Great if you want to get started with some hands-on exercises.
*   [AWS App Runner Deep Dive (video)](https://www.youtube.com/watch?v=x_1X_4j16A4) – Really nice overview of the services and gives some good insights into how features like auto-scaling works.

Feel free to leave a comment or tweet at [@jreijn](https://twitter.com/jreijn)
