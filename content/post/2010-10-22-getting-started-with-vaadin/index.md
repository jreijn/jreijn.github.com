---
categories:
- Software Engineering
comments: true
date: "2010-10-22T00:00:00Z"
title: Getting started with Vaadin
---


<a href="http://3.bp.blogspot.com/_hd6Y7yyFK7E/TLd_RYJLjYI/AAAAAAAAAZc/6kONtTl_gy8/s1600/vaadin.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" height="76" src="http://3.bp.blogspot.com/_hd6Y7yyFK7E/TLd_RYJLjYI/AAAAAAAAAZc/6kONtTl_gy8/s320/vaadin.png" width="320" /></a>A couple of weeks ago I made myself a promise that I would look into a new technology every month and write something about it here. I've been looking around for technologies unknown to me and perhaps to some of you, so I will start out with a RIA framework called <a href="http://vaadin.com/home">Vaadin</a>.

## About Vaadin
Before I started my journey with Vaadin, I have to say that I had never heard of it before. I was quite surprised that they were at version 6.4.6 already. That must mean something right? Let's find out.
My first impression is that for an open source framework their documentation is excellent. It's something you don't see everyday with open source frameworks and I've seen quite a few over the past years.
Vaadin really impressed with that and there even is a free (e-)book called '<a href="http://vaadin.com/book">The book of Vaadin</a>', which will get you started and gives you a lot of information about the history of Vaadin, the architecture, the different components bundled with Vaadin and much more.

## The architecture
I don't want to go into to much detail here, since you can find all this information on the Vaadin website, but from an architectural point of view I think these are the key concepts you need to know about Vaadin:

<ul><li>Everything is written in plain Java (no need for HTML templates, like with for instance <a href="http://wicket.apache.org/">Wicket</a>)</li><li>All request processing happens on the server-side</li><li><a href="http://code.google.com/webtoolkit/">GWT</a> is used for the client-side rendering</li><li>Vaadin is more application than page oriented</li><li>Vaadin applications are&nbsp;state-full&nbsp;applications. Everything is stored in the user session.</li><li>You can program with Vaadin, like you would program with Swing or AWT.</li></ul><div>Now let's try to actually start with a small application.</div><h2>Getting started</h2>
There are several ways to get started with Vaadin. Vaadin has it's own <a href="http://vaadin.com/eclipse">plugin for Eclipse</a>, <a href="http://vaadin.com/netbeans">NetBeans</a> and a nice <a href="http://refcardz.dzone.com/refcardz/getting-started-vaadin">DZone refcard</a>, but since I don't use either of those IDE's, I went for the Maven2 way. There are several Maven 2 archetypes available, which you can use from the command line or use from your favorite IDE (IntelliJ in my case).

Now let's create a clean Vaadin application by calling the archetype:

``` bash
mvn archetype:generate \
-DarchetypeGroupId=com.vaadin \
-DarchetypeArtifactId=vaadin-archetype-clean \
-DarchetypeVersion=LATEST \
-DgroupId=com.jeroenreijn \
-DartifactId=vaadin-demo \
-Dversion=1.0-SNAPSHOT \
-Dpackaging=war
```

This will result in a new folder called 'vaadin-demo' and all this folder contains is a pom.xml, a web.xml and a simple HelloWorld Vaadin application. There is nothing more to it than that.

The application class is really small and simple. It just contains some components to get you going. This is what it looks like:

``` java
package com.jeroenreijn;

import com.vaadin.Application;
import com.vaadin.ui.Button;
import com.vaadin.ui.Window;

public class MyVaadinApplication extends Application
{
    private Window window;

    @Override
    public void init()
    {
        window = new Window("My Vaadin Application");
        setMainWindow(window);
        window.addComponent(new Button("Click Me"));
    }
}
```

Now that is nice and small right? The only thing this application does for now is that it creates a Window to put elements on with a default layout. Next to that a button with the label "Click me" is added to this window. It does not do much, but it's enough to get you going.

## What's next?
I don't want to go into a full application in this post, but even after playing around with some more complex things, I have the feeling that I only scratched the surface. I think Vaadin is really interesting if you have to write rich web applications. The framework itself also has an <a href="http://vaadin.com/directory">addon directory</a> filled with interesting and mature add-ons. I have some ideas I want to work out so I will keep you posted with my progress.
