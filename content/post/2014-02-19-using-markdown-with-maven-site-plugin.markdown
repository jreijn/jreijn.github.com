---
categories:
- Software Engineering
comments: false
date: "2014-02-19T00:00:00Z"
summary: I find that generating Maven project documentation is always a bit cumbersome
  with the default XDOC or APT syntaxes. This probably has to do with getting accustomed
  to using Markdown while doing my thing on GitHub.
title: Using Markdown with the Maven site plugin
aliases:
- /2014/02/using-markdown-with-maven-site-plugin
---


I find that generating <a href="http://maven.apache.org/" target="_blank">Maven</a> project documentation is always a bit cumbersome with the default XDOC or APT ("Almost Plain Text") <a href="http://maven.apache.org/doxia/references/index.html" target="_blank">syntaxes</a>. This probably has to do with getting accustomed to using <a href="http://daringfireball.net/projects/markdown/" target="_blank">Markdown</a> while doing <a href="https://github.com/jreijn" target="_blank">my thing on GitHub</a>, which is sort of the de facto standard there.

While writing some documentation for a <a href="http://manage_settings.forge.onehippo.org/" target="_blank">new Hippo CMS plugin</a> the other day I noticed that the maven site plugin already supports the Markdown syntax and it's actually quite easy to setup, but the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">markdown-doxia-module</span> <a href="http://maven.apache.org/doxia/doxia/doxia-modules/doxia-module-markdown/" target="_blank">documentation is a bit limited</a>.
With this post I hope shed some more light and help you get going with using Markdown for writing documentation.

First up we need to define the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">maven-site-plugin</span> in our project <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">pom.xml</span> file. If you start with version 3.3 the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">markdown-doxia-module</span> will already be included. However for this post I will use the latest version ( at this moment 1.5 ), so I have to define it explicitly in my POM file.

``` xml
<plugins>
  <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-site-plugin</artifactId>
    <version>3.3</version>
    <dependencies>
      <dependency>
        <groupId>org.apache.maven.doxia</groupId>
        <artifactId>doxia-module-markdown</artifactId>
        <version>1.5</version>
      </dependency>
    </dependencies>
  </plugin>
</plugins>
```

Next, we will need to create the directory&nbsp; <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">src/site/markdown</span> which will hold our Markdown files. Make sure the files have the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">.md</span> extension.<br /><br />Now let's start with a simple file called <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">index.md</span> that needs to go into the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">markdown</span> folder. To prove that it will render markdown syntax we can use the following snippet as content.

```
A First Level Header
====================
A Second Level Header
---------------------
Now is the time for all good men to come to
the aid of their country. This is just a
regular paragraph.

The quick brown fox jumped over the lazy
dog's back.

### Header 3
> This is a blockquote.>
> This is the second paragraph in the blockquote.
>

## This is an H2 in a blockquote
```

Now start the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">maven-site-plugin</span> from the command-line:

```
$ mvn site:run
```
and point your browser to <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">http://localhost:8080/</span> and see the beautiful result!

A concrete implementation can be <a href="https://forge.onehippo.org/svn/manage_settings/trunk/">found</a> on the Hippo forge.
