---
comments: false
date: "2006-10-04T00:00:00Z"
title: Running AIGLX on my Latitude D610
---

A couple of days ago I succesfully managed to get AIGLX working on my Dell laptop in Ubuntu Dapper. I started out trying to install <a href="http://en.wikipedia.org/wiki/GLX" target="_blank">GLX</a> a few months ago, but it was quite a strugle and I decided to leave it for now.

Last weekend I found a very solid <a href="http://wiki.beryl-project.org/index.php/Aiglx/compiz_on_an_Intel_i915_video_card" target="_blank">manual</a> for laptops having an onboard Intell videocard. My Latitude contains a videocard that uses the i810 Intell driver, which wasn't supported untill a few weeks ago.

<a href="http://en.wikipedia.org/wiki/AIGLX" target="_blank">AIGLX</a> supports this type of videocard now and after reading some documenten about it I still could not get it working. Searching the <a href="http://www.beryl-project.org/" target="_blank">Beryl</a> (used to be compiz) <a href="http://forum.beryl-project.org/" target="_blank">forums</a> I figured it out. It had to be the Beryl packages which I had to install instead of the deprecated Compiz packages.

If you still have no clue what GLX is, be sure to check out <a href="http://video.google.com/videoplay?docid=4324063604327074565&amp;q=aiglx" target="_blank">this video</a> on GoogleVideo.
