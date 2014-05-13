---
layout: post
title: "Large heap dump analysis with Eclipse Memory Analyzer"
date: 2010-10-06
comments: false
categories:
 - java
---

<div class='post'>
Most developers working with Java hardly have to think about the memory footprint of their application that they wrote. The garbage collector inside the JVM will remove most waste, but what happens when not all waste can be removed or something is wrong inside the application? This may result in an exception that probably a lot of developers and system administrators have seen before: <i>java.lang.OutOfMemoryError </i>(OOME)<i>.</i><br />There are several causes for such an exception, but the most obvious is that there is memory leak somewhere in the application.<br /><h2>The situation</h2>At one of my recent projects we were having some memory related issues on one of the production machines. The web application was running in Tomcat 6 and it appeared that at a certain point in time, the JVM tried to allocate twice the average memory it was using. Let's say from 2 Gb the memory footprint went up to 4GB. You might have guessed it, because only a couple of minutes later we were represented with the OOME message in the server log. It turned out that this was related to the amount and type of requests being handled by the application server. I was glad to find out it was <strong>not</strong> a memory leak, but more a warning that the total size of requests could allocate a lot of memory. If your application is running, it's hard to see what objects allocate memory. To get an insight on what the application was doing at the moment the OOME occurred, we configured the JVM to create a memory(heap) dump/snapshot at the moment that the OOME was thrown.<br /><br /><h2>Generating a heap dump</h2>Most of my clients run on the Sun(Oracle) JVM, so I will try to keep this post focussed on the instructions for the Sun JVM. In case your application server runs out of memory you can instruct the JVM to generate a heap dump when an OOME occurs. This heap dump will be generated in the HPROF binary format. <br /><br />You can do this in by:<br /><br /><ol><li>Manually: by using 'jmap', which is available since JDK 1.5.</li><li>Automatically by providing the following JVM command line parameter: <br /><code>-XX:+HeapDumpOnOutOfMemoryError</code></li></ol><br />The size of the heap dump is around the same size as the configured max heap size JVM parameter.<br />So if you have set your max heap size to -Xmx512m , your heap dump will be around that size.  <br /><br /><h2>Analyzing the heap dump</h2>Now you have the heap dump and want to figure out what was inside the heap at the moment the OOME occurred.&nbsp;There are several Java heap dump analyzers out there, where most of them can do more then just heap analysis. The products range from commercial to open source and these are the ones that I tried with my 4Gb .hprof file:<br /><br /><ul><li><a href="http://www.yourkit.com/">Yourkit</a></li><li><a href="http://download.oracle.com/javase/6/docs/technotes/tools/share/jhat.html">jHat</a></li><li><a href="http://www.eclipse.org/mat/">Eclipse Memory Analyzer (MAT)</a></li><li><a href="https://visualvm.dev.java.net/">Visual VM</a></li></ul><br />I was surprised to see that most of the above applications were unable to handle a file of this size. Eclipse Memory Analyzer was actually the only heap dump analyzer that was able to handle a heap dump of this size on my MacBookPro. All the other analyzers were unable to handle a file of this size.&nbsp;Apparently some of these tools tried to load the entire file into memory. On a laptop with only 4 Gb this will not fit.&nbsp;&nbsp;Eclipse MAT was able to analyze this file within 5-10 minutes.<br /><br /><h2>About Eclipse Memory Analyzer</h2><a href="http://www.eclipse.org/mat/home/mat_thumb.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" height="320" src="http://www.eclipse.org/mat/home/mat_thumb.png" width="290" /></a><br />One of the great things about Eclipse Memory Analyzer is that it starts&nbsp;indexing the heapdumps on first load. This makes the processing of the heapdump very fast and once you've parsed the entire heapdump, reopening it is a piece of cake, because it does not have to process it all over again.<br /><br />Once you have the heapdump on your screen the dominator tree view is the most useful view and can give you a very good insight on what was loaded when the server ran out of memory.<br /><br />Next to the statistical views there is also an automatic leak hunter available to help you figure out the problem as fast as possible.<br /><br /><h2>Summary</h2><br />If you ever have to analyze a heap dump I would recommend to use Eclipse Memory Analyzer. It's fast, easy to use and free.</div>
<h2>Comments</h2>
<div class='comments'>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Memory Analyzer comes with some default reports like, Dominator Tree, etc. I would first start with those, since they can lead you into a direction that eventually might help you figure things out.<br /><br />There is no standard sequence of steps to figure out what is going on. You know your application best.</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Hello, I&#39;m running SAP Business Objects 4.0 with Tomcat6..<br /><br />I got a massive .hprof file 9-Gig&#39;s.. I can open this file with Eclipse Memory Analyzer. Had to set my &quot;Xmx&quot; to 6-Gig.. <br /><br />So I can open it, But how do I read it to find the source of the problem...  The issue happens when a particular reports is run, so I know there is an issue with that report/query..  But I&#39;d like to Learn/Use Eclipse Memory Analyzer see the error in the .hprof file..<br /><br />Thanks in advance for any help in learning how to use this tool.<br /><br />Steve</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Hi - I have &gt;2g heap dump file, pls suggest what would be the best place to analyze(like online service upload heap dump file, response should be downloadable report format). I tried from my win xp not enough memory.<br /><br />any help would be greatly appreciated...!</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
I am trying to analyze a heap dump {phd format}, the value of -Xmx parameter is set to 1024mb but when i got the heap dump and opened it in Eclipse Memory Analyzer th e &quot;beggest object by retained size&quot; graph show the total memory of 485mb, where is the rest of the memory.</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
heap dump size depends on your max heap size [ IF you are experiencing a OOM]. your best bet to open a heapdump (hprof or .phd) &gt; 1.5 gigs is to get a 64 bit machine and install a 64 bit JRE AND a 64 bit version of MAT WITH a lot of RAM.<br /><br />I was finally able to open those huge heapdumps &gt; 1.5 g {generated on solaris64bit}<br />on a Windows 64 bit machine with 8gb ram. I started MAT (.ini file) with -Xmx3g.<br /><br />Hope this helps. </div>
</div>
<div class='comment'>
<div class='author'>Arndt</div>
<div class='content'>
Check for the latest version at:<br /><br />http://dr-brenschede.de/bheapsampler/revisions.html<br /><br />There had been problems with parser robustness in the 1.0 version,<br />if with the current version (1.3) you still have problems, please<br />drop me a note per email (see the README for email adress)</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
It does not work: <br />root@ads8-1: ~ # java -Xmx800m -jar bheapsampler.jar memdump<br />BHeapSampler 1.0 / 2011 / Dr. Arndt Brenschede<br />* Sampling from: memdump in pass 0<br />version = JAVA PROFILE 1.0.1 id-size=8 date=Mon May 14 20:23:15 UTC 2012<br />Thread-ID:0<br /><br />tag = heap_dump size=-374919899 date=Mon May 14 20:23:15 UTC 2012<br />heap size:-374919899 date=Mon May 14 20:23:15 UTC 2012<br />tag =  size=-109726256 date=Mon May 14 20:23:15 UTC 2012<br />tag =  size=2041 date=Mon May 14 20:23:15 UTC 2012<br />Exception in thread &quot;main&quot; java.lang.ArrayIndexOutOfBoundsException: -8<br />        at BHeapSampler.a(Unknown Source)<br />        at BHeapSampler.main(Unknown Source)</div>
</div>
<div class='comment'>
<div class='author'>Arndt</div>
<div class='content'>
When analyzing large java heap dumps and trying to do memory leak detection, you should also take a look at BHeapSampler:<br /><br />http://dr-brenschede.de/bheapsampler/<br /><br />You may be amazed by the clarity and simplicity of the infotmation it presents.</div>
</div>
<div class='comment'>
<div class='author'>Eitan Tepper</div>
<div class='content'>
No problem to analyze large heaps with any of the above tools you can see how to do this in the this blog<br />http://performanceandjava.blogspot.com/</div>
</div>
<div class='comment'>
<div class='author'>Prateek</div>
<div class='content'>
Hey,<br />I faced a similar problem with my 2.5 gb heap dump file.<br /><br />This solved my problem.<br />http://wiki.eclipse.org/index.php/MemoryAnalyzer/FAQ#Out_of_Memory_Error_while_Running_the_Memory_Analyzer<br /><br />I allocated 2.7 gb on my system for MAT tool and it worked really fine.</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Hi I&#39;ve only seen this once. It means that if you have configured the Max heap size (Xmx) to 512m, the biggest object tree inside the memory dump is larger then this max size. Try 1 Gb for the Xmx and close all other applications. See if that works out for you.</div>
</div>
<div class='comment'>
<div class='author'>Belfridge</div>
<div class='content'>
Really sorry, Eclipse Memory Analyzer wouldn&#39;t parse my 4G head dump.  Allocated 512mb to the JVM, but it ran out of heap.<br /><br />Admittedly it got further than Netbeans/jhat, but on my 2GB RAM PC, and it seems that it requires less memory - 14% complete used 512MB.<br /><br />Seems stupid that a dump file from a server, can&#39;t be inspected by a developer&#39;s PC.  So annoyed :(</div>
</div>
</div>
