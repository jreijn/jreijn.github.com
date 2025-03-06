---
categories:
- Software Engineering
comments: true
date: "2010-05-24T00:00:00Z"
title: Giving Hippo CMS 7 some WebDAV support
---

A while ago a user on the <a href="http://www.onehippo.org/cms7/support/forums.html">Hippo CMS 7 forum</a> donated a patch, which provided a servlet for simple <a href="http://en.wikipedia.org/wiki/WebDAV">WebDAV</a> support. He donated his code as a proof of concept and hoped that somebody with some deeper knowledge of Hippo and it's nodetypes could pick this up and continue to work on it. Since the patch was left alone for quite some time I picked it up and turned it into a&nbsp;<a href="http://forge.onehippo.org/">Hippo Forge</a>&nbsp;project and called it: '<a href="http://forge.onehippo.org/projects/webdav/">Hippo CMS 7 WebDAV Support</a>'.

Now and then I find some time to work on this project and the current status now is that I have a working quickstart, which you can check out. I personally think it's far from finished, because there is still a lot of work remaining, but it is already usable. In this post I will explain how the WebDAV plugin works, the current status of the project and some future plans. Let's start with some of the basics.

<h2>What is WebDAV?</h2>
WebDAV is short for Web-based Distributed Authoring and Versioning. In short WebDAV is an extension on top of the default HTTP protocol and it allows computer users to edit and store files on a remote server. All the major operating systems provide support for WebDAV and will allow you to easily store and edit files on a remote server as if they were on your own computer.

<h2>Enable WebDAV support for your Hippo CMS 7 project</h2>
Using WebDAV in combination with Hippo CMS 7 is quite easy actually. All you need to do for now is do four things to enable the WebDAV support for your project.

First add the WebDAV support maven dependency to your project

``` xml
<dependency>
  <groupId>org.onehippo.forge.addon.webdav</groupId>
  <artifactId>webdav-addon</artifactId>
  <version>${webdav.addon.version}</version>
</dependency>
```
Second add the WebDAV support servlet definition to your web.xml

``` xml
<servlet>
 <servlet-name>WebDAVServlet</servlet-name>
 <servlet-class>org.onehippo.forge.addon.webdav.HippoWebdavServlet</servlet-class>
 <init-param>
  <param-name>repository-address</param-name>
  <param-value>vm://</param-value>
 </init-param>
 <init-param>
  <param-name>resource-path-prefix</param-name>
  <param-value>/webdav</param-value>
  <description>defines the prefix for spooling resources out of the repository.</description>
 </init-param>
 <init-param>
  <param-name>resource-config</param-name>
  <param-value>/WEB-INF/config.xml</param-value>
  <description>
   Defines various dav-resource configuration parameters.
  </description>
 </init-param>        
 <load-on-startup>5</load-on-startup>
</servlet>
```

Now add the WebDAV servlet mapping to your web.xml
``` xml
<servlet-mapping>
 <servlet-name>WebDAVServlet</servlet-name>
 <url-pattern>/webdav/*</url-pattern>        
</servlet-mapping>
```

And finally add the WebDAV support configuration file to your projects WEB-INF directory.

This configuration file can be found on the WebDAV support <a href="http://webdav.forge.onehippo.org/">documentation site</a>. It's quite easy to read and you should put it into your <b>/webapp/WEB-INF/</b> folder if possible.

<h2>In action</h2>
The following video will show you how easy it is to upload multiple files into the CMS.

<object height="300" width="400"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=11991107&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=11991107&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="400" height="300"></embed></object>
<a href="http://vimeo.com/11991107">Hippo CMS 7 WebDAV support</a> from <a href="http://vimeo.com/user3888132">Jeroen Reijn</a> on <a href="http://vimeo.com/">Vimeo</a>.

This <a href="http://www.youtube.com/watch?v=U0uXPyCn-EI">video</a> is also available on <a href="http://www.youtube.com/watch?v=U0uXPyCn-EI">YouTube</a>.

<h2>Current status</h2>
The current status is that the WebDAV addon has default support for the Hippo <b>assets</b> folder. This was actually quite easy to develop. This can also be used to copy all assets from a CMS 6 instance directly into a running CMS 7 instance. All other folders are not WebDAV enabled yet, but I have some plans for the other folders in the future.

For the short-term roadmap: 'pretty url support' is the first thing I want to work on. I could have put it in hardcoded, but since I want to make it configurable like in the CMS this will my main focus for the next two weeks. If you have ideas or want to help out, please let me know!
