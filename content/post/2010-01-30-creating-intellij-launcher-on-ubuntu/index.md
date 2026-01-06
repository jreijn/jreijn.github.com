---
categories:
- Software Engineering
comments: true
date: "2010-01-30T00:00:00Z"
title: Creating an IntelliJ launcher on Ubuntu 9.10
aliases:
- creating-intellij-launcher-on-ubuntu
---

Over the last couple of months I've slowly switched from <a href="http://www.eclipse.org/">Eclipse</a> to <a href="http://www.jetbrains.com/idea/">IntelliJ 9</a> as my main IDE for Java development. After having used Eclipse for more then 5 years I got pointed to IntelliJ by friends from <a href="http://jteam.nl/">JTEAM</a>, that I'm working with at one of my projects. They challenged me to start using IntelliJ, because I would eventually be impressed and would never want to switch back.

As I'm working on my Dell/Linux laptop, I used to start IntelliJ from the command line as instructed in the readme. Starting it from the command line started bugging me after a while, so I wanted to create a launcher for it. Creating a launcher seemed quite simple at first, but getting it to work was something else.

After a while I figured it out that by using the following line in my application launcher:
```
/bin/sh -c "export JDK_HOME=/path/to/java&amp;&amp;/path/to/intellij/bin/idea.sh"
```

I was able to get my IntelliJ launcher to work. As you might notice, you will still have to change the path to your JDK_HOME and IntelliJ installation directory, because they might be different on your own system.
I hope this post can help all of you out there trying to do the same thing.
