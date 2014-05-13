---
layout: post
title: "Creating an IntelliJ launcher on Ubuntu 9.10"
date: 2010-01-30
comments: false
categories:
 - ubuntu
---

<div class='post'>
Over the last couple of months I've slowly switched from <a href="http://www.eclipse.org/">Eclipse</a> to <a href="http://www.jetbrains.com/idea/">IntelliJ 9</a> as my main IDE for Java development. After having used Eclipse for more then 5 years I got pointed to IntelliJ by friends from <a href="http://jteam.nl/">JTEAM</a>, that I'm working with at one of my projects. They challenged me to start using IntelliJ, because I would eventually be impressed and would never want to switch back.<br /><br />As I'm working on my Dell/Linux laptop, I used to start IntelliJ from the command line as instructed in the readme. Starting it from the command line started bugging me after a while, so I wanted to create a launcher for it. Creating a launcher seemed quite simple at first, but getting it to work was something else.<br /><br />After a while I figured it out that by using the following line in my application launcher:<br /><span class="Apple-style-span" style="font-family: monospace;"><span class="Apple-style-span" style="font-family: Times;"><br /></span></span><br /><code> /bin/sh -c "export JDK_HOME=/path/to/java&amp;&amp;/path/to/intellij/bin/idea.sh"<br /></code><br /><br />I was able to get my IntelliJ launcher to work. As you might notice, you will still have to change the path to your JDK_HOME and IntelliJ installation directory, because they might be different on your own system.<br />I hope this post can help all of you out there trying to do the same thing.</div>
<h2>Comments</h2>
<div class='comments'>
<div class='comment'>
<div class='author'>amindri</div>
<div class='content'>
thank you very much!!! worked like a charm :)</div>
</div>
<div class='comment'>
<div class='author'>anet</div>
<div class='content'>
Thank you very much!!!!!!!!!!!!!!!!!!!</div>
</div>
<div class='comment'>
<div class='author'>johnrellis</div>
<div class='content'>
Thanks! :)</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
THANKS!!!!!!!!!!</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Hi, I created a custom application launcher and gave the input for the command option in launcher properties as: /bin/sh -c &quot;export JDK_HOME=/home/hasini/Setupfiles/jdk1.6.0_21&amp;&amp;/home/hasini/Software/idea-IC-93.94/bin/idea.sh&quot;<br /><br />But the launcher doesn&#39;t launch IDEA or doesn&#39;t even give any error.<br /><br />Any help would be really appriciated.<br />Thanks,<br />Hasini.</div>
</div>
<div class='comment'>
<div class='author'>robvdlv</div>
<div class='content'>
Hi, how you doing? :)<br />Alternatively, expose java on your path for the gnome session: http://robvdlindenvooren.wordpress.com/2010/02/28/ubuntu-karmic-koala-notes-to-self/</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
You can also use bash -l to get your environment variables as if you had logged into a terminal:<br /><br />bash -l path/to/rubymine/bin/rubmine.sh <br /><br />Works for me and takes away that dependency on the JDK_HOME.</div>
</div>
<div class='comment'>
<div class='author'>ikarius</div>
<div class='content'>
So cool thanks a lot :)</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
merci bien.</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Thank you ! It works for RubyMine as well, as one would expect.</div>
</div>
<div class='comment'>
<div class='author'>Gabriel</div>
<div class='content'>
Thank you VERY much. What a pain it&#39;s been to get this launcher working! Idea is awesome, I&#39;m glad to have found a easier way to launch it every day.</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
It helped - thank you.</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Thank you very much for the post.</div>
</div>
</div>
