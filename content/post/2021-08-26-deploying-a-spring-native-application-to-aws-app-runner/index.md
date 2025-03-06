---
comments: false
date: "2021-08-26T00:00:00Z"
image: /assets/2021/blue-containers-banner.jpg
categories:
- Cloud Engineering
- AWS
tags:
- aws
- aws-cdk
- aws-apprunner
- java
- iac
title: Deploying Spring Boot applications to AWS App Runner with AWS CodePipeline
---

In a [previous post](/2021/08/a-first-impression-of-aws-app-runner.html), we looked at [AWS App Runner](https://aws.amazon.com/apprunner/). AWS App Runner is a container service that lets you focus on your application and allows you to deploy your application in minutes without setting up any infrastructure.

AWS App Runner supports two source options for your App Runner service:

1.  By pointing to a Git(Hub) repository that contains your application source code
2.  From an existing container image stored in ECR (public or private is both possible)

The code-based source option only supports two languages at the moment: Node.js and Python. Your source also has to be stored on Github, but I expect AWS to add CodeCommit as a valid option pretty soon though. Now in my case, I would like to deploy a Java / [Spring Boot](https://spring.io/projects/spring-boot) based application to AWS App Runner, so my best bet, for now, is to use a container image based deployment. Now we could go for a pre-build image, but what’s the fun in that right? So in this post, we will take a look at a setup that you can leverage to deploy a Spring Boot based application to AWS App Runner.

## The overall setup

Our source code will be hosted in Github and we are leveraging CodePipeline + CodeBuild to build and test our Java application. If the build and test are successful we push the resulting container image to a private container registry in ECR. App Runner can then pick up the container image for deployment.

![](/assets/2021/app-runner-pipeline-export-e1629817366850-1024x575.jpg)

Now that we have a clear overall idea of what we need, let’s create the build and deployment stack with AWS CDK.

## Setting up the basics

The first thing we will need is a private container image repository in ECR. This will allow us to store our container image and can be used later by App Runner to get our application as a container.

<script src="https://gist.github.com/jreijn/390f0d784a4b97afd0feacf2be19a9a9.js?file=ECRRepository.java"></script>

With the image repository in place, we can continue with the next step, creating a CI pipeline for our project.

<script src="https://gist.github.com/jreijn/390f0d784a4b97afd0feacf2be19a9a9.js?file=BuildPipeline.java"></script>

The build pipeline makes sure that any code change will result in an update of our service. As you might have seen in the code snippet above we only build from the master branch, so any PR request, merge or commit to master will trigger a new build and will result in a new container image. In the App Runner service, which we will define later on, we can choose if we want App Runner to automatically deploy a new version of our application once it’s available. To instruct CodeBuild to build our maven based project and create a docker image out of that we can do so with a custom buildspec.yml file.

<script src="https://gist.github.com/jreijn/390f0d784a4b97afd0feacf2be19a9a9.js?file=buildspec.yml"></script>

As you can see we’ve split the build into 3 separate phases:

1.  We log into ECR and we create a hash for the image tag that we will create later on.
2.  We build the maven project and leverage the Spring Native maven plugin to create an a native image. For tagging with the correct container registry, we inject the repository location as an environment variable into our build process. As a final step, we tag the created docker image.
3.  We push the docker image to our ECR repository.

To make sure the App Runner service can fetch the docker image from our ECR repository, we will need to create and assign a role that has the permissions to do so.

<script src="https://gist.github.com/jreijn/390f0d784a4b97afd0feacf2be19a9a9.js?file=AppRunnerECRRole.java"></script>

## Creating the App Runner service

Now for the last and final part of our setup, we will need to create the AWS App Runner service via CDK.

<script src="https://gist.github.com/jreijn/390f0d784a4b97afd0feacf2be19a9a9.js?file=AppRunner.java"></script>

If we look at the above code snippet we’ve setup five configuration options for App Runner:

1.  The health check endpoint.
2.  The role required to access the image in ECR
3.  The image source and the Port that our container will listen on
4.  The service name
5.  The type of resources (memory/cpu) required to run our service


Now we have all the code we need for CDK to create the entire stack and create the service for us. It’s just a matter of running `cdk deploy` and you will have the entire stack up and running.

`$ cdk deploy`

If we want to know the URL of our new service, we can leverage a CDK `CnfOutput` construct in which you can request the URL of the service and it will be printed out once the stack is finished deploying.

<script src="https://gist.github.com/jreijn/390f0d784a4b97afd0feacf2be19a9a9.js?file=Output.java"></script>

When CDK is done with the deployment you will be able to find the URL to your service in the output of the CDK deploy.

     Do you wish to deploy these changes (y/n)? y 
     
     apprunner-runtime-stack: deploying... 
     apprunner-runtime-stack: creating CloudFormation changeset... 
     
     ✅  apprunner-runtime-stack 
     
     Outputs: apprunner-runtime-stack.serviceUrl = https://someid.eu-west-1.awsapprunner.com 

## Summary

Even if you’re not using a language supported by AWS App Runner, it’s still pretty straightforward to deploy your service to AWS App Runner. You can simply use your existing pipeline or create a new build pipeline in AWS CodePipeline that will result in an image in ECR, from which App Runner can do the rest. For this service, I’ve chosen to use [Spring Native](https://spring.io/blog/2021/03/11/announcing-spring-native-beta). Spring Native will create a native image for your Spring Boot application, which results in a much faster application startup. In my case, for a simple application, the time it takes for the application to start is about 500ms instead of 3 seconds (non-native image). When you expect your application to retrieve traffic spikes that might trigger app runner to scale out , this improvement can help for sure.