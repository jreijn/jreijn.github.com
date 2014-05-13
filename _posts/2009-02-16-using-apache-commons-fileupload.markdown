---
layout: post
title: "Using Apache Commons FileUpload"
date: 2009-02-16
comments: false
categories:
 - java
 - Development
 - Open Source
---

<div class='post'>
I'm currently working on a project that required me to upload some files from a JSP driven web application. A quick Google search brought me to <a href="http://commons.apache.org/fileupload/index.html">Apache Commons FileUpload</a>. It's a very useful library, that if used correctly makes you're life a lot easier.<br /><br />Once adding the dependency to my <a href="http://maven.apache.org/">Maven 2</a> pom.xml and looking at the <a href="http://commons.apache.org/fileupload/using.html">user guide</a>, I expected it to work straight away, but unfortunately it didn't and I was not really sure why. My piece of code seemed to halt when trying to execute the following method:<br /><br /><pre name="code" class="java">List items = upload.parseRequest(request);</pre><br /><br />My friend Google was unable to provide me with the correct answer (that's why I'm writing it down now), but after a while I figured out what the problem was. The problem was: <strong>me</strong> not reading the documentation. On that same <a href="http://commons.apache.org/fileupload/using.html">user guide page</a> it states:<br /><br /><blockquote><br />FileUpload depends on Commons IO, so make sure you have the version mentioned on the dependencies page  in your classpath before continuing.</blockquote><br /><br />So in the end it was just another dependency. Not sure why it did not throw an error though, but after adding it to my pom.xml it worked like a charm.</div>
