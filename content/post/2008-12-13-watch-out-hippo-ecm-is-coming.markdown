---
comments: true
date: "2008-12-13T00:00:00Z"
title: Watch out! Hippo ECM is coming!
---


<p>The past 3 months have been crazy. You might already have read it somewhere on the world wide web, but if you haven't, we're very close too a first official release of our new <a href="http://en.wikipedia.org/wiki/Enterprise_Content_Management">ECM</a> product.</p>

<p>It was September when <a href="http://blogs.hippo.nl/arje/">Arjé</a> did his <a href="http://blogs.hippo.nl/arje/2008/09/announcing_hippo_ecm_and_hippo.html">announcement of Hippo ECM and CMS 7</a> and it has come a long way since. More features have been added and the product has grown a lot since then. Hippo CMS 7 is still in a beta phase, but that won't be for long.</p>

<p>The next couple of weeks I'll try to share my experience, some thoughts and plugins, which I'm in the process of creating. For now I'll go for a short introduction on what's new and how  you can compare it to version six.</p>

<h2>Architecture</h2>
<p>The Hippo ECM architectural model did not change compared to CMS 6/Hippo Repository 1 model, since all components are still decoupled or as I like to describe it: an open architecture.</p>
<p><img alt="architecture-jcr.jpg" src="http://blogs.hippo.nl/reijn/2008/12/11/architecture-jcr.jpg" width="400" align="middle"/></p>
<p>From the inside a lot has changed though. The core of CMS 7 is fully based on <a href="http://wicket.apache.org">Apache Wicket</a>. The team working on CMS 7 have created a Wicket plugin model, which makes CMS 7 a lot more extendible then CMS 6. In my short experience with the plugin model, I have to say I'm very impressed with it's ability. It will  easily allow (other) developers to create their own CMS 7 plugins.</p>
<p>Next to the CMS there is also the content repository, which is now based on <a href="http://jackrabbit.apache.org">Apache Jackrabbit</a>, a reference implementation of the Java Content Repository (JSR-170) standard. The great thing here is that the JSR-170 is well known and accepted by different CM vendors, both open and closed source. With the new upcoming repository we of course added some additional features to the default Jackrabbit repository that would give Hippo users some advantages.I'll talk about this a bit more over the next couple of weeks.</p>
<p>On the front-end side we're also working very hard on some toolkits. Since one of the toolkits (HST2) is still under heavy development I will highlight some features next week. Like with version 6, you won't have to use them, but they can give you some handles to work with. You are still able to choose your own preferred technology, as long as it will be able to talk with the JCR repository.</p>
<h2>The Forge</h2>
<p>If you want to create you're own plugins/components that work or connect with one of the component in the Hippo ECM suite or use plugins made by the Hippo ECM community, we've  created a centralized place to store them: <a href="http://forge.hippo-ecm.org/">The Hippo Forge</a>. I have some ideas myself, which I hope I can realize in the next couple of weeks. I'll keep you posted.</p>
<h2>Documentation</h2>
<p>If you would like to play around with the new system, you can get it from our new <a href="http://docs.onehippo.org">documentation website</a>. Please keep in mind that the product is still in beta phase and so is it's documentation.</p>
<p>Well that's it for now. Keep an eye on <a href="http://planet.hippocms.org">Planet Hippo</a> or subscribe to my feed for more updates.</p>
