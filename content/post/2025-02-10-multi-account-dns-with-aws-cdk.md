---
comments: false
date: "2025-02-10T17:25:21Z"
image: /assets/2025/levi-frey-x19nNMWeo5A-unsplash.jpg
categories:
- Cloud Engineering
- AWS
tags:
- aws
- cdk
- iac
- dns
title: Multi-account DNS with AWS CDK
---

I was recently tasked with setting up DNS within an AWS organization structure. The idea was to use a single domain structure that would be able to support multiple environments (development, acceptance and production). In my actual use case it was a bit more complex, but in this post I’ll keep it simple and show some example code how you can implement the solution with [AWS CDK](https://github.com/aws/aws-cdk).

## Setting the stage

In this post, we’ll look at setting up multi-account DNS for our AWS accounts. It starts with having a central (network) account that owns the DNS for the root domain. ( exampledomain.com ). To let teams create their applications, manage their subdomains, and request SSL certificates from ACM (AWS Certificate Manager), we wanted to let them own and manage the subdomain for a specific environment. In essence, we would have 4 AWS accounts with their own DNS management.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1739199448200/fe0f8828-2086-48fa-8a6e-26c7899ed1f0.jpeg)

## Creating and Managing Hosted Zones

Implementing DNS in AWS is handled by the Amazon Route 53 service. To implement DNS in Route 53 we need to use a Route 53 hosted zone. A hosted zone is a container within Route 53 where you store and manage the DNS records for a specific domain or subdomain. There are two types of hosted zones:

* **Public Hosted Zone**: Used to manage the DNS records for a domain or subdomain that is publicly accessible on the internet. Example: A website like [exampledomain.com](https://exampledomain.com).
    
* **Private Hosted Zone**: Used to manage DNS records for a domain within a Virtual Private Cloud (VPC). Example: Internal services accessed only within a private network, like [internaldomain.com](https://internaldomain.com).
    

In our case, we want to create a public hosted zone for our top-level domain. To do that with AWS CDK you can use the **PublicHostedZone** construct.

```javascript
const parentHostedZone = new PublicHostedZone(this, 'parent-hosted-zone', {
    zoneName: 'exampledomain.com',
});
```

The above code should be part of the stack deployed to the central (networking) account. Now let’s look at what is being created when we created our public hosted zone.

## Types of DNS records in Route53

When you create a public hosted zone, you will by default get two DNS records as part of the hosted zone.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1736159256161/b4049600-f26f-4aae-a670-3404314984f8.png)

The hosted zone will contain both a NS record as well as a SOA record, but what do these records mean?

* **NS record** - NS stands for 'nameserver,' and **the nameserver record indicates which DNS server is authoritative for that domain** (i.e. which server contains the actual DNS records). NS records tell the Internet where to go to find out a domain's IP address.
    
* **SOA record** - The DNS ‘start of authority’ (SOA) record stores important information about a domain or zone such as the email address of the administrator, when the domain was last updated, and how long the server should wait between refreshes.
    

To tell the client (for instance a web browser) where to resolve the subdomain, we can explicitly define in route53 that the authoritative domain servers for the subdomain are located elsewhere by adding an explicit NS record to the hosted zone of the root/parent domain.

## Connecting the hosted zone in the central account with the hosted zone in the child account

To manage the DNS for the subdomain in the environment-specific account, we will need to also create a route 53 hosted zone in the environment specific (dev, staging, prod) account. Our next would be to specify that the environment specific account is responsible for the sub-domain we will need to explicitly state the relationship in the Route53 hosted zone of the central account.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1739199398427/0263f3d1-07a7-4cde-bf6e-a17ebaa3ce96.jpeg)

The following table shows an example of how to define the authoritative NS servers for the subdomain dev.exampledomain.com. In the example we show a single value for the NS server, but when working with route53 you will always have four DNS servers.

