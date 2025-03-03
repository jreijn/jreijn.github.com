---
comments: false
date: "2006-07-07T00:00:00Z"
title: Debugging the Hippo CMS GUI framework
---

All user interface components within <a href="http://www.hippocms.org" target="_blank">Hippo CMS 6</a> are handled by a javascript framework, which regulates the interaction between the different views and perspectives within the user interface.
This framework will also handle the AJAX requests to the server for updating all perspectives and views.

I think one of the most unknown and underestimated features within Hippo CMS is the ability to debug this framework.
If you want to create a new view or perspective within the CMS you will have to get a deeper understanding of what is going on in the background.

Ok well I will stop talking and show you guys how to do this! The configuration for the framework can be found in the framework component.xml. Each important component in the CMS has it's own component.xml. (perspectives, framework, workbench).
For the debugger window to appear you will have to modify the following framework attributes:

+ **showLogger**: set this to **true**
+ **logEnabled**: set this to **true**
+ **logLevel**: set this to '**1**' to put this to DEBUG
+ **logger**: this should be the **name** that represents you component in the debug window.

A typical example of the framework component configuration is shown in the next code sample.
{{< highlight xml >}}
  <framework id="framework" showLogger="true"
           undockLogger="false" logEnabled="true"
           logFrame="bottomframe" topFrame="topframe"
           mainFrame="mainframe" logLevel="1"
           logger="framework">

     <remoteCall id="rc" className="RemoteCall"
                 container="top" maxPoolSize="20"
                 wrapper="/workbench/remoteCall">
     </remoteCall>

     <eventManager id="eventmanager" className="EventManager">
     </eventManager>
  </framework>
{{< / highlight >}}

Each perspective has it's own component.xml file, where you can add the logger attribute to display only the messages of that specific perspective.
So did you modify your component? OK! Now refresh the CMS instance in your browser window and you will notice the debug window in the bottom of the page.
You can also detach this window if you want or detach it by default (see the other configuration options in the framework configuration). This debug window should give you enough information on what's going on inside the CMS, why your new view isn't working or what calls are beeing made to the server.

More information on how to handle debugging in Hippo CMS can be found on <a href="http://www.hippocms.org" target="_blank">http://www.hippocms.org</a>.
