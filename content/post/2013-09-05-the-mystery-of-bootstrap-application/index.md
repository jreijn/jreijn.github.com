---
categories:
- Software Engineering
comments: false
date: "2013-09-05T00:00:00Z"
summary: While developing Java based web application with Tomcat I always get nagged
  with an application called 'Bootstrap' popup up in my dock and taking over the focus
  from what I'm doing.
title: The mystery of the Bootstrap application
aliases:
- the-mystery-of-bootstrap-application
---

In my day to day job I'm a Java coder working on a MacBook Pro running OS X (Mountain Lion) and recently one thing started to really annoy me. While performing an <a href="http://maven.apache.org/" target="_blank">Apache Maven</a> build cycle occasionally an application pops up in my OS X dock and while browsing the web or composing an e-mail the focus is lost and moves to the just started application. In my case these applications are most of the time called <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">Bootstrap</span> or <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">ForkedBooter</span>.

I asked around a little if any of my fellow coders experienced this as well and it seems so, but nobody took the time to figure out what was going on. The answers are out there on the web, but you really need to know what to search for before finding a proper answer.

### ForkedBooter

If you see the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">ForkedBooter</span> application pop up in your dock this is most likely due to the <a href="http://maven.apache.org/surefire/maven-surefire-plugin/index.html" target="_blank">maven-surefire-plugin</a> which is being executed during the test phase of the Maven build lifecycle.

It's actually quite easy to get rid of this application popping up in the OS X dock by telling Maven to run Java in headless mode. To do so I've added the following line to my <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">.bash_profile</span> file stored in my users home directory. In my case this is located in <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">/Users/jreijn</span>.

``` bash
export MAVEN_OPTS="-Xms256m -Xmx512m -XX:PermSize=64m -XX:MaxPermSize=256m -Djava.awt.headless=true"
```
By adding the headless directive it will tell Maven and the plugins (which embrace the MAVEN_OPTS) to run Java in headless mode.

This should resolve the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">ForkedBooter</span> popping up in the OS X dock.

### Bootstrap
The <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">Bootstrap</span> application showing up in the dock is actually quite specific and originates from starting up Apache Tomcat somewhere during the Maven build. In my specific case this was because at <a href="http://www.onehippo.com/" target="_blank">Hippo</a> we use the <a href="http://cargo.codehaus.org/Maven2+plugin" target="_blank">cargo-maven2-plugin</a> to fire up Apache Tomcat to run the CMS and site web application inside a Tomcat instance.

There are several ways of solving this. One of the possible options I found was to change Tomcats&nbsp; <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">conf/catalina.properties</span> file and add the following line at the end of the file.

```
java.awt.headless=true
```

When using a standalone Tomcat instance this way of solving is fine, but you could also add this to the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">catalina.sh</span> or the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">startup.sh</span> scripts.<br /><br />Now in the scenario of using the Maven cargo plugin the container might be reinstalled on every build and this will overwrite your changes. There are two (or more) approaches again to solve this problem.

The first approach would be to add the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">catalina.properties</span> file to your local project and copy it over when cargo installs the container.

``` xml
<build>
  <plugins>
    <plugin>
      <groupId>org.codehaus.cargo</groupId>
      <artifactId>cargo-maven2-plugin</artifactId>
      <configuration>
        <configuration>
          <configfiles>
            <configfile>
              <file>${project.basedir}/conf/catalina.properties</file>
              <todir>conf/</todir>
              <tofile>catalina.properties</tofile>
            </configfile>
          </configfiles>
        </configuration>
      </configuration>
    </plugin>
  </plugins>
</build>
```

The problem with this approach is that you will have a local copy inside your project which you have to recheck when upgrading the cargo plugin or the container instance or it might not work when switching to a different container then Tomcat.

The other more simple approach which will work across multiple containers is by adding a system property to the cargo plugin.

``` xml
<build>
  <plugins>
    <plugin>
      <groupId>org.codehaus.cargo</groupId>
      <artifactId>cargo-maven2-plugin</artifactId>
      <configuration>
        <container>
          <systemProperties>
            <java.awt.headless>true</java.awt.headless>
          </systemProperties>
        </container>
      </configuration>
    </plugin>
  </plugins>
</build>
```

This way the system property is added to the Java run-time when starting up Tomcat from cargo and the <span style="font-family: &quot;Courier New&quot;,Courier,monospace;">Bootstrap</span> application does not pop up anymore inside the OS X dock.

I hope this post will help those of you in search for the same answers and could not find it.

### References

+ <a href="http://stackoverflow.com/questions/8189635/any-idea-why-org-apache-catalina-startup-bootstrap-pops-up-in-dock-on-mac" target="_blank">Stack overflow: Any idea why org.apache.catalina.startup.Bootstrap pops up in dock on Mac?</a>
+ <a href="https://issues.jenkins-ci.org/browse/JENKINS-9785" target="_blank">Jenkins JIRA: on OSX a java icon jump on dock for all starting maven build and takes focus</a>
