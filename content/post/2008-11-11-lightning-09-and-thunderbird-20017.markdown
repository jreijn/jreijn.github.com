---
comments: true
date: "2008-11-11T00:00:00Z"
title: Lightning 0.9 and Thunderbird 2.0.0.17
---

After doing a clean install of<a href="http://www.ubuntu.com"> Ubuntu Intrepid</a> last night (which went quite smooth as expected), almost everything kept working, except the combination of <a href="http://www.mozilla.com/en-US/thunderbird/">Mozilla Thunderbird</a> and <a href="http://www.mozilla.org/projects/calendar/lightning/">Lightning</a>.
I've been using this combination for a while now, since I was looking for a good replacement for my calendar software. I think it's a killer combination with the Google Calendar functionality.

At first I was unable to figure out, what might be the cause of my problems, but digging a bit deeper I found out that Thunderbird can help you out with this, by means of the error console.
Try adding '-console' to the startup parameters to enable the error console in Thunderbird. Once Thunderbird is started you can find the console under 'Tools' in the menu.
The actual errors pointed me to <a href="https://bugs.launchpad.net/ubuntu/+source/thunderbird/+bug/278853">this launchpad page</a>. The bug described the same behavior I was having.
I was unable to create a Calendar and the Lightning interface looked a bit broken at some places.
Scrolling down to the bottom of the bug report, others seemed to have found a solution, which was actually quite simple. You need to install libstdc++5 separately. You can do this with aptitude or any other package manager.
```
$ sudo aptitude install libstdc++5
```
Afterwards you will need to reinstall the Lightning add-on and everything should be back to normal!
