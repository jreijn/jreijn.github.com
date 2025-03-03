---
categories:
- Software Engineering
comments: false
date: "2009-04-30T00:00:00Z"
title: Eclipse plugins
---

I've been using <a href="http://www.eclipse.org/">Eclipse</a> as my main IDE the past couple of years. Eclipse by itself is great for Java development, but you can do so much more with it then just that. One of the biggest advantages I think Eclipse has, is that there are so many plugins available for it.

I recently added a couple of new plugins to my default set of Eclipse plugins, which you might like.

## Resource bundle editor
The <a href="http://sourceforge.net/projects/eclipse-rbe/">ResourceBundle editor plugin</a> for eclipse allows you to easily edit the resource bundles in your project. It can give you a very nice overview of all the available values for a key in your resource bundles.

<img  src="http://3.bp.blogspot.com/_hd6Y7yyFK7E/SgiVTBiUYwI/AAAAAAAAANc/LiXkZe_v4UA/s320/screenshot-rbeditor.jpg" alt="" id="BLOGGER_PHOTO_ID_5334677912682783490" border="0" class="img-fluid"/>

## JCR explorer

Recently <a href="https://www.xing.com/profile/Sandro_Boehme">Sandro Boehme</a> was so kind to create a version of his <a href="http://sourceforge.net/project/showfiles.php?group_id=154841">JCR Browser plugin</a> to be able to connect with <a href="http://docs.onehippo.org/">Hippo Repository</a>.
It's a nice Eclipse plugin, which allows you to browse the Hippo JCR repository based on <a href="http://jackrabbit.apache.org/">Apache Jackrabbit</a>. It's a view only plugin, but it can be very useful just to have some insight on what kind of information is in your repository.

<img  src="http://2.bp.blogspot.com/_hd6Y7yyFK7E/SgiSpMYTqeI/AAAAAAAAANU/MmPQaNByK9o/s320/screenshot-jcrexplorer.jpg" alt="" id="BLOGGER_PHOTO_ID_5334674995015821794" border="0" class="img-fluid" />


## Hudson plugin

The <a href="http://code.google.com/p/hudson-eclipse/">Hudson Eclipse plugin</a> ,created by Joakim Recht, allows you to monitor the build status of your projects from within Eclipse.
This plugin allows you to see the current build status and console output. You can also trigger your builds from within Eclipse, which makes it quite a handy little addition to your development environment.
<img class="img-fluid" src="http://4.bp.blogspot.com/_hd6Y7yyFK7E/SgiW2MBdf7I/AAAAAAAAANk/fWJhAWauuZM/s320/screenshot-hudson.jpg" alt="" id="BLOGGER_PHOTO_ID_5334679616304807858" border="0" />

According the the announcement [1] the ResourceBundleEditor is now part of the Eclipse Babel project [2].

But it seems to me that it should be replaced by an online solution [3]. I dont know if you can use that for 'your' projects any more ... I also didn't find the latest update site for the Eclipse plugin.


+ [1] http://sourceforge.net/forum/forum.php?forum_id=762004
+ [2] http://www.eclipse.org/babel/
+ [3] http://www.eclipse.org/babel/messages_editor/
