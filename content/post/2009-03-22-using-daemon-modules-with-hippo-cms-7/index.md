---
categories:
- Software Engineering
comments: true
date: "2009-03-22T00:00:00Z"
title: Using Daemon modules with Hippo CMS 7
---

Recently I was working on a new <a href="http://www.onehippo.org/cms7/">Hippo CMS 7</a> based project, where I was in need of a repository component that could run in the background and perform some scheduled tasks.
While talking to some colleagues about what I had to do, they pointed me to a build-in solution for adding repository components, which are initiated at startup.
It was actually very simple to implement this feature, so I'll try to describe how you can achieve the same solution in some very small steps.

The first thing you will need to do is create a Java class that implements the **DaemonModule** interface. As an example I've created the **BackgroundModule** as shown below. <br /><br />

``` java
package com.example.repository;
import javax.jcr.RepositoryException;
import javax.jcr.Session;
import org.hippoecm.repository.ext.DaemonModule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BackgroundModule implements DaemonModule{
    static final Logger log = LoggerFactory.getLogger(BackgroundModule.class);
    static Session session = null;

    public void initialize(Session session) throws RepositoryException {
        this.session = session;
        log.info("BackgroundModule started");
    }

    public void shutdown() {
      session.logout();
    }
}
```

You might wonder how the repository knows about these daemon modules? Well the trick is that the repository goes through all '**MANIFEST.MF**' files, which it can find on the classpath.
If the MANIFEST.MF file contains an entry for the property '**Hippo-Modules**', it will be added to the list of available modules. Once finished finding all modules it will start to initialize each of them and pass on an authorized JCR session, so you will be able to work with all information inside the repository.

I'm always using Maven 2 while working with CMS 7. Maven 2 has some useful utilities and it can help you you out with adding the correct manifest entry.
In my pom.xml I added some configuration for the maven-jar-plugin that adds my module to the manifest.

``` xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-jar-plugin</artifactId>
  <configuration>
    <archive>
      <manifest>
        <addDefaultImplementationEntries>true</addDefaultImplementationEntries>
      </manifest>
      <manifestEntries>
        <Hippo-Modules>com.example.repository.BackgroundModule</Hippo-Modules>
      </manifestEntries>
    </archive>
  </configuration>
</plugin>
```

If you need to add more then one module, you can do so by adding a space in between modules.<br /><br />For the project I was doing, I also made use of <a href="http://www.opensymphony.com/quartz/">Quartz</a> triggers, so my module would execute once in a while instead of just after initialization of the repository. <br /><br />The concept of these modules is quite powerful, so I hope this can help you to get started with writing your own Daemon modules.<br /><br /><b>Update</b><br /><br />The above article describes the situation back in 2009. With the recent release of Hippo CMS 7.8 there is a slightly different way of creating these modules. For more information see the <a href="http://www.onehippo.org/7_8/library/concepts/hippo-services/repository-managed-components.html" target="_blank">repository managed components page</a> in the hippo documentation.</div>
