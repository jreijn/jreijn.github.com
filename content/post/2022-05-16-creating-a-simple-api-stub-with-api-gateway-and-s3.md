---
comments: false
date: "2022-05-16T00:00:00Z"
image: /assets/2022/apigateway-to-s3-header.jpg
categories:
- Cloud Engineering
- AWS
tags:
- aws
- lambda
- apigateway
- java
- iac
title: Creating a simple API stub with API Gateway and S3
---


A while ago my team was looking to create a stub for an internal JSON HTTP based API. The to-be stubbed service was quite simple. The service exposed a REST API endpoint for listing resources of a specific type. The API supported paging and some specific request/query parameters.

**GET** requests to the service looked something like this:

    /items?type=sometype&page=2

We wanted to create a simple stub for the service within our AWS account which we could use for testing. One of the tests we wanted to perform is to test if the service was down. If so our application would follow a specific code path. We could of course not easily test this with the real services. of the remote API, we tried to keep things as simple as possible.

## Creating the API with API Gateway, Lambda, and S3

As most of the services within our domain are based on Amazon API Gateway and AWS Lambda, we started looking into that direction at first. As our stub was read-only and we didn’t have to modify the items, we chose to create an initial export of the dataset from the remote API into JSON files, which we could store in S3. For storing the files we chose to use a file name pattern that resembled our type and page parameter.

{TYPE}_{PAGE_NUMER}(.json)

This resulted in a bucket like this:

![](https://cdn-images-1.medium.com/max/3940/1*iGykWCXv2u6iEYCarLd3xw.png)

So the simplified design of the API stub was going to be as follows:

![](https://cdn-images-1.medium.com/max/2000/1*Yl8P5mVvA2LB8IpGERk-bQ.png)

An example version of what our code looked like was something similar to this:

<script src="https://gist.github.com/jreijn/33a09f144a0471fb16bc82acb241d3b3.js?file=Function.java"></script>

As you can see in the above snippet, we’re essentially calculating the path to the object in S3 based on some request parameters. When the path is resolved we just fetch the file from S3, and convert it to a string for the reply to API Gateway, which in turn returns the file to the consumer. Our lambda function was just acting as a simple proxy and we were wondering if we could get rid of the lambda function at all. Maintaining code, dependencies, etc takes a burden so if we don’t need it we would like to get rid of it.

## Creating the API with just API Gateway and S3

API Gateway has great support for direct integration with other AWS services, so we started exploring our options. The solution we hoped for was something similar to the image below.

![](https://cdn-images-1.medium.com/max/2000/1*BenWKBGtj0wKy4hwRGNNQw.png)

While going through the documentation for API Gateway we found [a pretty good example of how to use API Gateway as a proxy for S3](https://docs.aws.amazon.com/apigateway/latest/developerguide/integrating-api-with-aws-services-s3.html). The provided solution lets API Gateway mirror the folder and file structure(s) in S3. Useful, but it did not cover our use case.

One of the other options that looked promising was configuring [mapping templates](https://docs.aws.amazon.com/apigateway/latest/developerguide/models-mappings.html). We had used that before to transform an incoming request body to a different format for the remote backend. In case you’re unfamiliar with mapping templates in API Gateway:

A *mapping template* is a script expressed in [Velocity Template Language (VTL)](https://velocity.apache.org/engine/devel/vtl-reference.html) and applied to the payload using [JSONPath expressions](http://goessner.net/articles/JsonPath/).

After digging through the API Gateway documentation we also discovered that mapping templates can be used to alter the [query string, headers, and path](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-override-request-response-parameters.html).

<script src="https://gist.github.com/jreijn/33a09f144a0471fb16bc82acb241d3b3.js?file=parameter-mapping.csv"></script>

Modifying the path was exactly what we wanted, so we tried that and it worked like a charm. Let’s take a look at the resulting setup for our API Gateway GET request.

![](https://cdn-images-1.medium.com/max/2652/1*Xg9rbrFprMRLLWuUILtojw.png)

As you can see in the above section we’ve added a GET method to the root of our API. The GET method has a method request which defines both query parameters; *page* and *type*.

![](https://cdn-images-1.medium.com/max/2652/1*k40m7L2NVCdYzvoAuAD21A.png)

For the integration request, we define the remote service we want to integrate with and we specify the bucket and a dynamic fileName.

![AWS Console screenshot of the integration request](https://cdn-images-1.medium.com/max/2000/1*sGUCytwl-tpwEqZ87LJzqg.png)*AWS Console screenshot of the integration request*

In the path override of the integration request there are two important things to notice:

1. At the start of the **Path override** parameter, we provide the S3 bucket name

1. As the second argument, we provide a dynamic value named **fileName**

The path override will therefor be {bucket-name}/{fileName}.

Now in our mapping template, we will fill the **fileName** parameter so that API Gateway knows which file to get from S3.

Let’s take a look at the mapping template.

![](https://cdn-images-1.medium.com/max/2000/1*SFI1w35OhwVh8lTuEcDEtw.png)

As you can see we’ve set up a template for requests for content-type **application/json**. Now when a GET request arrives with the *type* and *page* query parameters, it will assemble the resulting ***fileName*** variable in the path override.

<script src="https://gist.github.com/jreijn/33a09f144a0471fb16bc82acb241d3b3.js?file=mapping-template.vm"></script>

When the file in that specific bucket is found it will return the corresponding JSON. When the file is not found it will throw a 404 response body. We can also map the response code with a mapping template to produce some nice-looking error messages.

## Some last thoughts

While researching this solution I also came across a post by [Tom Vincent](https://twitter.com/tlvince). Tom wrote a nice post about what he calls [Lambdaless](https://tlvince.com/lambdaless). I like the term and it resonates well with what we also tried to achieve in this post.

I think this post shows a nice way of using Mapping Templates in API Gateway to transform the path and create a simple stub. Do keep in mind we use this for testing only and we don’t run production workloads with this setup. I also think that if the API would have been more complex we would not have taken this approach. Nevertheless, it was simple to set up and use for our stub.
