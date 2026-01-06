---
categories:
- Software Engineering
comments: true
date: "2009-03-30T00:00:00Z"
title: 'Apache Camel: open source integration framework'
aliases:
- apache-camel-open-source-integration
---

I'm currently working on a project where we are looking at creating an integration layer for external applications to connect to our back-end applications. In our case, one of the back-end applications is <a href="http://docs.onehippo.org/">Hippo CMS 7's</a> repository.
I've been reading up on <a href="http://en.wikipedia.org/wiki/Enterprise_service_bus">ESB</a>'s like <a href="http://servicemix.apache.org/">Apache ServiceMix</a> and <a href="http://synapse.apache.org/">Synapse</a>, but even though both projects look very interesting, they actually are a bit too much for what I want to do.
There was one project though that seems to be exactly what I want: <a href="http://camel.apache.org/">Apache Camel</a>.


### About Apache Camel

Apache Camel is an open source Java framework that focuses on making integration easier. One of the great things is that Camel comes with a lot of default components and connectors.
Even though I was quite new to the integration concept, I was able to get my first Camel project up and running within 30 minutes or so, which I think is quite fast.
You only need is a bit of Java/Spring knowledge to get going.

### The basic concepts

While using an integration framework like Camel, you will have to keep four key terms in mind:
+ **Endpoint**: where the message comes in or leaves the integration layer
+ **Route**: how a message goes from endpoint A to endpoint B
+ **Filter**: the chained components that are involved in the process of handling a message that comes from endpoint A and goes to endpoint B. It could be that the content of the message  needs to be transformed from SOAP to for instance ATOM.
+ **Pipe**: the way the message travels from endpoint A through filters to endpoint B

One of the things I'm looking at Camel for is using it to convert RSS feed entries into JCR nodes. If I would create an endpoint diagram, which would describe my route, it would look something like the image below.

<img style="margin: 0px auto 10px; display: block; text-align: center; cursor: pointer; width: 400px; height: 160px;" src="http://3.bp.blogspot.com/_hd6Y7yyFK7E/SdHfznTRvsI/AAAAAAAAANM/tdaCZzPnCZ8/s400/camel_endpoints.png" alt="" id="BLOGGER_PHOTO_ID_5319278712717426370" border="0" />
With Camel, the endpoints and routes can be configured in a few lines of Java code or with Spring XML configuration. I started out with the Spring XML configuration and it was actually quite easy to get going. Here is an example where I poll my own RSS feed and store the items into a mock 'feeds' object.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:context="http://www.springframework.org/schema/context"
  xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context-2.5.xsd
       http://camel.apache.org/schema/spring
       http://camel.apache.org/schema/spring/camel-spring.xsd">

  <camelContext xmlns="http://camel.apache.org/schema/spring">
    <route>
      <from uri="rss://http://blog.jeroenreijn.com/feeds/posts/default?alt=rss" />
      <to uri="mock:feeds"/>
    </route>
  </camelContext>
</beans>
```

As you can see that's just a couple of lines of code. It's really that simple to do things in Camel. Of course this configuration does not end up in a JCR repository, but as an example I think it's quite easy to grasp. For those of you, that want to play around with Camel as well, I'll try to explain all the step I took to get a working web application example from here on. As I'm using <a href="http://maven.apache.org/">Maven2</a> for building my projects, you should be able to reproduce my setup quite easily.

### Setting up your maven project

First off we'll start with adding the camel dependencies to our maven project descriptor( pom.xml).

``` xml
<dependencies>
  <dependency>
    <groupId>org.apache.camel</groupId>
    <artifactId>camel-core</artifactId>
    <version>${camel-version}</version>
  </dependency>
  <dependency>
    <groupId>org.apache.camel</groupId>
    <artifactId>camel-spring</artifactId>
    <version>${camel-version}</version>
  </dependency>
  <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-core</artifactId>
    <version>${spring-version}</version>
  </dependency>
  <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-web</artifactId>
    <version>${spring-version}</version>
  </dependency>
  <dependency>
    <groupId>org.apache.camel</groupId>
    <artifactId>camel-rss</artifactId>
    <version>${camel-version}</version>
  </dependency>
