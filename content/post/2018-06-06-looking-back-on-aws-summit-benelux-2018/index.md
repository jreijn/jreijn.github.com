---
comments: false
date: "2018-06-06T23:32:51Z"
tags:
- aws
categories:
- AWS
title: Looking back on AWS Summit Benelux 2018
---

Last week I visited [AWS Summit Benelux][1] together with [Sander][2]. AWS Summit is all about cloud computing and the topics that surround cloud computing. This being my first AWS conference I can say it was a really nice experience. Sure there was room for improvement (no coffee or tea after the opening keynote being one), but other than that it was a very good experience. Getting inside was a breeze with all the different check-in points and after you entered you were directly on the exhibitor floor where a lot of Amazon partners showed their products.

## Opening keynote

The day started with an introduction by Kamini Aisola, Head of Amazon Benelux. With this being my first AWS summit it was great to see Kamini showing some numbers about the conference: 2000 attendees and 28 technical sessions. She also showed us the growth pattern of AWS with an increasing growth of 49% compared to last year. That's really impressive!

## Who are builders?

Shortly after, Amazon.com CTO [Werner Vogels][3] started with his opening keynote. Werner showed how AWS evolved from being 'just' an IaaS company to now offering more than 125 different services. More than 90% of the developed services were based on customer feedback from the last couple of years. That's probably one of the reasons why AWS is growing so rapidly and customers are adopting the AWS platform.

What I noticed throughout the entire keynote is that AWS is constantly thinking about what builders want to build (in the cloud) and what kind of tools those builders need to have to be successful. These tools come in different forms and sizes, but I noticed there is a certain pattern in how services evolve or are grown at AWS. The overall trend I noticed during the talks is that engineers or builders should have to spend less time focussing on lower level infrastructure and can start to really focus on delivering business value by leveraging the services that AWS has to offer.

During the keynote Werner ran through a couple of different focus areas for which he showed what AWS is currently offering. In this post I won't go through all of them, because I expect you can probably watch a recording of the keynote on youtube soon, but I'll highlight a few.

Let's first start with the state of Machine Learning and analytics. Werner looked back at how machine learning evolved at Amazon.com and how services were developed to make machine learning more accessible for teams within the organisation. Out of this came a really nice mission statement:

> AWS want's to put machine learning in the hands of **every** developer and data scientist.

To achieve this mission AWS is currently offering a layered ML stack to engineers looking into to using ML on the AWS platform.

![](/assets/2018/ml-stack-aws.png)

The layers go from low-level libraries to pre-build functionalities based on these lower level layers. I really liked that fact that these services are built in such a way that engineers can decide at which level of complexity they want to start using the ML services offered by AWS. Most of the time data engineers and data scientist will start from either [SageMaker][5] or even lower, but most application developers might just want to use a pre-built functionality like image recognition, text processing or speech recognition. See for instance this [really awesome post][6] on using Facial recognition by my colleague [Roberto][7].

Another example of this layered approach was with regards to container support on AWS. A few years back Amazon added container support to their offering with Amazon Elastic Container Service (Amazon ECS). This allowed Amazon ECS helped customers run containers on AWS without having to manage all servers and manager their own container orchestration software. ECS delivered all of this. Now fast forwarding a few years Amazon is now offering [Amazon EKS][8] (managed Kubernetes on Amazon) after they noticed that about 63% of managed Kubernetes clusters ran on AWS. Kubernetes has become the current industry standard when it comes to container orchestration, so this makes a lot of sense. In addition, Amazon now also offers [Amazon Fargate][9]. With Fargate they take the next step which means that Fargate allows you as the developer to focus on running containers 'without having to think about managing servers or clusters'.

![](/assets/2018/IMG_0108.jpg)

During his keynote, Werner also mentioned the [Well-Architected framework][11]. The Well-Architect framework has been developed to help cloud architects run their applications in the cloud based on AWS best practices. When implemented correctly it allows you to fully focus on your functional requirements to deliver business value to your customers. The framework is based on the following five pillars:

1.  Operational Excellence
2.  Security 
3.  Reliability
4.  Performance Efficiency
5.  Cost Optimization

I had not heard about the framework before, so during the weekend I read through some of its documentation. Some of the items are pretty straightforward, but others might give you some insights in what it means to run applications in the cloud. One aspect of the Well-Architected framework, Security, had been recurring throughout the entire keynote.

Werner emphasised a very important point during his presentation:

> Security is **EVERYONE's** job

With all the data breaches happening lately I think this is a really good point to make. Security should be everybody's **number one priority** these days.

During the keynote, there were a couple of customers that showed how AWS had helped them achieve a certain goal. Bastiaan Terhorst, CPO at [WeTransfer][12] explained that being a cloud-scale company comes with certain problems. He explained how they moved from a brittle situation towards a more scalable solution. They could not modify the schema of their DB anymore without breaking the application, which is horrible if you reach a certain scale and customer base. They had to rearchitect the way they worked with incoming data and using historic data for reporting. I really liked the fact that he shared some hard-learned lessons about database scalability issues that can occur when you reach a certain scale.

