---
title: Implementing DNSSEC with AWS CDK
date: 2025-03-05T20:20:00
image: https://images.unsplash.com/photo-1633265486064-086b219458ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3MTc5ODl8MHwxfHNlYXJjaHwxOHx8c2VjdXJpdHl8ZW58MHx8fHwxNzQxMTc4ODYzfDA&ixlib=rb-4.0.3&q=80&w=1080
description: ''
draft: true
tags:
  - aws
  - cdk
  - dns
  - iac
categories:
  - AWS
  - Cloud Engineering
comments: false
---
In [a previous post](https://jreijn.hashnode.dev/multi-account-dns-with-aws-cdk), we've looked at how to setup DNS with Route53 and AWS CDK for a multi-account AWS organization. To make sure we secure our DNS Servers and our domain, we’ll dive into setting up DNSSEC in this post.

## What is DNS SEC?

Public domain names and DNS servers sometimes can be the target of attackers which try to hijack traffic to internet endpoints such as web servers. They try this by intercepting DNS queries and returning their own IP addresses to DNS resolvers instead of the actual IP addresses for those endpoints. Users are then routed to the IP addresses provided by the attackers in the spoofed response, for example, to fake websites.

To prevent this, you can protect your domain from this type of attack, known as DNS spoofing or a man-in-the-middle attack, by configuring Domain Name System Security Extensions (DNSSEC). DNSSEC is a protocol for securing DNS traffic by establishing a chain of trust for responses from intermediate resolvers. The chain of trust begins with the TLD registry for the domain (the domain's parent zone) and ends with the authoritative name servers at your DNS service provider. Which in our case is Route53.

TODO rewrite next paragraph as copied from CloudFlare

DNSSEC creates a secure domain name system by adding cryptographic signatures to existing DNS records. These digital signatures are stored in DNS name servers alongside common record types like A, AAAA, MX, CNAME, etc. By checking its associated signature, you can verify that a requested DNS record comes from its authoritative name server and wasn’t altered en-route, opposed to a fake record injected in a man-in-the-middle attack.

## Implementing DNS SEC with AWS CDK

### Creating a Key Management System (KMS) Key for DNSSEC

To be able to create a DNS signing key we will first need to create a AWS KMS key used for creating our signing key. Keep in mind that if you're planning to create your Route53 hosted zones in another region then `us-east-1` the KMS key can only be created in the `us-east-1` region. In my project I solved this by deploying different stacks to different regions in my CI/CD pipeline as separate steps.

![](/assets/2025/dns-sec-stages.png)

Let's take it step by step and see how DNS SEC can be implemented for our domains.

First we need to create a Route53 hosted 

```
import * as cdk from 'aws-cdk-lib';
import * as kms from 'aws-cdk-lib/aws-kms';

const dnsSecKey = new kms.Key(this, 'DnsSecKmsKey', {
    enableKeyRotation: true,
    alias: 'alias/dnssec-key',
});
```

### Enabling DNSSEC for our Route 53 Hosted Zone(s)

```
import * as route53 from 'aws-cdk-lib/aws-route53';

const rootHostedZone = route53.HostedZone.fromLookup(this, 'RootHostedZone', {
    domainName: 'exampledomain.com',
});

const keySigningKey = new route53.CfnKeySigningKey(this, 'RootKeySigningKey', {
    hostedZoneId: rootHostedZone.hostedZoneId,
    keyManagementServiceArn: dnsSecKey.keyArn,
    name: 'dnssec-key',
});

new route53.CfnDNSSEC(this, 'DNSSEC', {
    hostedZoneId: rootHostedZone.hostedZoneId,
});
```

### Register the DS record information with the domain registrar

You can get the DNS SEC information for the hosted zone by using the AWS CLI 

```
bash
aws route53 get-dnssec --hosted-zone-id <hosted-zone-id>
```

or from the AWS console.

Now that we have everything in place we need to make sure that our changes have been picked up correctly. Let's verify the DNSSEC status by using dig:

```
bash
dig +dnssec exampledomain.com
```
