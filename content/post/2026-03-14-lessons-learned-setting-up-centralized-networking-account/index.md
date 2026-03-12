--- 
title: "AWS Transit Gateway Stack Walkthrough" 
date: 2025-02-14
draft: true
tags: [aws, networking, transit-gateway, vpn, ram, ssm, cloudformation] 
---
Overview

This post summarizes the provisioning flow shown in the architecture diagram, focusing on a multi-account AWS Transit Gateway setup with site-to-site VPN, RAM sharing, and VPC attachments.
Step-by-step flow

1. Deploy the `TransitGatewayStack` in the networking account to create a Transit Gateway and its route table.
2. The same stack provisions a site-to-site VPN with a Customer Gateway, creating two tunnels. A route is added to the Transit Gateway route table to forward on-premises CIDR ranges to the VPN connection.
3. During deployment, a Resource Access Manager share is created for the Transit Gateway and related SSM parameters, then shared with target accounts.
4. In each child account, deploy the `TransitGatewayAttachmentStack`. A custom resource accepts the RAM invitation through `ResourceShareAcceptor`.
5. After acceptance, a Transit Gateway attachment is created to connect the child account VPC to the Transit Gateway.
6. Based on configuration, routes for on-premises CIDR ranges are added to private subnet route tables in the child VPC.
7. Re-deploy the attachment stack to associate the attachment with the Transit Gateway. A custom resource discovers VPC attachments and enables propagation so connected CIDR ranges are added to the Transit Gateway route table.

Key outcomes

This flow centralizes connectivity, enables controlled sharing across accounts, and ensures on-premises and VPC routes are consistently propagated through the Transit Gateway.
