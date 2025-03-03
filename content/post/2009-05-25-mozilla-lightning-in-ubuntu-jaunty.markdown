---
categories:
- Software Engineering
comments: true
date: "2009-05-25T00:00:00Z"
title: Mozilla lightning in Ubuntu Jaunty
---

I just did a fresh install of <a href="http://www.ubuntu.com">Ubuntu Jaunty Jackalope</a>(9.04). After reinstalling Thunderbird (my favorite mail client), I was unable to see my Google calendars with Thunderbirds <a href="https://addons.mozilla.org/en-US/thunderbird/addon/2313">Lightning extension</a>.

The Lightning extension seemed to work, since I saw a calendar, but I was unable to actually add one of my existing calendars.

Google gave me a quick answer, which was located at the <a href="http://ubuntuforums.org/showthread.php?t=1145351">ubuntu forums</a>.

To fix this a couple of simple steps needed to be taken:

First remove the Lightning extension from Thunderbird: Tools->Addons, select Lightning, and uninstall. Close Thunderbird.

Now install libstdc++5:
```
$ sudo apt-get install libstdc++5
```
Now open Thunderbird again, and go back to Tools->Addons. Click the 'Install' button, and browse to the extension file, lightning-0.9-tb-linux.xpi - and open it. At the Software Installation prompt, click 'Install Now' after the short countdown, restart Thunderbird.

Once Thunderbird has been restarting you should be able to add your calendars again.
