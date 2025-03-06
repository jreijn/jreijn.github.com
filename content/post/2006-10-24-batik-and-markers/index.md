---
comments: false
date: "2006-10-24T00:00:00Z"
title: Batik and markers
categories:
- Software Engineering
---

Yesterday I stumbled upon another hidden feature of Batik, when I noticed that the Visio diagrams didn't show their arrowheads in the generated jpeg.
It seems this is caused by an inappropriate *markerWidth/Height* and *viewbox*. According to the SVG specification you need to make sure the marker does not overflow it's viewport.

A quick fix for this problem setting the overflow to visible on the marker.

```xml
<marker id="mrkr1-7" class="st2"
        v:arrowType="1" v:arrowSize="2"
        orient="auto" overflow="visible"
        markerUnits="strokeWidth" />
```

<a href="http://marc2.theaimsgroup.com/?l=batik-dev&m=111045831900017&w=2" target="_blank">Thanks to Google and  Thomas DeWeese! </a>
