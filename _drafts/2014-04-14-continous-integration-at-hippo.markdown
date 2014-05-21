---
layout: post
title: "How we practice Continuous Integration with our products at Hippo"
date: 2014-04-14
comments: true
categories:
 - hippo
---

Personally I always like to read how other companies do software development, but sharing our way is probably just as interesting to others.
In this post I will describe what a typical  Hippo CMS development cycle looks like and how we do continuous integration at <a href="http://www.onehippo.com/" target="_blank">Hippo</a>.

+ Maintain a code repository
+ Automate the build
+ Make the build self-testing
+ Everyone commits to the baseline every day
+ Every commit (to the baseline) should be built
+ Keep the build fast
+ Test in a clone of the production environment
+ Everyone can see the result of the latest build
+ Automate deployment

But let's start at the beginning with the development environment of a typical software developer working at Hippo.

##The development environment

At Hippo, we as developers can choose our own preferred development platform. Being Windows, any Linux distribution or Mac.
The majority of the <a href="http://www.onehippo.org/" target="_blank">Hippo CMS</a> code base consists of Java and JavaScript.
Our standard developer environment therefor contains Java 7 and <a href="http://maven.apache.org/" target="_blank">Apache Maven</a> (for build and dependency management).
With regards to an IDE the majority of developers at Hippo prefer <a href="http://www.jetbrains.com/idea/" target="_blank">IntelliJ</a> Ultimate with Eclipse coming in second.
As a version control system for most of our code we use our public <a href="http://svn.onehippo.org/repos/hippo/hippo-cms7/" target="_blank">Subversion repository</a>.
I say most, because a few months back we adopted <a href="http://angularjs.org/" target="_blank">AngularJS</a> into our stack which required back then to have some parts on <a href="http://www.github.com/" target="_blank">Github</a>.
I will explain more about why later in this post.

Development strategy wise we do a lot of trunk based development. For features that will take more than a couple of days we tend to use feature branches, which we keep in sync with the trunk as often as possible to prevent getting into a merge hell.
Bug fixes in the product usually also happen first on trunk before they get back-ported to one of the maintenance release branches.

##Integrating the changes

For continuous integration we use <a href="http://hudson-ci.org/" target="_blank">Hudson</a> (we have plans to migrate to <a href="http://jenkins-ci.org/" target="_blank">Jenkins</a>) which contains different <a href="https://builds.onehippo.org/" target="_blank">jobs</a> for different parts of our CMS stack ( CMS, HST, Repository and additional modules like replication, relevance, etc).
Hudson polls the Subversion repository for changes and when a change is detected the Maven build is started and all code will get compiled, unit tested (JUnit) and a bunch of integration tests are run.
Since we try to commit as often as possible this cycle happens multiple times a day. The above setup is quite common when doing CI with Java based projects.

As I mentioned before we adopted AngularJS for our CMS UI. This also required us to rethink our current build environment. For AngularJS based projects it's quite common to use a combination of [npm](https://www.npmjs.org/), [grunt](http://gruntjs.com/) and [bower](http://bower.io/). Now ideally we did not want to have multiple ways of working with our software, so it should be pretty straight forward on how to build the different components.
To be able to use Maven we use the ```exec-maven-plugin``` to call these tools from Maven.

As I said we use Bower for dependency management for our Javascript libraries. Now since Maven itself is just focussed on Java based dependencies we needed to figure out how to get our Javascript dependency into our build lifecycle. There are several ways of doing this using these tools together. The [using Grunt and Maven together](http://addyosmani.com/blog/making-maven-grunt/) post by @addyosmani explains several options, but here is how we did it.

What we did is use Maven to actually package our javascript dependencies as .zip based artifacts with the ```maven-assembly-plugin```and store in our nexus repository just like we do with our .jar dependencies.

Now when the build of a CMS component (which contains AngularJS code) is started we first fetch these .zip based artifacts to the ```initialize``` phase of the [Maven build lifecycle](http://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference). During the initialize of the build we copy the dependencies from our remote maven repository into our build directory and extract the zip files, so they can be used by bower as normal dependencies. Bower has several ways of working with dependencies



``` xml
<build>
  <defaultGoal>package</defaultGoal>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-dependency-plugin</artifactId>
      <version>${maven.plugin.dependency.version}</version>
      <executions>
        <execution>
          <id>fetch-bower-dependencies</id>
          <phase>initialize</phase>
          <goals><goal>copy-dependencies</goal></goals>
          <configuration>
            <includeGroupIds>org.onehippo.cms7.frontend</includeGroupIds>
            <includeArtifactIds>
              hippo-plugins,
              hippo-theme
            </includeArtifactIds>
            <stripClassifier>true</stripClassifier>
            <stripVersion>true</stripVersion>
          </configuration>
        </execution>
      </executions>
    </plugin>
    <plugin>
      <groupId>org.codehaus.mojo</groupId>
      <artifactId>exec-maven-plugin</artifactId>
      <version>${maven.plugin.exec.version}</version>
      <executions>
        <execution>
          <id>npm-install</id>
          <phase>generate-sources</phase>
          <goals><goal>exec</goal></goals>
          <configuration>
            <executable>npm</executable>
            <commandlineArgs>install</commandlineArgs>
          </configuration>
        </execution>
        <execution>
          <id>bower-install</id>
          <phase>generate-sources</phase>
          <goals><goal>exec</goal></goals>
          <configuration>
            <executable>bower</executable>
            <commandlineArgs>install</commandlineArgs>
          </configuration>
        </execution>
        <execution>
          <id>grunt-build</id>
          <phase>generate-sources</phase>
          <goals><goal>exec</goal></goals>
          <configuration>
            <executable>grunt</executable>
            <commandlineArgs>build</commandlineArgs>
          </configuration>
        </execution>
        <execution>
          <id>grunt-test</id>
          <phase>test</phase>
          <goals><goal>exec</goal></goals>
          <configuration>
            <executable>grunt</executable>
            <commandlineArgs>test</commandlineArgs>
            <skip>${skipTests}</skip>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

###'Nightly' deploys

Now when all builds are successful we have one final step in the process which is creating a distribution of our demo website project (also known as GoGreen) based on the latest version of the entire stack.
We chose to use a real project, because it helps us keep track of what kind of effect a change has on an existing project running an older version of the stack.
The distribution will be stored in our nexus repository from which it will be fetched by a cron job on the internal test server.
Once the distribution is on the test server it will be unpacked and deployed in an existing Tomcat container.
This makes all the new features available to the QA team and product owners, so they can see the 'current' state of the product.

So the end result looks like this:

![CI at Hippo](/assets/ci-at-hippo-small.png)