| **Record name** | **Type** | **Value/Route traffic to** |
| --- | --- | --- |
| exampledomain.com | NS | ns-123123.aws-dns.org |
| dev.exampledomain.com | NS | ns-234234.aws-dns.org |
| staging.exampledoimain.com | NS | ns-345345.aws-dns.org |
| … | … | … |

Now, when a client tries to resolve the DNS for **dev.exampledomain.com**, it will first try to find the NS servers for **.com**, after which it will try to resolve **exampledomain.com,** followed by resolving the **dev.exampledomain.com** before reaching the correct authoritative domain servers. Adding an additional NS server will cause one additional hop before it can resolve the DNS, so keep that in mind when implementing this solution.

We could create the NS record(s) for the dev or staging account in the public-hosted zones of the central account via the AWS console, but ideally, you would want to automate the entire process.

## Implementing Sub-zone DNS delegation

As mentioned before we wanted teams to be able to manage sub-domain records for their accounts. This would allow them to create **applicationname.dev.exampledomain.com**. Having control over the DNS for the subdomain within the corresponding account will make it easy for them to create specific domain names for applications, or create DNS-validated HTTPS certificates (big plus for automation compared to email-validated certificates). To be able to do so in AWS CDK the easiest way is to create an IAM role that the Dev account can assume when trying to insert/update the NS records for its subdomain in the hosted zone of the parent domain.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1739199418625/bb05caf8-5ec8-4fc6-868f-564365cf12fb.jpeg)

To create such a role in the central account you can choose to do this by using an organization(al unit) id or by using an account id. Let’s take a look at some examples.

```javascript
const role = new Role(this, 'ParentZoneOrganizationRole', {
    assumedBy: new OrganizationPrincipal('o-xxxxxxx'),
    roleName: 'HostedZoneDelegationRole',
});
```

In the above example, we specify that any account being part of a specific organization or organizational unit can assume the role to perform the changes on the hosted zone. However, if you want to be specific you can also opt for creating a specific role per account that is allowed to perform this kind of changes.

```javascript
const role = new Role(this, 'ParentZoneAccountRole', {
    assumedBy: new AccountPrincipal('123456789'),
    roleName: 'dev-HostedZoneDelegationRole',
});
```

For the role name in this example I’ve used the prefix part of the subdomain, but you can of course also use the AWS account id or something that shows for which subdomain the role is meant. To allow the role to change the hosted zone in the networking account a **grant** can be given by means of the **grantDelegation** method on the HostedZone construct.

```javascript
parentHostedZone.grantDelegation(role);
```

This will add the permissions to add or change records of type NS in the parent hosted zone. However, when inspecting policies I found that the IAM permissions were a bit too permissive for my liking. The following code snippet is taken from the AWS CDK v2 source code (at Feb 5th 2024):

```javascript
export function makeGrantDelegation(grantee: iam.IGrantable, hostedZoneArn: string): iam.Grant {
  const g1 = iam.Grant.addToPrincipal({
    grantee,
    actions: ['route53:ChangeResourceRecordSets'],
    resourceArns: [hostedZoneArn],
    conditions: {
      'ForAllValues:StringEquals': {
        'route53:ChangeResourceRecordSetsRecordTypes': ['NS'],
        'route53:ChangeResourceRecordSetsActions': ['UPSERT', 'DELETE'],
      },
    },
  });
  const g2 = iam.Grant.addToPrincipal({
    grantee,
    actions: ['route53:ListHostedZonesByName'],
    resourceArns: ['*'],
  });

  return g1.combine(g2);
}
```

As you can see the role allows all accounts (when used with an OrganizationPrincipal) to assume the role and allows these accounts to update NS records in the parent hosted zone without any strict validation on the subdomain (it does for record type). In my case, I want to limit that to a specific subdomain so that only the dev account can change the NS records in the parent zone for the *dev.exampledomain.com* subdomain and not for instance change the NS records for the *prod.exampledomain.com* subdomain. So how can we achieve this?

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1738788374615/46d1db2f-8e2c-4085-8683-6c4e4a5caba2.jpeg)

## Limiting the delegation scope

To prevent this, a custom IAM policy needs to be created for the role that limits the scope to a specific subdomain.

