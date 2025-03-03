---
comments: false
date: "2017-05-10T00:00:00Z"
image: /assets/2023/java-image-snail.jpg
categories:
- Software Engineering
tags:
- java
- spring-boot
title: Fixing the long startup time of my Java application running on macOS Sierra
---

At my current project, we're developing an application based on [Spring Boot](https://projects.spring.io/spring-boot/). During my normal development cycle, I always start the application from within IntelliJ by means of a run configuration that deploys the application to a local Tomcat container.  Spring boot applications can run perfectly fine with an embedded container, but since we deploy the application within a Tomcat container in our acceptance and production environments, I always stick to the same deployment manner on my local machine.

After joining the project in March one thing always kept bugging me. When I started the application with IntelliJ, it always took more than 60 seconds to start the deployed application, which I thought was pretty long given the size of the application. My teammates always said they found it strange as well, but nobody bothered to spend the time to investigate the cause.

Most of us run the entire application and it's dependencies (MongoDB and Elasticsearch) on their laptop and the application requires no remote connections, so I always wondering what the application was doing during those 60+ seconds. Just leveraging the logging framework with the Spring boot application gives you a pretty good insight into what's going on during the launch of the application. In the log file, there were a couple of strange jumps in time that I wanted to investigate further. Let's take a look at a snippet of the log:

``` bash
2017-05-09 23:53:10,293 INFO - Bean 'integrationGlobalProperties' of type [class java.util.Properties] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)
2017-05-09 23:53:15,829 INFO - Cluster created with settings {hosts=[localhost:27017], mode=MULTIPLE, requiredClusterType=UNKNOWN, serverSelectionTimeout='30000 ms', maxWaitQueueSize=500}
2017-05-09 23:53:15,830 INFO - Adding discovered server localhost:27017 to client view of cluster
2017-05-09 23:53:16,432 INFO - No server chosen by WritableServerSelector from cluster description ClusterDescription{type=UNKNOWN, connectionMode=MULTIPLE, serverDescriptions=[ServerDescription{address=localhost:27017, type=UNKNOWN, state=CONNECTING}]}. Waiting for 30000 ms before timing out
2017-05-09 23:53:20,992 INFO - Opened connection [connectionId{localValue:1, serverValue:45}] to localhost:27017
2017-05-09 23:53:20,994 INFO - Monitor thread successfully connected to server with description ServerDescription{address=localhost:27017, type=STANDALONE, state=CONNECTED, ok=true, version=ServerVersion{versionList=[3, 4, 2]}, minWireVersion=0, maxWireVersion=5, maxDocumentSize=16777216, roundTripTimeNanos=457426}
2017-05-09 23:53:20,995 INFO - Discovered cluster type of STANDALONE
2017-05-09 23:53:21,020 INFO - Opened connection [connectionId{localValue:2, serverValue:46}] to localhost:27017
2017-05-09 23:53:21,293 INFO - Checking unique service notification from repository: [text=]
```

Now what's interesting about the above log is that it makes a couple of multi-second jumps. The first jump is after handling the bean 'integrationGlobalProperties'. After about 5 seconds the application logs an entry when it tries to setup a connection to a locally running MongoDB instance. I double checked my settings, but you can see it's really trying to connect to a locally running instance by the log messages stating it tries to connect to 'localhost' on '27017'.
A couple of lines down it makes another jump of about 4 seconds. In that line, it is still trying to set up the proper MongoDB connection. So in it takes about **10 seconds** in total to connect to a locally running (almost empty) MongoDB instance. That can't be right?!

Figuring out what's was going on wasn't that hard. I just took a couple of Thread dumps and a small Google query which led me to [this post](https://youtrack.jetbrains.com/issue/IDEA-161967) on the IntelliJ forum and [this post](http://stackoverflow.com/questions/39636792/jvm-takes-a-long-time-to-resolve-ip-address-for-localhost/39698914#39698914) on StackOverflow. Both posts point out a problem similar to mine: a 'DNS problem' with how 'localhost' was resolved. T he time seems to be spent in **java.net.InetAddress.getLocalHost()**. The writers of both posts have a delay up to 5 minutes or so, which definitely is not workable and would have pushed me to look into this problem instantly. I guess I was 'lucky' it just took a minute on my machine.

Solving the problem is actually quite simple as stated in both posts. All you have to do is make sure that your `/etc/hosts` file also contains the .local domain entry for 'localhost' entries.

While inspecting my hosts file I noticed it did contain both entries for resolving localhost on both IPv4 and IPv6.

```
127.0.0.1 localhost
::1       localhost
```

However, it was missing the .local addresses, so I added those. If you're unsure what your hostname is, you can get it quite easily from a terminal. Just use the **hostname** command:

```$ hostname```

and it should return something like:

```
Jeroens-MacBook-Pro.local
```

In the end, the entries in your host file should look something like:

```
127.0.0.1   localhost Jeroens-MacBook-Pro.local
::1             localhost Jeroens-MacBook-Pro.local
```

Now with this small change applied to my hosts file, the application starts within 19 seconds. That **1/3** of the time it needed before! Not bad for a 30-minute investigation. I wonder if this is related to an upgraded macOS or if it exists on a clean install of macOS Sierra as well. The good thing is that this will apply to other applications as well, not just Java applications.
