---
comments: false
date: "2024-12-04T11:24:45Z"
image: /assets/2024/reinvent/swami-and-vogel.jpg
categories:
- AWS
tags:
- aws
- reinvent
title: AWS re:Invent 2024 Day 2
---

Today was the second day of re:invent and the day was packed with exciting events. These days are full of sessions, social events and casual conversations at the Expo, Community Hub or just in line while waiting to get into a room.

## The CEO keynote with Matt Garman

In the morning I kicked off the day with the keynote by AWS CEO Matt Garman. I quickly learned that walking up 30 minutes before isn't enough to get into the room. Who would have guessed right with 60.000 people attending re:invent. Luckily there are many overflow rooms available 😅 I thought Matt was killing it 🔥 during the keynote. He introduced some great new announcements and as expected the keynote contained quite some new innovations around Generative AI. However, I thought it was well positioned by talking about the use case and customer requests. It didn't feel like GenAI "because of GenAI" like last year.

There are definitely some announcements I want to explore further over the next period. Some of the highlights for me were:

- The improvements for Amazon Q (unit test, documentation, code reviews, integration with GitLab Duo and transformations for .Net, VMWare and Mainframe).

- The introduction of Amazon Aurora DSQL

- The introduction of Amazon SageMaker Unified Studio

- The introduction of Amazons own foundational models: Nova

If you want to see all announcements from re:invent don't forget to keep your eye on [the top re:invents announcements blog](https://aws.amazon.com/blogs/aws/top-announcements-of-aws-reinvent-2024/).

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733339978730/5f8f9a2e-3e57-43bf-ac4f-c641c5407191.jpeg)

## Supercharge your Lambda functions with Lambda Powertools 🚀

Just after the keynote I attended the Dev session by [Raphael Manke](https://www.linkedin.com/in/raphael-manke/) on [Lambda Power Tools](https://docs.powertools.aws.dev/lambda/typescript/latest/). Raphael gave one heck of a demo and showed how Lambda power tools can supercharge your lambda functions and help improve observability, idempotency, batch handling and much more.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733339546271/859770da-9a37-4c01-8dc9-bdebb59a202f.jpeg)

## The EMEA Community Builders Mixer

Next up was a EMEA community mixer in the Buddy V restaurant. It was great meeting many EMEA based Community Builders. I got to meet Lee Gilmore there who has an excellent newsletter called "[Serverless Advocate](https://serverlessadvocate.substack.com)" (be sure to check it out at). These mixer events are great for getting to know people and learn about what other community members are doing.

## Mitigating noisy neighbour issues for multi-tenant SQS queues

After the mixer I headed to the MGM Grand together with [Pubudu Jayawardana](https://www.linkedin.com/in/pubudusj/) to attend a chalk talk about mitigating the noisy neighbours problem when having multi-tenant SQS queues.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733339609640/7fa2d438-3e1b-4b49-b5fe-5f778fa99169.jpeg)

They showed the following strategies:

- Having a single queue per tenant
- Separate queues for noisy neighbours
- Sharding to different queues (for instance with a hash function)
- Shuffle sharding
- Dynamic overflow queues
- And using SNS Topics and to queues and downstream sources

It was my first chalk talk and I'm definitely going to attend more of these as I really liked the open format and white boarding with AWS specialists.

## The Global AWS Community Builder mixer

After a quick workshop session on solving Idempotency issues in distributed systems it was time to head back for a Community Builders mixer with all community builders present at the AWS summit. It was great meeting Ayman Metwally, Jacob Verhoeks , Ivan Casco Valero, Rob Van Pamel, Fernando Paz, Jocelyn Poblete, Michael Liendo, Matt Bacchi, Arijita Mitra and Paloma Lataliza.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1733339847170/b7610311-c094-429a-9a83-bf2158597c6e.jpeg)

Jeff Bar was present and handed out some unique Builder Cards. For those of you who don't know, Jeff started the AWS blog about 20 years ago. It was also great to meet the people that bring this community together Jason Dunn, 🌤 Farrah Campbell and Thembile Martis!

Day two was another great day. The jetlag and long days are starting to wear on me a bit, but Im looking forward to day 3!