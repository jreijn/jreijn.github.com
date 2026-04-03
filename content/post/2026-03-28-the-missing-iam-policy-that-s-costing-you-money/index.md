---
title: The missing IAM policy that's costing you money
date: 2026-04-07T15:09:00+02:00
image: https://images.unsplash.com/photo-1633265486064-086b219458ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3MTc5ODl8MHwxfHNlYXJjaHwxM3x8c2VjdXJpdHl8ZW58MHx8fHwxNzc0NzA2OTkxfDA&ixlib=rb-4.1.0&q=80&w=1080
draft: true
description: ''
tags:
  - aws, iam, ec2
categories:
  - AWS
  - Cloud Engineering
---

At my current project we've been using the AWS EC2 Image Builder service for generating EC2 AMIs for Windows. The service itself is great. You create an image recipe, a pipeline, and you're good to go.

> Photo by <a href="https://unsplash.com/@towfiqu999999?utm_source=sveltia-cms&amp;utm_medium=referral">Towfiqu barbhuiya</a> on <a href="https://unsplash.com/?utm_source=sveltia-cms&amp;utm_medium=referral">Unsplash</a>
