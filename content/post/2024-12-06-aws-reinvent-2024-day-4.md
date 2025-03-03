---
comments: false
date: "2024-12-06T20:15:03Z"
image: /assets/2024/reinvent/keep-it-simple-layer.jpg
categories:
- AWS
tags:
- aws
- reinvent
title: AWS re:Invent 2024 Day 4
---

Thursday, the day of the highly anticipated Dr. Werner Vogels keynote. On Wednesday I already heard about the fact that you would probably have to be in the queue around 6.30-7.00 am to be able to get into the keynote room. Because I did not sleep very well over the last couple of days I decided to take a bit of time in the morning to have breakfast in the Caesars Palace and watch the keynote from my hotel room before heading out for my first session of the day.

## Dr. Werner Vogels keynote

In his keynote Dr. Werner Vogels focussed on the concept of simplicity vs complexity.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733759162831/462da8ca-ce43-439e-bbba-c2b8467d1be6.png)

Building systems requires constant thought and with the ongoing demand from businesses, systems are always changing. Over time you need to be aware of the growing complexity of the system(s) at hand. He highlighted some great examples i’ve seen in real-life:

* Declining feature velocity
    
* Time consuming debugging
    
* Frequent escalation
    

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733759261340/6e9c0c86-886f-407a-bece-8a8e5fa1c47b.png)

The push for simplicity is important and he shared the lessons learned at Amazon.

* Evolvability as a Requirement
    
* Break Complexity into Pieces
    
* Align Teams with Architecture
    
* Organize into Cells
    
* Automate Complexity
    
* Design Predictable Systems
    

He continued his story with principles required to build evolvable systems. In his talk there are great examples of evolving systems like S3 and CloudWatch over time. There are many lessons to learn from this keynote as an engineer/architect/CTO, so if you havent seen it yet, I highly recommend [watching it on Youtube](https://www.youtube.com/watch?v=aim5x73crbM).

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733759600130/b9dd6e59-af3a-4df3-8541-fde3ce1971a0.png)

During the keynote there were two great customer stories by Canva and Too Good To Go (TGTG). Both shared an incredible story about the growth they had and how their systems and architecture design needed to adapt. It was nice to hear the story from TGTG about their migration from PHP to Java with Spring Framework to achieve clear boundaries and more performance by o.a. the great off the shelf features of Spring, transactions, connection pooling, etc. The story was a good step up to Aurora DSQL as TGTG wanted to scale globally into different regions where they for now had to duplicate their architecture.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733760283585/225375b8-d98d-4a87-8082-4823d0c7f836.png)

Werner continued with a deep dive on why they created Aurora DSQL (Distributed SQL) and how it can solve some of the challenges TGTG was facing during their growth phase.

## Is your Serverless application ready for production? (SVS313)

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733760668271/8ae9961e-de7e-4157-9daa-8b25eef7f8aa.jpeg)

In this chalk talk by [Mark Sailes](https://sailes.co.uk) and [Thomas Moore](https://tmmr.uk) we looked at three different serverless architectures and evaluated the production readiness against 5 pillars of the Well Architected Framework. This was a really good session with lots of interaction with the audience. It was also great to finally meet Mark in person, after having multiple conversation on Twitter.

## Optimize Amazon DynamoDB performance using AWS SDK for Java 2.x (DAT414)

For the final session of the day I went back to the Wynn for a code talk by [Arjan Schaaf](https://x.com/arjanschaaf) and [Michael Shao](https://michaelshao.com/). This session dived deep into using the Java SDK when using DynamoDB. We looked at several different factors like:

* synchronous versus asynchronous clients
    
* client initialisation
    
* different http clients like Apache http, aws-crt and url-connection client
    
* pre-initialisation of the data model
    
* client side and server side metrics
    

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733769027007/86d4dfcc-ba9e-465f-907e-5a61e01e56f2.jpeg)

This code talk showed some really nice and example and Arjan showed different steps with their impact on latency. Even though there are some sessions on Friday morning, this was my final re:invent session as on Friday we would be going home.

## re:Play

Thursdays at re:invent end with a party at the Las Vegas festival grounds. After a busy week with connecting and learning it was time for some relaxation. There was so much to do like roller disco, great food, drinks and some great headline artists like Weezer and Zedd.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733769292063/b98bb515-9b78-4de1-a4d5-eef995200e96.jpeg)

The party was great! I’m a big fan or EDM, so I really enjoyed Zedds performance!

