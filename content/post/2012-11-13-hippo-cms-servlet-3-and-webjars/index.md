---
categories:
- Software Engineering
tags:
- java
comments: false
date: "2012-11-13T00:00:00Z"
title: Hippo CMS, Servlet 3 and WebJars
---

Besides my work at <a href="http://www.onhippo.com/" target="_blank">Hippo</a> I'm quite a fan of <a href="http://www.playframework.org/" target="_blank">Play framework</a>.
My first introduction to Play framework was back in 2011 just around the time I was about to attend <a href="http://www.devoxx.com/" target="_blank">Devoxx</a>.
Because of this I attended a talk at Devoxx by <a href="http://www.jamesward.com/" target="_blank">James Ward</a> about <a href="http://www.devoxx.com/pages/viewpage.action?pageId=5015973">Deploying Java &amp; Play Framework Apps to the Cloud</a>.
I've been following James on Twitter since that day because he was playing around with quite some interesting technologies.
Recently I noticed James <a href="http://www.jamesward.com/2012/10/31/webjars-officially-launched" target="_blank">introduced</a> an interesting project called <a href="http://www.webjars.org/" target="_blank">WebJars</a>.

### What are WebJars?

In most Java projects a dependency management system is used like <a href="http://maven.apache.org/" target="_blank">Maven</a>, <a href="http://ant.apache.org/ivy/" target="_blank">Ivy</a> or <a href="http://www.gradle.org/" target="_blank">Gradle</a>.
Having dependency management setup for server-side dependencies is quite natural, but what about client-side dependencies? This is where WebJars can help out.

WebJars are client-side web libraries packaged into JAR files. This is very useful for maintaining a web application.
By using dependency management also for client-side libraries helps you find out easily which version of a dependency is being used in a project.
This can be really helpful since not all web libraries have versions in their file names.

Another advantage of using dependency management is that you will get transitive dependencies for free.
For instance if you want to use <a href="http://twitter.github.com/bootstrap/" target="_blank">Twitter Bootstrap</a> 2.2.1 as a WebJar you will also get <a href="http://jquery.org/" target="_blank">jQuery</a> 1.8.2.
That's really helpful!

So let's see what we need to do if we want to use WebJars in for instance a Hippo CMS project.

### Getting started with&nbsp; Hippo CMS and WebJars.

Let's first <a href="http://www.onehippo.org/7_7/trails/developer-trail/hippo-baby-steps" target="_blank">generate a new Hippo project</a>. The following maven command will generate a Hippo CMS 7.7.6 project from the Hippo Archetype.

``` bash
mvn archetype:generate
    -DarchetypeRepository=http://maven.onehippo.com/maven2
    -DarchetypeGroupId=org.onehippo.cms7
    -DarchetypeArtifactId=hippo-archetype-website
    -DarchetypeVersion=1.05.08
```

Once this is finished you should have a project that looks similar to this:

```
drwxr-xr-x  11 jreijn  staff   374  9 nov 13:47 .
drwxr-xr-x  46 jreijn  staff  1564  9 nov 11:30 ..
-rw-r--r--   1 jreijn  staff  1677  9 nov 11:30 README.txt
drwxr-xr-x   6 jreijn  staff   204  9 nov 13:47 cms
drwxr-xr-x   6 jreijn  staff   204  9 nov 11:30 conf
drwxr-xr-x   5 jreijn  staff   170  9 nov 13:47 content
-rw-r--r--   1 jreijn  staff  9006  9 nov 11:57 pom.xml
drwxr-xr-x   5 jreijn  staff   170  9 nov 13:47 site
drwxr-xr-x   3 jreijn  staff   102  9 nov 11:30 src
```

Before we proceed there is one little catch. To be able to use WebJars within a Hippo project we need to run on a Servlet 3 container.
By default the Hippo archetype packages Apache Tomcat 6, but Tomcat 6 supports Servlet 2.5 and not Servlet 3.
Tomcat 7 however does support Servlet 3, so with some minimal changes we can run our Hippo project with Tomcat 7 for our local development environment.

The reason why we need a Servlet 3 container is that with any Servlet 3 compatible container anything in a <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">META-INF/resources</span> directory in a JAR file located in the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">WEB-INF/lib</span> directory is automatically exposed as a static resource.

The Hippo archetype runs with the maven cargo plugin. By default the cargo configuration is handled by the parent pom, which is out of the projects code, but it's easy to change this by just adding some additional properties in the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;"><properties></span> section of our projects <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">pom.xml</span> file.

``` xml
<properties>
  <cargo.tomcat.major.version>7</cargo.tomcat.major.version>
  <cargo.tomcat.full.version>7.0.32</cargo.tomcat.full.version>
</properties>
```

Now to be able to use for instance the Twitter Bootstrap WebJar all we need to do is add the following dependency to our <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">site/pom.xml</span> file within the dependencies section.&nbsp;

``` xml
<dependency>
  <groupId>org.webjars</groupId>
  <artifactId>bootstrap</artifactId>
  <version>2.2.1</version>
</dependency>
```

As I've mentioned before jQuery will also be fetched since it's a transitive dependency of Bootstrap.
Now if we want to use it all we need to do is change for instance the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">webpage.jsp</span> that gets bundled with the default archetype. So all we need to do is insert the following snippet:

``` xml
<hst:link var="bootstrapCssLink" path="/webjars/bootstrap/2.2.1/css/bootstrap.min.css"/>
<link rel="stylesheet" href="${bootstrapCssLink}" type="text/css"/>
```

And that's it. Now let's package our project and start the Hippo CMS instance:

``` bash
$ mvn clean package && mvn -Pcargo.run
```

Now all we need to do is open up a browser and point it to the website: <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">http://localhost:8080/site/</span> and you should see the Bootstrap CSS theme kicking in.<br /><br />Of course Bootstrap and jQuery are not the only available frameworks. The WebJars website already counts about 40 different WebJars. For more information and documentation make sure to check out the official <a href="http://www.webjars.org/" target="_blank">WebJars website</a>.
