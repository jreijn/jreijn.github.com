---
comments: false
date: "2013-02-19T00:00:00Z"
title: Hippo Fridays @ Hippo
---

At Hippo we have a concept we call 'Hippo Fridays'. Hippo Fridays are monthly Fridays on which all Hippo developers can share knowledge, try out new things, work on improvements or hack on their own pet project. We've been having Hippo Fridays for more then a year and even if it's only one day a month, they are always great fun!

The other day while leaving the office I overheard one of my colleagues ask questions about the actual outcome of these Hippo Fridays. Does something end up in the product? Well let me share what has come out of the more recent Hippo Fridays and will end up in the upcoming Hippo CMS 7.8 release.

## HTML5 History API in the CMS and Console

With the upcoming Hippo CMS 7.8 release both CMS and Console will make use of the <a href="https://developer.mozilla.org/en-US/docs/DOM/Manipulating_the_browser_history" target="_blank">HTML5 history API</a>. This might sounds a bit vague and technical, but it means that the CMS and Console will store the URLs to the documents that you visited in your browsers history. By doing that it will allow you to reach them by using your browsers history or by using a direct URL in the browsers address bar. See the address bar in the picture below.

<img border="0" height="361" src="http://2.bp.blogspot.com/-eC3km9I8f1I/UQZADyyTZJI/AAAAAAAAAkE/_tYPm2OiDg0/s640/CapturFiles-20130128_1001.png" width="640" />

## Multiple Console improvements

The more experienced Hippo users will probably notice some new options in the Console menu bar.
The Console UI was improved with some new features to benefit the user experience:

+ deletion of multiple nodes
+ keyboard shortcuts
+ open a node by path or UUID
+ use the arrow keys to navigate the tree

The next image shows you all the keyboard-shortcuts that are available in the Console.

<img border="0" height="444" src="http://3.bp.blogspot.com/-PnfTVdMy4PA/UQZEv3uTtQI/AAAAAAAAAkk/eh6T3t8pVRg/s640/CapturFiles-20130128_1001_2.png" width="640" />

## Scripting support

With the upcoming 7.8 release we will also have scripting support straight from the CMS UI. This feature will be for 'admin' users only. Scripting support is focused on supporting JCR runner / visitors from the CMS UI and helps you do bulk updates of document or just plain JCR nodes. The scripting support in CMS 7.8 was inspired by the introduction of the <a href="http://blog.jeroenreijn.com/2012/05/introducing-hippo-cms-groovy-add-on.html" target="_blank">Hippo CMS Groovy add-on</a>, which started out as a prototype on a Hippo Friday.

<img border="0" height="450" src="http://4.bp.blogspot.com/-2Mj6xmhuZlg/UQZC3NQqxCI/AAAAAAAAAkU/UDvcv67VHGU/s640/CapturFiles-20130128_1001_1.png" width="640" />

## SNEAK PREVIEW: Settings management

This next feature is one of my own pet projects. Those of you who are experienced with Hippo CMS know that Hippo CMS is very flexible and you can configure all most everything. However most of the configuration options are done through the CMS Console.

With the settings management add-on there will be a new user friendly interface and you might even discover some options you never knew existed. Since this is still under heavy development it will <b>not</b> end up in the CMS 7.8 release, but I will keep you posted when a first release is made, so you can try it out.

<img border="0" height="473" src="http://3.bp.blogspot.com/-t23JJ_U5xxc/URoQRna9D5I/AAAAAAAAAk8/SSBrgo9fi5A/s640/hippo-settings-addon.png" width="640" />

As you can see: <b>What happens on Hippo Fridays does not stay on Hippo Fridays!</b>
