---
categories:
- Software Engineering
comments: true
date: "2007-10-25T00:00:00Z"
title: Updating Ubuntu to 7.10
---

A couple of days ago I tried to update Ubuntu 7.04 <a href="https://wiki.ubuntu.com/FeistyFawn" target="_blank">(Feisty</a>) to 7.10 (<a href="https://wiki.ubuntu.com/GutsyGibbon" target="_blank">Gutsy</a>). I was excepting another flawless upgrade after my experience with upgrading Ubuntu before from 6.06 to 7.04. Unfortunately this was not the case. During the installation I had a couple of errors and almost at the end my installation even crashed. As a complete novice on this level, what were going to be the consequences?

I first tried to use the synaptic package manager to see if an update could help. It seems my index was somehow broken and could be fixed with:
```
$ sudo apt-get install -f
```

After that I did another update and all packages seemed to install properly.

The next problem I had was that after the initial boot my xorg.conf somehow seemed to be broken. I only got a black screen and nothing else.

Creating a new xorg.conf seemed to fix it.
```
$  sudo dpkg-reconfigure -phigh xserver-xorg
```
After that I had a running environment again. The video performance still seemed quite slow especially when browsing webpages. My Dell integrated Intell video card seemed to be the problem. On one of the ubuntu forums I found a hint that told me to create a file called 'disable' for the xgl-xserver.

Create the following file:
```
$ vi ~/.config/xserver-xgl/disable
```
After another reboot it seemed to solve all my problems. It even looked like it was running smoother then before. I'm a happy Ubuntu user again. Let's hope things work out a bit better next time.
