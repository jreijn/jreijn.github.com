---
canonical: https://www.luminis.eu/blog/my-journey-with-aws-cdk-and-java-what-you-need-to-know/
canonical_url: https://www.luminis.eu/blog/my-journey-with-aws-cdk-and-java-what-you-need-to-know/
comments: false
date: "2024-09-02T11:00:00Z"
image: /assets/2024/scott-rodgerson-PSpf_XgOM5w-unsplash_layered.jpg
categories:
- Cloud Engineering
- AWS
tags:
- aws
- aws-cdk
- java
- iac
- dns
title: 'My Journey with AWS CDK and Java: What You Need to Know'
---

One of the first decisions you’ll need to make when working with the [AWS Cloud Development Kit (CDK)](https://aws.amazon.com/cdk/) is choosing the language for writing your Infrastructure as Code (IaC). The CDK currently supports TypeScript, JavaScript, Python, Java, C#, and Go. Over the past few years, I’ve worked with the CDK in Typescript, Python and Java. While there is ample information available online for TypeScript and Python, this post aims to share my experience using Java as the language of choice for the AWS CDK.

## *Wait…. what? Using Java with the AWS CDK?*

Some may say that Typescript is the most obvious language to use while working with the AWS CDK. The CDK itself is written in Typescript and it’s also the most used language [according to the 2023 CDK Community Survey](https://matthewbonig.com/posts/community-survey-2023/). Java is coming in 3rd place with a small percentage of use.

![https://matthewbonig.com/posts/community-survey-2023/](https://matthewbonig.com/assets/blog/community-survey-2023/language.png)

Image source [https://matthewbonig.com/posts/community-survey-2023/](https://matthewbonig.com/posts/community-survey-2023/)

I do wonder if this still holds true given the number of responses to the survey. I’ve worked with small businesses and large enterprise organizations over the last years, and I see more and more Java oriented teams move their workloads to AWS while adopting AWS CDK as their Infrastructure as Code tool. Depending on the type of service(s) being built by these teams they may or may not have any experience with either Python or Typescript and the NodeJs ecosystem, which makes sticking to Java an easy choice.

## General observations

From what I’ve seen, adopting the CDK in Java is relatively easy for most of these teams as they already understand the language and the ecosystem. Integrating the CDK with their existing build tools like [Maven](https://maven.apache.org) and [Gradle](https://gradle.org) is well documented, which leaves them with the learning curve of understanding how to work with infrastructure as code, how to structure a CDK project and when to use [L1, L2 and L3 constructs](https://docs.aws.amazon.com/cdk/v2/guide/constructs.html).

Compared to Typescript the CDK stacks and constructs written in Java contain a bit more boilerplate code and therefor might feel a bit more bloated if you come from a different language. I personally don’t feel this makes the code less readable and with modern IDE’s and coding assistants I don’t feel I’m less productive.

The CDK also seems to become more widely adopted in the Java community with more recent Java frameworks like [Micronaut](https://micronaut.io) even having built-in support for AWS CDK in the framework.

See for instance the following Micronaut launch configurations:

* [**Micronaut Application with API Gateway and CDK for Java runtime**](https://micronaut.io/launch?type=DEFAULT&javaVersion=JDK_11&features=aws-lambda&features=aws-cdk&features=amazon-api-gateway)
    
* [**Micronaut Function with API Gateway and CDK for Java runtime**](https://micronaut.io/launch?type=FUNCTION&javaVersion=JDK_11&features=aws-lambda&features=aws-cdk&features=amazon-api-gateway)
    

One of the advantages of Java is that it’s a statically-typed language, which means it will catch most CDK coding errors during compile-time. There are still some errors which you will only see during an actual `cdk synth` or `cdk deploy`. For instance, some constructs have required properties which will only become visible if you try to synthesize the stack, but in my experience, you will have that in other languages as well.

Performance wise it feels like the CDK in Java is a bit slower compared to using it Typescript or any other interpreted language. I’ve not measured this, but it’s more of a gut feeling. This might have to do with the static nature of Java and its corresponding build tools and compile phase. On the other hand it might be that the [JSII runtime architecture](https://aws.github.io/jsii/overview/runtime-architecture/) also has an effect and how Java is interacting with a Javascript environment.

## Java Builders

One of the biggest differences when using the AWS CDK with Java is the use of Builders. When creating constructs with Typescript you’re mainly using the *props* argument (map of configuration properties) while creating a construct. Let’s take a look at an example:

```jsx
const bucket = new s3.Bucket(this,"MyBucket", {
    versioned: true,
    encryption: BucketEncryption.KMS_MANAGED
})
```

The Java version of the above snippet uses a Builder class that follows the builder pattern for constructing the properties. If you’re unfamiliar with the Builder pattern in Java I recommend to checkout [this blog post](https://blogs.oracle.com/javamagazine/post/exploring-joshua-blochs-builder-design-pattern-in-java) about using the Builder pattern. Depending on the CDK construct you might be able to define a CDK resource in two different ways.

In the first example you use the Builder for the Bucket properties.

```java
Bucket bucket = new Bucket(this, "MyBucket", new BucketProps.Builder()
                           .versioned(true)
                           .encryption(BucketEncryption.KMS_MANAGED)
                           .build());
```

The alternative is that constructs can have their own builder class, which makes it a little less verbose and easier to read.

```java
Bucket bucket = Bucket.Builder
                           .create(this, "MyBucket")
                           .versioned(true)
                           .encryption(BucketEncryption.KMS_MANAGED)
                           .build();
```

## IDE support

Overall IDE support is really great when working with CDK in Java. I use IntelliJ IDEA on a daily basis and auto completion really helps when using the Builder objects.

![](/assets/2024/cdk_java_auto_complete.jpg)

As the CDK documentation is also inside the CDKs Java source code, looking up documentation is really easy. It’s similar to how you would do it with any kind of other object or library.

![](/assets/2024/cdk_java_docs.jpg)

## Third party construct support

The CDK itself is written in Typescript and for each supported programming language a specific binding is generated. This means that when a new resource or feature for an AWS service is added in the Typescript variant of the CDK it’s also available to developers using a Java based CDK.

Besides the default CDK constructs there are also a lot of community generated constructs. [Construct Hub](https://constructs.dev) is a great place to find them.

From what I’ve seen most constructs coming out of AWS will support Java as one of the default languages. Community supported constructs however might not. There are several popular constructs that only support Typescript and Python. Filtering on Construct Hub for AWS CDK v2 based constructs, sorted by programming languages results in the following data.

| **Language** | **Number of constructs libraries** |
| --- | --- |
| Typescript | 1164 |
| Python | 781 |
| .Net | 511 |
| Java | 455 |
| Go | 132 |

Depending on the type of infrastructure or third-party services you’re planning to use, you might not be able to use all available constructs. For instance, the constructs maintained by [DataDog](https://constructs.dev/packages/datadog-cdk-constructs-v2/) are only available in Typescript, Python and Go. In my personal experience though, most construct developers are open to support Java. Third party constructs are based on [projen](https://projen.io) and [jsii](https://aws.github.io/jsii/), which means that adding a Java based version is most of the time a matter of configuration in the package.json file of the project.

```json
"jsii": {
  "outdir": "dist",
  "targets": {
    "java": {
      "package": "io.github.cdklabs.cdknag",
      "maven": {
        "groupId": "io.github.cdklabs",
        "artifactId": "cdknag"
      }
    },
    "python": {
      "distName": "cdk-nag",
      "module": "cdk_nag"
    },
    "dotnet": {
      "namespace": "Cdklabs.CdkNag",
      "packageId": "Cdklabs.CdkNag"
    },
    "go": {
      "moduleName": "github.com/cdklabs/cdk-nag-go"
    }
  },
  "tsc": {
    "outDir": "lib",
    "rootDir": "src"
  }
}
```

( An example of how JSII is configured for the [CDK NAG project](https://github.com/cdklabs/cdk-nag) )

Once the configuration is in place and the artifacts have been pushed to for instance Maven Central, you’re good to go.

When thinking about it, I once had a 3rd party construct I wanted to use that did not support Java (yet). It got added quite quickly and there was also an alternative solution for it, so I can't remember having issues with the lower number of available constructs.

## Examples, tutorials and documentation

I think it’s good to reflect on the fact that there are more CDK examples and tutorials available in Typescript and Python compared to Java. This reflects the findings in the usage chart from the CDK Community Survey. However, reading Typescript as a Java programmer is relatively easy (my personal opinion). If you’re new to the AWS CDK there is a ton of example code available on Github, Youtube, and in numerous blog posts and tutorials. If you’re already using the CDK in combination with Java, be sure to write some blog posts or tutorials, so others can see that and benefit from your knowledge!

## Summary

Java is a very viable option when working with the AWS CDK, especially for workload teams already familiar with the language and its ecosystem. IDE support for the CDK is excellent with features like auto-completion and easy access to source code documentation.

All in all, the experience is really good. Keep in mind that picking Java for your infrastructure as code all depends on the context and the environment you’re in. I would suggest picking the language which is most applicable in your specific situation. If you still need to make the choice and are already working with Java, I definitely recommend trying it out!

> Photo by [Scott Rodgerson](https://unsplash.com/@scottrodgerson) on [Unsplash](https://unsplash.com/)