```javascript
// Validate this can only happen for the dev.exampledomain.com sub-domain
const conditions = {
    'ForAllValues:StringEquals': {
        'route53:ChangeResourceRecordSetsRecordTypes': ['NS'],
        'route53:ChangeResourceRecordSetsActions': ['UPSERT', 'DELETE'],
        'route53:ChangeResourceRecordSetsNormalizedRecordNames': ['dev.exampledomain.com']
    }
};

// Allow the role to perform the GetHostedZone and ChangeResourceRecordSets methods on the recordset for the subdomain.
const recordSetPolicyStatement = new iam.PolicyStatement({
    actions: ["route53:GetHostedZone", "route53:ChangeResourceRecordSets"],
    resources: [parentDomainHostedZone.hostedZoneArn],
    conditions: conditions
});

// Allow the role to list hosted zones by name
const zoneListingPolicyStatement = new iam.PolicyStatement({
    actions: ["route53:ListHostedZonesByName"],
    resources: ["*"]
});

const policyDocument = new iam.PolicyDocument({
    statements: [recordSetPolicyStatement, zoneListingPolicyStatement]
});
```

Now that we’ve set up our policy all we need to do is assign that the IAM role.

```java
// Set explicit inline policies for the 
const role = new Role(this, 'ParentZoneAccountRole', {
    assumedBy: new AccountPrincipal('123456789'),
    roleName: 'dev-HostedZoneDelegationRole',
    inlinePolicies: {
      delegation: policyDocument,
    },
});
```

That it for the work we need to do in the central account. Now let’s move on to what we need to do in the sub account.

## DNS in the sub-account

In the sub accounts (dev, staging, prod) we will need to create a public hosted zone so we can manage subdomains for the applications living in the accounts.

```javascript
const subDomainHostedZone = new PublicHostedZone(this, 'subDomainHostedZone', {
    zoneName: 'dev.exampledomain.com',
});
```

Now that we’ve created the hosted zone we want to publish the NS record information into the central hosted zone, so we can perform the NS record delegation.

```javascript
// construct the ARN for our cross account role
const delegationRoleArn = Stack.of(this).formatArn({
    account: rootAccountId,
    region: '',
    resource: 'role',
    resourceName: 'dev-HostedZoneDelegationRole',
    service: 'iam',
});

// Get the role by ARN
const delegationRole = Role.fromRoleArn(this, 'DelegationRole', delegationRoleArn);

// create a cross account hosted zone delegation record (NS)
new CrossAccountZoneDelegationRecord(this, 'DelegationRecord', {
    delegationRole,
    subDomainHostedZone,
    parentHostedZoneName: 'exampledomain.com',
});
```

The [CrossAccountZoneDelegationRecord](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_route53.CrossAccountZoneDelegationRecord.html) is a [CloudFormation CustomResource](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-customresource.html) that will create assume the role and create the NS records in the hosted zone of the central account based on the NS servers of the hosted zone for the subdomain.

Now that we have the hosted zone in place for the sub-account it should be a matter of some simple lines of CDK code for generating DNS records and certificates for applications.

```javascript
const certificate = new Certificate(this, 'appSubDomainHostedZoneCert', {
    domainName: `applicationname.dev.exampledomain.com`,
    validation: CertificateValidation.fromDns(subDomainHostedZone),
});
```

## Summary

Implementing DNS management in a multi-account setup can be a bit challenging at first if you’ve never done this before. Using of AWS CDK you can add the required constructs that will allow you to perform sub-zone delegation. Limiting down the scope of what the cross-account role can do takes a bit more effort. While writing this post I learned there is an open issue for implementing a similar behaviour for permission limitation registered in the AWS CDK project [https://github.com/aws/aws-cdk/issues/28078](https://github.com/aws/aws-cdk/issues/28078). Let’s hope it becomes part of the CDK, so it will save us some time.

> Photo by [Levi Frey](https://unsplash.com/@levifrey) on [Unsplash](https://unsplash.com/)