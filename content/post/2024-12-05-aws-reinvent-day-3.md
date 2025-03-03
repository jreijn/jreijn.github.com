---
comments: false
date: "2024-12-05T14:42:24Z"
image: /assets/2024/reinvent/rethink-databases.jpg
categories:
- AWS
tags:
- aws
- reinvent
title: AWS re:Invent 2024 Day 3
---

[Day 2](/2024/12/aws-reinvent-day-2.html) ended with a great global AWS Community Builder mixer. On day 3 of re:invent I had to skip the opening keynote by Dr. Swami Sivasubramanian VP AI & Data, because I planned to start the day with “DAT404: Advanced data modelling with Amazon DynamoDB” by [Alex DeBrie](https://www.alexdebrie.com). Alex is a great speaker and author of the [DynamoDB book](https://dynamodbbook.com), so I really wanted to attend this session in person. When I arrived at the session I quickly learned I wasn’t the only one skipping the keynote. The queue went around the corner, but luckily I had reserved a seat so I did not have to get into the Walk-up line.

![Long queue for the session](https://cdn.hashnode.com/res/hashnode/image/upload/v1733694445246/d69c1a68-1a23-4ae5-a21b-cc69b8cc1314.jpeg)

## Advanced data modelling with Amazon DynamoDB

Alex discussed a lot of different concerns when working with DynamoDB:

* Data modelling basics (collections, denormalization, LSIs, GSIs)
* DynamoDB + napkin math (always validate what working with DynamoDB will costs you)
* DynamoDB Stream and how you can disconnect applications from having too many responsibilities like writhing to both DynamoDB and SQS as the same time.

Again I learned quite a few interesting lessons, so that talk was definitely worth it.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733726430345/0685eaf6-acab-484c-93ae-0dcef5789911.jpeg)

After the session I went to the AWS Community Hub to meet some fellow builders, watch the replay of the keynote, and finish my day 2 post. The Community Hub was located inside the Venetian shopping area which is a crazy place if you’ve never been to Vegas before. It contains some elements of actual Venice like a canal with gondola’s, palazzo’s, etc.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733729186558/b3de0dc4-6397-4902-a7e0-e5dc99cc5e58.jpeg)

## AI and Data keynote by Dr. Swami Sivasubramanian

The keynote showed some interesting new releases:

* Amazon Bedrock:
    
    * **Bedrock Marketplace** - provides generative AI developers access to over 100 publicly available and proprietary foundation models (FMs)
        
    * Text-to-image models from **Stability AI** are added
        
    * Generating high-quality video clips from text and images with the models from **Luma AI** are added to Bedrock
        
    * **Poolside's Assistant** is added to Bedrock powered by its malibu and point models
        
    * **Prompt caching** for supported models. Caches frequently used prompts across multiple API calls
        
    * **Prompt Routing** - Uses prompt matching and model understanding techniques, Intelligent Prompt Routing predicts the performance of each model for each request and dynamically routes each request to the model that it predicts is most likely to give the desired response at the lowest cost
        
    * **Bedrock Knowledge Bases** offers an end-to-end managed workflow for customers to build custom generative AI applications that can access and incorporate contextual information from a variety of structured and unstructured data sources
        
    * **Bedrock Knowledge Bases** now supports **GraphRAG,** providing more accurate and comprehensive responses to end users by using RAG techniques combined with graphs.
        
    * **Bedrock Data Automation** enables developers to automate the generation of valuable insights from unstructured multimodal content such as documents, images, video, and audio to build GenAI-based applications.
        
    * **Bedrock Guardrails Multimodel toxicity detection** \- enabling the detection and filtration of undesirable and potentially harmful image content while retaining safe and relevant visuals.
        
* Amazon Q:
    
    * Q Developer is now available in **SageMaker Canvas**
        
    * Is now available in **Quicksight Scenarios**
        

Before heading out of to my next session, which was in the furthest away location, I decided to walk the expo a bit. The expo hall is HUGE with so many vendors promoting their products. It was great meeting many different vendors and catching up with great projects like [LocalStack](https://www.localstack.cloud) and [Elastic](https://www.elastic.co), which I’ve used over the years.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733750634755/6c301493-ea0b-4b10-a20d-96199eddb8d8.jpeg)

## Deep dive intro Amazon Aurora DSQL and it’s architecture

After the EXPO I took the transit to the Mandalay Bay convention center to attend Marc Brooker’s deep dive session on the architecture behind [Aurora DSQL](https://aws.amazon.com/blogs/database/introducing-amazon-aurora-dsql/), the new serverless database introduced by AWS.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733748025963/1e257fc9-13b4-48d4-9b22-b4dd499d5cbe.jpeg)

This was a very interesting break-out session (recording should be up soon) about the challenges of designing and running a distributed database. It was interesting to hear how they split of a traditional monolithic database into separate services with their own responsibilities. Marc has a [series of blogs posts](https://brooker.co.za/blog/) about DSQL, which I highly recommend reading if you’re interested in DSQL.

## EMEA networking reception

The day ended with returning back to the Venetian before heading out to the Wynn for the EMEA networking reception in the XS night club. Finding your way around these hotels and convention centers can be a bit of a challenge, especially when it’s your first time. When I finally found the night club it was quite busy, as to be expected for a conference with about 60.000 people, and I enjoyed a nice evening with great food and nice music.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733750832657/2b1efeba-6557-4600-aa4a-e54d707413c5.jpeg)
