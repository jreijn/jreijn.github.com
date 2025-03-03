---
categories:
- Software Engineering
comments: false
date: "2006-10-17T00:00:00Z"
title: Batik and imagemaps
---

Last week I was working on a project that translates svg to jpeg. Creating jpeg's from svg is pretty easy with the <a href="http://xmlgraphics.apache.org/batik/" target="_blank">Apache Batik SVG toolkit</a>. But the customer needed to be able to link from the svg files to another location, so I had to create html imagemaps from the hyperlinks created from within the svg.

How to start? I did not have any experience with Batik yet, so I had to look around and see if there was something available that would help me out in this task. Well after a while I figured out there was no build-in functionality for imagemaps in Batik yet.

What's next? I was trying Google to see if I could find something about it, because I couldn't imagine I was the only one trying to do this. Well and what do you know! Torsten Knodt <a href="http://www.mail-archive.com/batik-dev@xml.apache.org/msg01764.html" target="_blank">wrote some classes</a> for batik to transcode svg to an imagemap in 2002, but they did not get committed into Batik.

Since they were Apache licensed and on the mailinglist, I was fortunate to be able to use them. I applied the patches to the batik 1.6 version, since it was the version used by Cocoon, and modified the SVGSerializer in Cocoon a bit to get it all working, but it <strong>did work</strong>. It outputs nice imagemap code from the SVG serializer, but there was still another issue to fix.

The coordinates for the hyperlinks were incorrectly positioned on top of the image. Since google was already becoming my best friend I gave it a shot and again in the search archives I found <a href="http://mail-archives.apache.org/mod_mbox/xmlgraphics-batik-users/200303.mbox/%3C3E634505.E6B43148@oracle.com%3E" target="_blank">my answer</a>. It seemed that the jpeg transcoder in batik changed the proportions of the outputted image. That caused my imagemap to have wrong locations for hyperlinks.

In the end I was glad that it was fixed by putting the <strong>"KEY_PIXEL_UNIT_TO_MILLIMETER"</strong> for jpg transcoder used by the SVGSerializer.
