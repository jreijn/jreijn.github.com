---
categories: null
comments: false
date: "2006-07-11T00:00:00Z"
title: Javascript debugging in Internet Explorer
---

I guess most web developers feel the same about Javascript debugging in IE. I think it's really hard and it sucks bigtime. I just did not want to start placing alert's all over the place again, to see what was going on. There is just not enough information comming from the browser (by default), about what's really going wrong compared with how Firefox handles Javascript errors. The best Firefox script debugger in my opinion is <a href="http://www.mozilla.org/projects/venkman/" target="_blank">Venkman</a> of course. You should really give it a try.

In IE's alert window, the line number of an exception is almost always incorrect and nowhere to be found. After a frustrating start today, I went searching for what I hoped to be an extensions or something similar to improve IE's functionality.

I found out that there are a couple of them. Microsoft released a new script debugger with their latest Microsoft Office (XP/2003), called 'Microsoft Script Editor'. As an alternative you can also use the '<a href="http://www.microsoft.com/downloads/details.aspx?FamilyID=2f465be0-94fd-4569-b3c4-dffdf19ccd99&DisplayLang=en" target="_blank">Microsoft Script Debugger</a>' which is free to download from the Microsoft website. I never noticed it, but could it get any worse? I gave it a try and it presented me with more useable information of what IE was complaining about, so it made me very happy.

Before using any of these script debuggers you will have to enable debugging in IE.

Go to tools->internet options->advanced. Make sure that “Disable Script Debugging (other)” and “Disable Script Debugging (Internet Explorer) are NOT checked.
