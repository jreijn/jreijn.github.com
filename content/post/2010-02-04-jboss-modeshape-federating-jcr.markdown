---
categories:
- Software Engineering
comments: true
date: "2010-02-04T00:00:00Z"
title: 'Jboss ModeShape: A federating JCR repository'
---

Some interesting stuff is happing in the JCR community. With <a href="http://jackrabbit.apache.org/">Apache Jackrabbit 2.0.0</a> out (with JCR 2.0) and an interesting project called <a href="http://www.jboss.org/modeshape">Jboss ModeShape</a> almost reaching it's final 1.0 release. ModeShape recently came to my attention and it seems an interesting project. In this post I will give a short introduction of ModeShape and it's features.

## What's ModeShape?
<div class="separator" style="clear: both; text-align: center;"><a href="http://1.bp.blogspot.com/_hd6Y7yyFK7E/TSLZruQyo9I/AAAAAAAAAa8/FItl70uw9cA/s1600/modeshape_icon_64px_med.png" imageanchor="1" style="clear: left; float: left; margin-bottom: 1em; margin-right: 1em;"><img border="0" height="64" src="http://1.bp.blogspot.com/_hd6Y7yyFK7E/TSLZruQyo9I/AAAAAAAAAa8/FItl70uw9cA/s320/modeshape_icon_64px_med.png" width="64" /></a></div>

ModeShape is a Java Content Repository implementation which will support both <a href="http://jcp.org/en/jsr/detail?id=170">JSR-170</a> and <a href="http://jcp.org/en/jsr/detail?id=283">JSR-283</a>. It's not trying to be just another isolated content repository, but a repository with a strong focus on content federation. In other words: ModeShape's main goal is to provide a single JCR interface for accessing and searching content coming from different back-end systems. These systems can even be of different sorts. You might think of a ModeShape repository containing information from a relation database, a file system and perhaps even another Java content repository like for instance <a href="http://www.onehippo.org/">Hippo CMS 7</a>'s content repository. You can configure these sources of information with the help of ModeShapes connector framework.

<h2>Connectors</h2>
One of ModeShape's key concepts is the concept of connectors. A connector will allow you to connect to a certain type of back-end system and transparently expose the information inside the ModeShape repository. In the current 1.0.0 beta release there are already a couple of out of the box connectors available:


<ul><li>In-Memory Connector</li><li>File System Connector</li><li>JPA Connector</li><li>Federation Connector</li><li>Subversion Connector</li><li>JBoss Cache Connector</li><li>Infinispan Connector</li><li>JDBC Metadata Connector </li></ul>
That's already quite a few, but for the upcoming release they also have plans for expanding the set of connectors with for instance a JCR connector, which I find quite interesting myself, because that would allow you to expose other JCR implementations like Hippo CMS 7 (Apache JackRabbit) in combination with other systems through one JCR interface.

<div class="separator" style="clear: both; text-align: center;"><a href="http://3.bp.blogspot.com/_hd6Y7yyFK7E/S2rRrGuaTNI/AAAAAAAAAXw/fFDuXs75Ykc/s1600-h/modeshap-connectors.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" src="http://3.bp.blogspot.com/_hd6Y7yyFK7E/S2rRrGuaTNI/AAAAAAAAAXw/fFDuXs75Ykc/s320/modeshap-connectors.png" /></a></div>There are many other content solutions out there, so if you can't find a connector that suits your need, you can of course write one yourself and perhaps donate it to the ModeShape project.

<h2>Sequencers</h2>
One of ModeShapes other interesting features is the concept of sequencers. With sequencers you can gather additional information from a certain item inside the repository and store that extracted information in the repository. ModeShape has quite a few sequencers out of the box:


<ul><li>Compact Node Type (CND) Sequencer</li><li>XML Document Sequencer</li><li>ZIP File Sequencer</li><li>Microsoft Office Document Sequencer</li><li>Java Source File Sequencer</li><li>Java Class File Sequencer</li><li>Image Sequencer</li><li>MP3 Sequencer</li><li>DDL File Sequencer</li><li>Text Sequencers</li></ul>
The example below is of the ImageSequencer, which can gather information from certain types of images stored inside the repository. The ImageMetaDataSequencer is used here to extract metadata like size, dimensions and so on from the image if they have one of the specified extensions and the extracted information is stored somewhere else inside the repository.

```java
JcrConfiguration config = ...
config.sequencer("Image Sequencer")
.usingClass("org.modeshape.sequencer.image.ImageMetadataSequencer")
.loadedFromClasspath()
.setDescription("Sequences image files to extract the characteristics of the image")
.sequencingFrom("//(*.(jpg|jpeg|gif|bmp|psd)[*])/jcr:content[@jcr:data]")
.andOutputtingTo("/images/$1");
```
## Conclusion
With other mature JCR implementations out there I think ModeShapes strongest point is it's focus on content federation. Providing a single JCR interface for content stored in different systems is a great initiative, because the JCR API is quite easy to learn and to use. I see a bright future for ModeShape, since companies are sharing more and more in-house information on the web these days. I myself will try to keep a close eye on ModeShape and see how it evolves.
