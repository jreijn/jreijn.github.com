---
layout: post
title: "Eclipse plugins"
date: 2009-04-30
comments: false
categories:
 - Tools
---

I've been using <a href="http://www.eclipse.org/">Eclipse</a> as my main IDE the past couple of years. Eclipse by itself is great for Java development, but you can do so much more with it then just that. One of the biggest advantages I think Eclipse has, is that there are so many plugins available for it.

I recently added a couple of new plugins to my default set of Eclipse plugins, which you might like.

<h2>Resource bundle editor</h2>
The <a href="http://sourceforge.net/projects/eclipse-rbe/">ResourceBundle editor plugin</a> for eclipse allows you to easily edit the resource bundles in your project. It can give you a very nice overview of all the available values for a key in your resource bundles.<br /><img style="cursor: pointer; width: 320px; height: 222px;" src="http://3.bp.blogspot.com/_hd6Y7yyFK7E/SgiVTBiUYwI/AAAAAAAAANc/LiXkZe_v4UA/s320/screenshot-rbeditor.jpg" alt="" id="BLOGGER_PHOTO_ID_5334677912682783490" border="0"/>

<h2>JCR explorer</h2>
Recently <a href="https://www.xing.com/profile/Sandro_Boehme">Sandro Boehme</a> was so kind to create a version of his <a href="http://sourceforge.net/project/showfiles.php?group_id=154841">JCR Browser plugin</a> to be able to connect with <a href="http://docs.onehippo.org/">Hippo Repository</a>.<br /><img style="cursor: pointer; width: 320px; height: 240px;" src="http://2.bp.blogspot.com/_hd6Y7yyFK7E/SgiSpMYTqeI/AAAAAAAAANU/MmPQaNByK9o/s320/screenshot-jcrexplorer.jpg" alt="" id="BLOGGER_PHOTO_ID_5334674995015821794" border="0" />
It's a nice Eclipse plugin, which allows you to browse the Hippo JCR repository based on <a href="http://jackrabbit.apache.org/">Apache Jackrabbit</a>. It's a view only plugin, but it can be very usefull just to have some insight on what kind of information is in your repository.

<h2>Hudson plugin</h2>
The <a href="http://code.google.com/p/hudson-eclipse/">Hudson Eclipse plugin</a> ,created by Joakim Recht, allows you to monitor the build status of your projects from within Eclipse.
This plugin allows you to see the current build status and console output. You can also trigger your builds from within Eclipse, which makes it quite a handy little addition to your development environment.
<img style="cursor: pointer; width: 320px; height: 239px;" src="http://4.bp.blogspot.com/_hd6Y7yyFK7E/SgiW2MBdf7I/AAAAAAAAANk/fWJhAWauuZM/s320/screenshot-hudson.jpg" alt="" id="BLOGGER_PHOTO_ID_5334679616304807858" border="0" align="left"/>
<h2>Comments</h2>
<div class='comments'>
<div class='comment'>
<div class='author'>Gautam</div>
<div class='content'>
Resource bundle seems to be pretty good. Good post.</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Thanks for your comment! It seems for now I better stick with the resource bundle editor, because some of the features are not ported yet. It's great too see that there is an effort to support this from within Eclipse itself.</div>
</div>
<div class='comment'>
<div class='author'>janmaterne</div>
<div class='content'>
According the the announcement [1] the ResourceBundleEditor is now part of the Eclipse Babel project [2].<br /><br />But it seems to me that it should be replaced by an online solution [3]. I dont know if you can use that for 'your' projects any more ... I also didnt found the latest update site for the Eclipse plugin.<br /><br /><br />[1] http://sourceforge.net/forum/forum.php?forum_id=762004<br />[2] http://www.eclipse.org/babel/<br />[3] http://www.eclipse.org/babel/messages_editor/</div>
</div>