[Tim Bogaert][13], CTO at [de Persgroep][14] also showed how they moved from being a silo-ed organization with own datacenters and waterfall long-running projects towards all-in AWS with an agile approach and teams following the "You Build It, You Run It" mantra. It was an interesting story because I see a lot of larger enterprises still struggling with these transitions.

After the morning keynote, the breakout sessions started. There were 7 parallel tracks and all with different topics, so plenty to choose from. During the day I attended only a few, so here goes.

## Improve Productivity with Continuous Integration & Delivery

This really nice talk by [Clara Ligouri][15] (software engineer for AWS Developer Tools) and [Jamie van Brunschot][16] (Cloud engineer at Coolblue) gave a good insight into all the different tools provided by AWS to support the full development and deployment lifecycle of an application.

![](/assets/2018/IMG_0114-768x576.jpg)

Clara modified some code in [Cloud9][18] (the online IDE), debugged some code, ran CI jobs, tests and deployments all from within her browser and pushed a new change to production within only a matter of minutes. It shows how far the current state of being a cloud-native developer has really come. I looked at Cloud9 years ago. Way before they were acquired by Amazon. I've always been a bit skeptical when it comes to using an online IDE. I remember having some good discussions with the CTO at my former company about if this would really be the next step for IDEs and software development in general. I'm just so comfortable with IntelliJ for Java development and it always works (even if I do not have any internet ;-)). I do wonder if anybody reading this is already using Cloud9 (or any other Web IDE) and is doing his / her development fully in the cloud. If you do, please leave a comment, I would love to learn from your experiences. The other tools like CodePipeline and CodeDeploy definitely looked interesting, so I need to find some time to play around with them.

## GDPR

Next up was a talk on GDPR. The room was quite packed. I didn't expect that though, because everybody should be GDPR compliant by now right? :-) Well not really. Companies are still implementing changes to be compliant with GDPR. The talk by Christian Hesse looked at different aspects of GDPR like:

*   The right to data portability
*   The right to be forgotten
*   Privacy by design
*   Data breach notification

He also talked about the [shared responsibility model][19] when it comes to being GDPR compliant. AWS as the **processor** of personal data and the company using AWS being the **controller** are both responsible for making sure data stays safe. GDPR is a hot topic and I guess it will stay so for the rest of the year at least. It's something that we as engineers will always need to keep in the back of our minds while developing new applications or features.

## Serverless

In the afternoon I also attended a talk on Serverless by Prakash Palanisamy (Solutions Architect, Amazon Web Services) and Joachim den Hertog (Solutions Architect, ReSnap / Albelli). This presentation gave a nice overview of Serverless and Step functions, but also showed new improvements like the Serverless Application Repository, save Serverless deployments and incremental deployments. Joachim gave some insights into how Albelli was using Serverless and Machine Learning on the AWS platform for their online photo book creator application called ReSnap.

![](/assets/2018/IMG_0133-768x576.jpg)

Unfortunately I had to leave early, so I missed the end of the Serverless talk and the last breakout session, but all in all AWS Summit Benelux was a very nice experience with some interesting customer cases and architectures. For a 'free' event it was amazingly organized, I learned some new things and had a chance to speak with some people about how they used AWS. It has triggered me to spend some more time with AWS and its services. Let's see what interesting things I can do on the next Luminis TechDay.

Build On!

 [1]: https://aws.amazon.com/summits/benelux/
 [2]: https://amsterdam.luminis.eu/author/sander-meinema/
 [3]: https://twitter.com/Werner
 [4]: /assets/2018/ml-stack-aws.png
 [5]: https://aws.amazon.com/sagemaker/
 [6]: https://amsterdam.luminis.eu/2018/06/05/tech-day-facial-recognition-on-my-magic-mirror/
 [7]: https://amsterdam.luminis.eu/author/roberto/
 [8]: https://aws.amazon.com/blogs/aws/amazon-elastic-container-service-for-kubernetes/
 [9]: https://aws.amazon.com/fargate/
 [10]: /assets/2018/IMG_0108.jpg
 [11]: https://aws.amazon.com/architecture/well-architected/
 [12]: https://wetransfer.com
 [13]: https://twitter.com/bogguard
 [14]: https://www.persgroep.be/en
 [15]: https://twitter.com/clare_liguori
 [16]: https://twitter.com/JvanBrunschot
 [17]: /assets/2018/IMG_0114.jpg
 [18]: https://aws.amazon.com/cloud9/
 [19]: https://aws.amazon.com/compliance/shared-responsibility-model/
 [20]: /assets/2018/IMG_0133.jpg