---
categories:
- Software Engineering
comments: false
date: "2012-02-09T00:00:00Z"
title: Get in control with Spring Insight!
---

<a href="http://3.bp.blogspot.com/-0PN-ehj_nQ4/TzQz3WID_6I/AAAAAAAAAhU/vMD-iMenY68/s1600/SpringInsight_Logo_black_0.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" height="90" src="http://3.bp.blogspot.com/-0PN-ehj_nQ4/TzQz3WID_6I/AAAAAAAAAhU/vMD-iMenY68/s320/SpringInsight_Logo_black_0.png" width="320" /></a>
Ever wondered what your application was doing? Why that specific page was so slow?
I've asked myself this question numerous times and always had to change some log level or attach a profiler to get actual feedback on what was going on inside my application.

The other day while commuting from home to work, I discovered the <a href="http://www.springsource.org/insight/">Spring Insight project</a>.
From what I've seen so far Spring Insight is a set of inspections (plugins) which are visually displayed in a web application.
To get an idea of what Spring Insight can do for you, be sure to check out the introduction screencast.

<iframe width="640" height="480" src="//www.youtube.com/embed/nBqSh7nVNzc" frameborder="0" allowfullscreen></iframe>

By default Spring Insight comes with a default set of plugins/inspections for different kinds of frameworks/libraries like:

<ul>
<li>Spring Web, Spring core</li>
<li>JDBC</li>
<li>Servlets</li>
<li>Hibernate</li>
<li>Grails</li>
</ul>

There are [more plugins available](https://github.com/SpringSource/spring-insight-plugins/tree/master/collection-plugins) and it's even quite easy to create some of your own and that's what the rest of this post is about.

### Writing your own Spring Insight plugin

Working with Hippo CMS driven web applications every day I had the idea of creating a Spring Insight plugin for the Hippo Site Toolkit (HST in short). The HST consists of a set of components that interact with the Hippo content repository.
During a single request multiple components can be called and for each component there are multiple processing phases.
So my initial idea for the Spring Insight plugin was to show:
<ol>
<li>The amount of time taken for each processing phase of an HST component</li>
<li>The time it takes to perform an <i>HstQuery</i> to the repository</li>
</ol>

Because the default Spring Insight plugins are open source I was able to write my first plugin in about 30 minutes or so.
A large part of those 30 minutes were taken up with learning <a href="http://eclipse.org/aspectj/">AspectsJ</a>, because I'd never used that before.

### Getting started

For this post we will now focus on creating an inspection on performing HST queries.
From the Insight web application view I would like to see the information of an <i>HstQuery</i> and time it took to perform the actual query.
With AspectJ you can pick a join point and inspect for instance the execution of that join point. In our case I would like to inspect the <i>HstQuery.execute()</i> method.
By putting the join point on the <i>HstQuery</i> interface, we've made sure that any object extending the <i>HstQuery</i> will be able to represent it's data within the Insight web application.

Let's first take a look at the what such an inspection looks like.

``` java
package com.jeroenreijn.insight.hst;
import com.springsource.insight.collection.AbstractOperationCollectionAspect;
import com.springsource.insight.intercept.operation.Operation;
import com.springsource.insight.intercept.operation.OperationType;

import org.aspectj.lang.JoinPoint;
import org.hippoecm.hst.content.beans.query.HstQuery;
import org.hippoecm.hst.content.beans.query.HstQueryResult;
import org.hippoecm.hst.content.beans.query.exceptions.QueryException;

/**
 * Aspect for collecting HstQuery executions.
 */
public aspect HstQueryOperationAspect extends AbstractOperationCollectionAspect {

  private static final OperationType TYPE = OperationType.valueOf("query_execute");
  public pointcut collectionPoint(): execution(HstQueryResult HstQuery.execute());

  public Operation createOperation(JoinPoint jp) {
    HstQuery query = (HstQuery) jp.getTarget();
    Operation op = new Operation().type(TYPE).label("HstQuery");
    op.sourceCodeLocation(getSourceCodeLocation(jp));
    try {
      op.put("query", query.getQueryAsString(false));
      op.put("limit", query.getLimit());
      op.put("offset", query.getOffset());
    } catch (QueryException e) {
      // ignore for now
    }
    return op;
  }
}
```

The more important part of the above collection aspect is the <i>collectionPoint</i> poincut, where we define what kind of operation we would like to collect information from.
In this case we define an inspection on the <i>HstQuery.execute()</i> method.
Next to the collection point you will also see the <i>createOperation()</i> method. which allows you to collect certain information from the current state of the collection point.
In the above code snippet we collect the actually <i>HstQuery</i> object and get some information from it like the actual JCR XPath query, the limit set on the query and the offset.
That's all for the information collection part of our plugin.
Now that we've created the aspect for the <i>HstQuery</i>, let's create a view for this inspection.
You can create a freemarker template for each inspection if you want.
For the <i>HstQuery</i> I've created the following template.

```
<#ftl strip_whitespace=true>
<#import "/insight-1.0.ftl" as insight />
<@insight.group label="HST Query">
  <@insight.entry name="Query" value=operation.query />
  <@insight.entry name="Limit" value=operation.limit />
  <@insight.entry name="Offset" value=operation.offset/>
</@insight.group>
```

In the above template we define the values that we've put as attributes on our <i>Operation</i> object.
All we have to do now is wire the operation and the view together inside the plugin configuration.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:insight="http://www.springframework.org/schema/insight-idk"
   xsi:schemaLocation="http://www.springframework.org/schema/beans
   http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
   http://www.springframework.org/schema/insight-idk
   http://www.springframework.org/schema/insight-idk/insight-idk-1.0.xsd">

   <insight:plugin name="hst" version="${project.version}" publisher="Jeroen Reijn" />
   <insight:operation-view operation="query_execute" template="com/jeroenreijn/insight/hst/query.ftl" />
   <insight:operation-group group="Hippo" operation="query_execute" />
</beans>
```

So now that we've finished our plugin, we package it and drop it inside the <i>collection-plugins</i> folder of our Spring Insight instance.
Next we fire up the <a href="http://www.vmware.com/products/vfabric-tcserver/">VMware vFabric TM tc Server</a> and do some requests on the web application that we would like to get some information from.
Once that's done switch the URL in the browser to '/insight' and there is the information collected by Spring Insight.
The image below show exactly the information that we tried to show.

<img border="0" height="355" src="http://3.bp.blogspot.com/-SEC9RgyMLuc/Tp0MlDXYjNI/AAAAAAAAAgA/GOv2q70Opw8/s640/CapturFiles-201110287_1210.png" width="640" style="margin-left: 1em; margin-right: 1em;" />

In this example request you can see from the top of the call stack, the chain of filters that the request went through and all of the HST components.
For each component you can now see the class, the window name (as you can also see in the CMS console) and the render path ( the JSP or Freemarker template) used for rendering the information of the component.
You can also expand an HST component when it contains an <i>HstQuery</i>.
The advantage of having such a plugin might help us identify some slow pages that might have slow JCR queries or components that do extensive (unnecessary) processing.

### Summary

Spring Insight is a very interesting project. Doing a quick scan for troublesome code is relatively fast, but can for now only be done with the VMware vFabric TM  tc Server, so you cannot run it in your personal preferred application container like Tomcat, Jetty or JBoss.
I've personally added Spring Insight to my default set of tools for figuring out performance issues when I need to do a review of a project.

All of the above code and how to install this HST Spring Insight plugin can be found on the <a href="https://github.com/jreijn/insight-plugin-hst" target="_blank">plugin project page on Github</a>.
