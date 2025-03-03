---
comments: true
date: "2007-06-01T00:00:00Z"
title: Combining Cocoon and Solr
---

It's been quiet here this month. I've been extremely busy (what else is new) with finishing up old and starting up new projects. One of the exciting new things is that I've been asked to help out with a new project that embraces the power of <a href="http://cocoon.apache.org/" target="_blank">Cocoon</a> (hurrah!).

It's a very nice project with a lot of interesting features. The team is very skilled and they are very enthusiastic about the project. My job for now is to support them in their daily Cocoon development and help them out with solutions for parts of their system.

I'm currently looking at how we can implement faceted navigation and fast searching. The first thing that came to mind was <a title="Lucene" target="_blank" href="http://lucene.apache.org/">Lucene</a> and <a href="http://lucene.apache.org/solr/" target="_blank">Solr</a>. I've heard <a target="_blank" href="http://www.codeconsult.ch/bertrand/">Bertrand</a> talking about Solr so many time that I had to take a look at it. Solr seems to be very powerful,flexible and easy to use. Even for people new to Solr it's easy to setup and play with.

So yesterday I gave Solr a try, to see what we could use it for and it seems to be almost exactly what we need. Cocoon and Solr are in my opinion made for each other since you can do all sorts of XML operations with Cocoon and send and receive these to/from Solr.

While playing around with Solr, I wanted to give it a try from a Cocoon application to see how they would interact. Since you can get results back from Solr by doing an http request it's very easy to integrate this in your Cocoon sitemap. Digging a bit deeper, I stumbled upon a Solr SearchGenerator for Cocoon. Of course that sounded very interesting and I tried it at once. The SearchGenerator is actually very simple and is just a wrapper around an http PostMethod that sends a query to Solr and generates the XML response into the pipeline. Now I had all I needed.

I've even written a small faceted webapp based on the sample content provided in the default Solr checkout. It was fun to write and did not even take me that long. I'll write some more documentation about this and put it online, so other people could also try this out.

So far I really like Solr. Can't wait to spend more time on using it!

Some good links on Solr:

+ <a target="_blank" href="http://www.ibm.com/developerworks/java/library/j-solr1/">Search smarter with Apache Solr, Part 1: Essential features and the Solr schema</a>
+ <a target="_blank" href="http://www.ibm.com/developerworks/library/j-solr2/index.html">Search smarter with Apache Solr, Part 2: Solr for the enterprise</a>
