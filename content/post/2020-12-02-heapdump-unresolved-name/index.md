---
comments: false
date: "2020-12-02T00:00:00Z"
image: /assets/2020/heap-dump-header.jpg
categories:
- Software Engineering
tags:
- java
title: Heap dump with lots of 'Unresolved Name' objects
aliases:
- heapdump-unresolved-name
---

If you're familiar with Java as a programming language you might have come across the following message: *java.lang.OutOfMemoryError: Java heap space*. We recently got that message in of the services that we're currently working on. 
To better understand why this happens, it's good to get a Java memory heap dump for further analysis.

After parsing the heap dump in both [Eclipse MAT](https://www.eclipse.org/mat/) and [Visual VM](https://visualvm.github.io/) I noticed something strange. My heap dump felt obfuscated and show lots of objects named **'Unresolved Name 0x'**. 

![](/assets/2020/unresolved-name-heapdump.jpg)
*Image describing a similar problem. Not actual heap dump of our project*

I had never seen that before so I tried both memory analyzer applications to see if it had to do with the nightly build of MAT that I needed to use (because of Big Sur). MAT is usually my goto tool for analysing heap dumps, so I was quite surprised as I had not seen this before. Once I noticed both analyzers were showing this I had to look elsewhere for the cause.

The first thing to do of course is to search the great internet, but there were only one or two results that showed something similar. On of the results was [this](https://github.com/elastic/elasticsearch/issues/49699) elasticsearch issue. I noticed I was not the only one that had the issue, but it did not show a solution and they were able to guess what the underlying issue was.

After pondering about it a bit more I had the feeling it had to do something with the JDK and some incompatible export. The project uses Java 12.0.2 and I was also running Java 12.0.2 on my MacBook.

After some further analysis it showed that the service used **AdoptOpenJDK 12.0.2** and when double-checking sdkman I noticed that I was also running Java 12.0.2, but I was running **OpenJDK 12.0.2**. After installing AdoptOpenJDK 12.0.2 and reparsing the heapdump the information was correct and I was able to see which classes and packages were actually taking up heap space.

So, long story short. If you encounter lots of 'Unresolved Name' entities **check your JDK version** on the machine you're trying to analyze the heap dump.

### Notes

In case you want to use a different JVM for Eclipse on your Mac you can make a change  to 

`/Applications/mat.app/Contents/Info.plist`

``` xml
<array>
  <string>-vm</string><string>/Users/jreijn/.sdkman/candidates/java/current/bin/java</string>
</array>
```

If you run into memory issues while trying to parse the heapdump you can increase the MAT JVM heap size by changing the 

`/Applications/mat.app/Contents/Eclipse/MemoryAnalyzer.ini` and changing or adding the `-Xmx4G` parameter.