</dependencies>
```
As you can see I explicitly added the camel-rss component, so that my camel application knows how to handle rss feeds. Camel does not have it's own RSS parser, but is using <a href="https://rome.dev.java.net/">Rome</a> in the background for handling the RSS feeds. The Camel project is setup in such a way that you can include any component you want, by adding the needed component dependency to your pom.xml. If you're thinking about using Camel, make sure you checkout the <a href="http://camel.apache.org/components.html">components page</a>, which shows you all of the currently available components.

Camel uses Spring, so we need to add the Spring ContextLoaderListener to the local web.xml in **src/main/webapp/WEB-INF/**.

```xml

<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/j2ee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd"
  version="2.4">
  <listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
  </listener>
</web-app>
```

The last step in our process is defining our endpoints. In my case I chose to use the Spring XML configuration for defining my endpoints.

Add a file called **applicationContext.xml** to your **src/main/webapp/WEB-INF/** folder.
Once the file is created you should be able to define your routes like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:context="http://www.springframework.org/schema/context"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
  http://www.springframework.org/schema/context
  http://www.springframework.org/schema/context/spring-context-2.5.xsd
  http://camel.apache.org/schema/spring
  http://camel.apache.org/schema/spring/camel-spring.xsd">
  <camelContext xmlns="http://camel.apache.org/schema/spring">
    <route>
      <from uri="rss://http://blog.jeroenreijn.com/feeds/posts/default?alt=rss" />
      <to uri="mock:feeds"/>
    </route>
  </camelContext>
</beans>
```
In this example I'm using my own RSS feed, but you can of course use any feed url you like.
For testing purposes you can add a **log4j.properties** file in **src/main/resources/**, so you can see the output of the Camel RSS component in your console.
Here is the configuration I used writing this blogpost.

```
# The logging properties used for eclipse testing, We want to see debug output on the console.
log4j.rootLogger=INFO, out
log4j.logger.org.apache.camel=DEBUG

# uncomment the following line to turn on ActiveMQ debugging
# log4j.logger.org.springframework=INFO
# CONSOLE appender not used by default
log4j.appender.out=org.apache.log4j.ConsoleAppender
log4j.appender.out.layout=org.apache.log4j.PatternLayout
log4j.appender.out.layout.ConversionPattern=[%30.30t] %-30.30c{1} %-5p %m%n

```
Well that's it. Now the only thing you will need to do is fire up an application container, like Jetty and see what's going on in the console.

```
$ mvn jetty:run
```

If Jetty is running and everything is setup correctly you should be able to see some debug information come by that looks like:

```
SyndFeedImpl.author=noreply@blogger.com (Jeroen Reijn)
SyndFeedImpl.authors=[]
SyndFeedImpl.title=Jeroen Reijn
SyndFeedImpl.description=
SyndFeedImpl.feedType=rss_2.0
SyndFeedImpl.encoding=null
SyndFeedImpl.entries[0].contributors=[]
```

As you will see the RSS feed is parsed and converted into a SyndFeed object.
From there on you can make use of this object and perform any operation on it.

I must admit that while playing around with Camel and RSS feeds, I noticed that the RSS (and Atom) component did not handle extra request parameters correctly, so I added a patch in the Camel JIRA, hoping it wil be included in the next release of Camel.
If you have issues with the RSS component and request parameters, you might want to try to build the Camel SVN trunk and apply my patch (<a href="https://issues.apache.org/activemq/browse/CAMEL-1496">CAMEL-1496</a>).
This is only necessary if you want to parse a feed that has for instance a unique id as request parameter added to the feed URL.

We'll that's it! This post will get a follow-up, where I will show you have to use Camel to actually store the RSS feed entries into a JCR repository.

Here are a couple of good articles too read before starting with Camel:
<ul><li><a href="http://camel.apache.org/">Apache Camel (official website)
</a></li><li><a href="http://architects.dzone.com/articles/apache-camel-integration">Apache Camel: Integration Nirvana</a> (@<a href="http://www.dzone.com/">dzone</a>)
</li><li><a href="http://refcardz.dzone.com/refcardz/enterprise-integration">Camel Reference card (@dzone)</a></li></ul>

This blogpost was inspired by an article over at <a href="http://www.gridshore.nl/">Gridshore</a>, where Jettro  wrote a post on using <a href="http://www.gridshore.nl/2009/03/29/using-spring-integration-for-rss-reading/">Spring Integrations</a> as integration framework. Since I'm pretty much Apache minded, I have been looking around for other open source integration frameworks within the ASF, which brought me to Apache Camel.
