---
categories:
- Software Engineering
comments: false
date: "2014-08-05T00:00:00Z"
title: Speeding up your Hippo CMS development with Spring Loaded
---

At [Hippo](http://www.onehippo.com) we use [JRebel](http://zeroturnaround.com/software/jrebel/) a lot during the development of our CMS product. JRebel is a great tool and allows us to do live reloading of source code and enables us to develop the CMS product in a lot less time. The main reason that we use JRebel is that the the CMS suite itself is build from several multi-module Maven projects. JRebel helps limiting the amount of build, aggregate, package and redeploy cycles needed to test the changes and new features which we add to the CMS. For this specific scenario JRebel is excellent and it works really well, but most of the developers I meet are spending time on developing websites with Hippo CMS, which are usually less complex projects. For developers on those kinds of projects getting a JRebel license is usually a thougher challange, but don't worry there are alternatives besides using JRebel that can also help you speed up development.

One of these alternatives is [Spring Loaded](https://github.com/spring-projects/spring-loaded). Spring Loaded is used as the reloading system in [Grails 2](https://grails.org/) based projects. It's battle tested, open source and free to use. In this post I will explain how you can leverage Spring Loaded to implement your Hippo CMS project in less time.

## Some background information

Building a Hippo CMS driven website is usually done with the ``cargo-maven2-plugin`` to deploy the CMS and Site (delivery-tier) application into a by [Cargo](http://cargo.codehaus.org/Home) created Tomcat instance. This makes it simple to use for new users, because you don't have to install an application container first and you only need Java and Maven. Most Hippo CMS projects start from our archetype (i.e. the Essentials or plain archetype). By default this archetype comes with a JRebel profile, which you can leverage if you (or your employer) already have a license. If you don't have a license you will have to build, re-package and run a cargo:redeploy to get the latest changes into the running Tomcat instance. IDE tooling can also help, but has it's limits. Setting it up with your IDE can be less straightforward and time-consuming.

## Getting Spring Loaded

Before we start with adding Spring loaded let's take a look at what Spring Loaded can help us with.

> Spring Loaded is a JVM agent for reloading class file changes whilst a JVM is running. It transforms classes at load time to make them amenable to later reloading. Unlike 'hot code replace' which only allows simple changes once a JVM is running (e.g. changes to method bodies), Spring Loaded allows you to add/modify/delete methods/fields/constructors. The annotations on types/methods/fields/constructors can also be modified and it is possible to add/remove/change values in enum types.

Getting it installed is quite simple. If you're running on Mac OS X and have Homebrew you can just do:

``` bash
$ brew install spring-loaded
```
In case you don't have homebrew installed or are not running OSX you can use ``curl`` or ``wget``.

``` bash
$ curl -O --progress-bar http://search.maven.org/remotecontent?filepath=org/springframework/springloaded/1.2.0.RELEASE/springloaded-1.2.0.RELEASE.jar
```

## Adding Spring Loaded to your Hippo CMS project.

Add a new profile to the root **pom.xml** file, which adds Spring Loaded as the javaagent.

``` xml
<profile>
  <id>springloaded</id>
  <activation>
    <property>
      <name>springloaded</name>
    </property>
  </activation>
  <properties>
    <javaagent>-javaagent:/Users/jreijn/Developer/tools/springloaded/springloaded-1.2.0.RELEASE.jar</javaagent>
  </properties>
</profile>
```

Make sure you change the path to the location in which you stored the Spring loaded .jar file.

Now if you start your project with both the cargo and the springloaded profile it will attach Spring Loaded as the agent to the JVM that starts Tomcat.

``` bash
$ mvn -Pcargo.run,springloaded
```

Now the next step in this process is to create a context.xml file for the site application that allows us to point to our build path(s), so that Spring Loaded and Tomcat can detect the new packaged templates (JSP's) and new and changed Java classes. To do so we can create a file called context-site.xml and use the [VirtualWebappLoader](http://tomcat.apache.org/tomcat-7.0-doc/config/loader.html) to point to our maven build directory.

site-context.xml

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<Context path="/site" docBase="${project.basedir}/site/target/site">

  <Loader className="org.apache.catalina.loader.VirtualWebappLoader" searchVirtualFirst="true"
          virtualClasspath="${project.basedir}/site/target/classes" />

  <!-- In case you want to reload other files as well you can uncomment the following section -->
  <!--  <Resources className="org.apache.naming.resources.VirtualDirContext"
             extraResourcePaths="/=${project.basedir}/site/src/main/webapp" />
   -->

</Context>
```

As you can see, there are some placeholders in this XML file for which we will let the ``maven-resources-plugin`` replace before Cargo starts our Tomcat container. For that we add the ``maven-resources-plugin`` to the existing **cargo.run** profile in the root **pom.xml** file.

``` xml
<profile>
  <id>cargo.run</id>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-resources-plugin</artifactId>
        <executions>
          <execution>
            <id>copy-tomcat-resources</id>
            <phase>validate</phase>
            <goals>
              <goal>copy-resources</goal>
            </goals>
            <configuration>
              <outputDirectory>${project.build.directory}/contexts</outputDirectory>
              <resources>
                <resource>
                  <directory>conf</directory>
                  <includes>
                    <include>*-context.xml</include>
                  </includes>
                  <filtering>true</filtering>
                </resource>
              </resources>
            </configuration>
          </execution>
        </executions>
      </plugin>
      ...
    </plugins>
  </build>
</profile>
```

The last step in this process is to copy the XML file that results from the above step into the Tomcat installation. We can do this by adding a ``configfile`` to the existing ``cargo-maven2-plugin`` configuration section in the root **pom.xml** file.

``` xml
<plugin>
  <groupId>org.codehaus.cargo</groupId>
  <artifactId>cargo-maven2-plugin</artifactId>
  <configuration>
    <configuration>
      <configfiles>
        <configfile>
          <file>${project.build.directory}/contexts/site-context.xml</file>
          <todir>conf/Catalina/localhost/</todir>
          <tofile>site.xml</tofile>
        </configfile>
      </configfiles>
    </configuration>
  </configuration>
</plugin>
```

Now these are actually the only changes required to get started with Spring Loaded and seeing live changes without package and deployment cycles. If you change a JSP or class file from now on, all you need to do is compile and package the change from within your IDE. Within IntelliJ you can do this by just pressing CMD + SHIFT + F9.

This video shows all the steps we've done above from beginning till end and shows you a working end result.

<iframe width="853" height="480" src="//www.youtube.com/embed/VBwxFzbjdKo" allowfullscreen></iframe>

## Current limitations

I've noticed that if you compare Spring Loaded with JRebel it's still pretty young with regards to plugins for particular frameworks. Also Spring Loaded [does not yet support multi-module Maven projects](https://github.com/spring-projects/spring-loaded/issues/70). I guess this is mainly becase Grails 2 based projects do not make use of a multi-module project setup, but all the code is in one source section. In our case it can handle the classes within the webapp ``WEB-INF/classes`` directory really well, but it will not detect changes made in .jar files or other modules in the project. If your Hippo CMS project isn't that large then this is no problem. If you just stick to keeping your Java source files within your ``site`` or ``cms`` project module you should be fine and Spring Loaded is a definitly a very promising alternative. Now since it's open source and I see more people paying attention to Spring Loaded I would not be suprised if multi-module support would be added any time soon.

You can find the end result of the above project setup (after you've installed Spring Loaded and changed the path accordingly of course) in my [example GitHub repository](https://github.com/jreijn/hippocms-spring-loaded).
