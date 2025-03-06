---
categories:
- Software Engineering
comments: true
date: "2009-06-10T00:00:00Z"
title: 'JCR: Sorting on child node properties'
---


A JCR repository, like <a href="http://jackrabbit.apache.org">Apache Jackrabbit</a> (basis for <a href="http://www.onehippo.org">Hippo CMS 7</a>'s content repository), mainly consists of nodes and properties.
As described in the <a href="http://jcp.org/aboutJava/communityprocess/final/jsr170/index.html">JCR specification</a>, a Java Content Repository should support 2 different query syntaxes: XPath and SQL. Once you get the hang of the syntax, performing a search on a JCR repository is quite easy, but today I came into a situation where I was not able perform the query I wanted. In this post I'll try to describe what my problem was and how the same result can still be achieved.

<h3>The content model</h3>
Let's first start with my content model. The actual node definition for my project looks something like the below:

```
[myproject:metadata]
- myproject:creator (string)
- myproject:language (string)
- myproject:publicationDate (date)
- myproject:availableUntil (date)
- myproject:lastModified (date)
- myproject:keywords (string)
- myproject:contributor (string)

[myproject:news] > hippostd:publishable, hippostd:publishableSummary, hippo:document
- myproject:title (string)
+ myproject:introduction (hippostd:html)
+ myproject:body (hippostd:html)
+ myproject:metadata (myproject:metadata)
```

I came into a situation where I wanted to search for nodes of type '<span style="font-weight:bold;">myproject:news</span>', but sorted on the 'myproject:publicationDate' property of the '<span style="font-weight:bold;">myproject:metadata</span>' subnode. Writing an XPath for such a query is quite easy if you're familiar with the XPath syntax.

Let's start out with a very simple search and just search for nodes of the type '<span style="font-weight:bold;">myproject:news</span>' , which in XPath looks like:

```
//element( *, myproject:news)
```

Now if we would want to order these node types based on for instance the myproject:title property the same XPath query looks like:

```
//element( *, myproject:news) order by @myproject:title descending
```

Now if we would want to sort on the '**myproject:publicationDate**' property of the myproject:metadata subnode, I would expect the same XPath to be:

```
//element( *, myproject:news) order by myproject:metadata/@myproject:publicationDate descending
```

Unfortunately this query did not seem to actually sort the result on the publicatenDate property as I would have expected. I was searching for typos first, but it appeared that the syntax of my query was ok, but it appeared that support for child axis in order by clauses was not yet supported by Jackrabbit itself.

Then I found <a href="https://issues.apache.org/jira/browse/JCR-800">this</a> JIRA issue[1] in the Jackrabbit bugtracker describing this problem and there appears to be a patch available. I'm still wondering how much of a performance impact this might have for large repositories, where you might want to sort on a property of a child node 'n'-levels deep underneath the actual node.

If you want to sort on properties of a specific nodetype, you will have to add the sortable properties to the actual nodetype, which you are searching for and can't put them on a subnode.
It seems that the patch, which should fix this problem, has already been comitted to the Jackrabbit trunk and should be available from Jackrabbit 1.6.0 as marked in the JackRabbit JIRA.
