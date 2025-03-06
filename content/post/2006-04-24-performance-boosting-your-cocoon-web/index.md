---
comments: false
date: "2006-04-24T00:00:00Z"
title: Performance boosting your Cocoon web application
---

As you might know, the user experience of a web application is very important. Fast request and response times are a <strong>must</strong>! You can do so much with Cocoon that sometimes you don't even know the functionality is there. There is already a lot written about Cocoon performance on the <a href="http://cocoon.apache.org/2.1/performancetips.html" target="_blank">website</a> as well as on the <a href="http://wiki.apache.org/cocoon/CocoonPerformance" target="_blank">wiki</a>, but over the past couple of years I came across a couple of things that could speed up the performance of you Cocoon web application.

Here are a few tips:
<ul>
<li>Be careful with non-caching components inside your caching pipelines (like the request generator).</li>
<li>Be careful with using the resource-exists selector on non-filesystem sources.</li>
<li>Make good use of http headers within your sitemap( like the expires header ) for images, css and javascript. Cocoon is good in processing, but is not fast with sending resources back to the client. Make sure you keep the amount of requests to Cocoon as minimal as possible.</li>
<li>Pick the best XSLT processor in case you need to do a lot of transformations: Saxon or Xalan.</li>
<li>Try to keep the number of pipelines for a request as small as possible. All pipelines will have to be checked for their validity when a request comes in.</li>
</ul>

I hope you'll find these tips useful. Always try to get as much out of you web application as possible!
