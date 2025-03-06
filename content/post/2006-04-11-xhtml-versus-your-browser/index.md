---
comments: false
date: "2006-04-11T00:00:00Z"
title: XHTML versus your browser
---

Using XHTML with Cocoon is sometimes a little frustrating. It seems that by using the default XHTML serializer configuration located on the <a href="http://cocoon.apache.org/2.1/userdocs/xhtml-serializer.html" target="_blank">Cocoon Wiki</a> your rendered page is not valid XHTML.
While taking a closer look at the configuration (see below) you will notice that it uses the XMLSerializer as its source.

``` xml
<map:serializer name="xhtml"
     src="org.apache.cocoon.serialization.XMLSerializer"
     mime-type="text/html" logger="sitemap.serializer.xhtml"
     pool-max="64">
  <doctype-public>-//W3C//DTD XHTML 1.0 Strict//EN</doctype-public>
  <doctype-system>http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd</doctype-system>
  <encoding>UTF-8</encoding>
</map:serializer>
```

While the output is XML valid, the browser does not completely seem to understand the requested XHTML.
For example: If you would use a div element that doesn't contain content it would make the browser choke and all the XHTML after that element, would be included in the div element. If you would view the page source, everything seems fine, but the browser does not parse the XHTML correctly because of the closed tag. The page source will show you the closed div tag.

``` xml
<div />
```

The above looks valid in an XML point of view. But the only way the browser likes it, is if you open it and close it again.

``` xml
<div></div>
```

At first I thought it was the browser to blame, but after quick look at the W3C specs it seems that according to the official DTD you are not allowed to create 'empty' div elements or empty textarea elements. With 'empty' they mean ```<div />```. A quick workaround is to put a space inside the empty element. This is not a clean way of fixing things and it could also break the design.

After digging through the Cocoon blocks I found a XHTMLSerializer in the serializers block that did fix this problem. The XHTMLSerializer has an closeElement implementation that leaves certain elements 'open', so the browser will render the page correctly.
This serializer has one disadvantage though: if you use inline Javascript, it will convert all quote characters to &amp;quote;. A quick workaround is to put all your Javascript in to script tags and include them from a remote file.

That leaves me with a choise between two options that are not 100% what I need. For now it seems that I can continue to work with the XHTMLSerializer from the serializers block since I do not have inline Javascript function calls.

<strong>UPDATE</strong>
After reading Arthur's comment ( thanks !! ), I found out that I missed a part of the W3C specs. According to the <a href="http://www.w3.org/TR/2002/NOTE-xhtml-media-types-20020801/#media-types" target="_blank">W3C specs</a> you will also have to provide the correct mime-type for the browser to render it as XHTML. When using XHTML you <strong>must</strong> send <strong>application/xhtml+xml</strong> as the mime-type to the browser and not text/html. After a quick test it seems that FireFox can handle this, but IE 6 can't. I've not been able to test it on IE 7 yet, but let's hope they fixed it.

In the end it still leaves me with the problem that I can't render my XHTML the way I want, without doing any work-arounds for some browsers.
