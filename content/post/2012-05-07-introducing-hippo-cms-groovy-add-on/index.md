---
categories:
- Software Engineering
comments: false
date: "2012-05-07T00:00:00Z"
title: Introducing the Hippo CMS Groovy add-on
---

<img border="0" height="99" src="http://2.bp.blogspot.com/-yzUVGJ0U-Pg/T6eAmpqdYuI/AAAAAAAAAiA/QIGbLjpXaDE/s200/groovy-logo-medium.png" width="200" style="clear: left; float: left; margin-bottom: 1em; margin-right: 1em;" />
A while back I was playing around on some pet project with <a href="http://groovy.codehaus.org/" target="_blank">Groovy</a>.
For those of you that are not familiar with Groovy: Groovy is a dynamic language for the Java Virtual Machine. In other words you can write Groovy (scripts) and keep writing without having to recompile / deploy.
Groovy can integrate with any framework or library out there, so I tried it on Hippo CMS as well.

### A little background

One of the reasons I tried Groovy for Hippo CMS was that I was looking for a different way of executing code against the Hippo repository.
There are different options for executing code against the repository. As you might know you have the option to use UpdaterModules.
I've written about these modules a while back in <a href="http://blog.jeroenreijn.com/2010/06/introduction-to-hippo-cms-7-updater.html" target="_blank">an older blog post</a>.
In short an UpdaterModule allows you to run a piece of Java code at start-up time (when the repository starts) and can execute any command on the low-level JCR API.
This is quite a nice concept, but when you run these updaters the CMS is not usable for users and if you have a large updater it can be down for quite a while.
There is a good reason why this is so and it's very useful for a couple of use-cases.

Next to the UpdaterModules Hippo CMS also has the concept of <a href="https://forge.onehippo.org/gf/project/jcr-runner/" target="_blank">JCR runners</a>. These runners connect through RMI and can be run from the same server to perform large batch operations against a running CMS/Repository. They are really handy, but the downside is that you need to have physical access or SSH access to the machine itself, which you sometimes/mostly do not have.

### The reason for creating the Hippo Groovy plugin

First of all I like Groovy as a language. It's simple, intuitive for Java developers, reduces scaffolding code and you can easily integrate it with your current framework.

My primary objective with creating the Hippo Groovy add-on was creating a CMS plugin that allowed you as a Hippo 'admin' user to for instance:

+ run a dynamic script against the Hippo repository that might get some information
+ update a set of documents
+ query for data and call for instance a the publication workflow for all documents that match this criteria.
+ what ever comes to mind...

And I wanted to be able to do it all from <b>within</b> the CMS interface.

*Note: Of course giving scripting access to users that have 'admin' permissions within the Hippo system can also be quite dangerous, because for instance they can throw away all data if they are not careful with their scripts. I do however believe that the type of users that run these scripts take extra care before executing these scripts.*

### Current status

The Hippo CMS Groovy add-on is now <a href="https://github.com/jreijn/hippo-groovy-addon" target="_blank">a project on Github</a> and is almost ready for it's first release. The first release will contain a CMS add-on that is only shown to users that have the 'admin' role within the CMS.
The features implemented right now are:
<ul><li>Script execution from the CMS UI</li><li>Uploading a script before execution</li><li>Feedback of the script by providing a CMS Wicket model as the 'output' for the script</li><li>Exposing the entire JCR api to scripts based on the current user session</li><li>Syntax highlighting for the Groovy scripts with the <a href="http://codemirror.net/" target="_blank">CodeMirror</a> javascript library</li></ul>

<div class="separator" style="clear: both; text-align: center;"><a href="https://github.com/jreijn/hippo-groovy-addon/raw/master/src/main/resources/scripting.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" height="640" src="https://github.com/jreijn/hippo-groovy-addon/raw/master/src/main/resources/scripting.png" width="619" /></a></div>

### Future plans

For the next couple of releases I have a few plans like:
<ul><li><strike>Groovy script storing inside the repository&nbsp;</strike> (done)</li><li>Scheduled execution of stored scripts</li><li>Perhaps support Groovy syntax in HST (GSP) templates (like for instance <a href="http://www.playframework.org/" target="_blank">Play framework </a>does with Play version 1.2.x)</li>
</ul>

### Contribute

If you like the concept then please fork the project on Github and send in pull requests.
