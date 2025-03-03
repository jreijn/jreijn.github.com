---
comments: true
date: "2009-09-15T00:00:00Z"
title: Apache Cocoon and Javascript minification
---

A couple of days ago somebody on the <a href="http://cocoon.apache.org/">Apache Cocoon</a> user list send a message to the mailing-list about on the fly minification of for instance Javascript files. This topic has been quite popular over the past years, since web application have become richer and Javascript files have become larger.

The ideal situation would be to compres your static files (CSS or Javascript) at build time, so this will not cost you any processing power, when your application is already running. I myself quite often use the <a href="http://maven.apache.org/">Maven 2</a> <a href="http://alchim.sourceforge.net/yuicompressor-maven-plugin/overview.html">YUI compressor plugin</a> while building my projects, but in case you can't use this plugin you could think about a different solution. Since I've been using Cocoon for over more then 5 years, I thought I gave it another try and write a nice Cocoon reader that does this minification for you.

There are multiple minification and obfuscation frameworks out there. One has a greater compression ratio then the other, but for me the most well know ones are probably:
<ol><li><a href="http://shrinksafe.dojotoolkit.org/" target="_blank">Dojo Shrinksafe</a> - Rhino based compressor from the Dojo Toolkit
</li><li><a href="http://developer.yahoo.com/yui/compressor/" target="_blank">YUI Compressor</a> - Rhino based compressor by Yahoo
</li><li><a href="http://www.crockford.com/javascript/jsmin.html">JSMin</a> - a whitespace compressor by Douglas Crockford
</li></ol>Since Apache Cocoon comes with a version of Rhino and both #1 and #2 have their own version of Rhino included, this could end up having nasty conflicts because of two different versions of the library on the same classpath. Therefore I chose to write a reader based on JSMin, which does a lot of whitespace compression for you.

The implementation of this reader was quite simple and if you're interested, you can get the source <a href="http://people.apache.org/%7Ejreijn/sources/java/JavaScriptMinifyReader.java">here</a>. Do keep in mind that you will have to have the JSMin.java file also on the classpath, otherwise it wil not work.
