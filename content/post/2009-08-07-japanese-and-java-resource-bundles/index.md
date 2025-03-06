---
comments: true
date: "2009-08-07T00:00:00Z"
title: Japanese and Java resource bundles
---


At <a href="http://www.onehippo.com/">Hippo</a> we have a project, which is build with <a href="http://en.wikipedia.org/wiki/JavaServer_Faces">Java Server Faces</a>, for which I occasionally do some maintenance. A while ago I had an issue in our JIRA bug tracker that reported an error for the Japanese version of the website. The error came from a component that reads information from a resource bundle properties file, which is stored on the local filesystem. In this case from the Japanese version of the resource bundle (ApplicationResource_jp.properties), which is used by the web application to display some Japanese labels.

The error wasn't very clear since it only gave the following exception:

<blockquote>java.util.MissingResourceException:
Can't find resource for bundle java.util.PropertyResourceBundle, key 'somekey'
</blockquote>

Looking in my project, I could clearly see that the resource bundle <span style="font-weight: bold;">was</span> there and after a quick peek at the resource bundle file itself, I could see that the requested key was also present.

After trying some different options I came to the conclusion that my web application was unable to read the actual .properties file from the classpath. By searching some more, I found out that the Java compiler and other Java tools can only process files which contain Latin-1 and/or Unicode-encoded (\udddd notation) characters. Since I was seeing Japanese characters when opening the properties file, it was clearly the case that this file did not meet those requirements.

Solving this issue was quite simple in the end, since the <a href="http://java.sun.com/javase/6/">Sun JDK</a> comes with a utility to help you out with files that contain characters, which are not Latin1. The utility is called: '<a href="http://java.sun.com/javase/6/docs/technotes/tools/windows/native2ascii.html">native2ascii</a>' and can be run from the command-line quite easily by typing:

<code>$ native2ascii [inputfile] [outputfile]</code>

Once I did that the application was working like a charm again!
