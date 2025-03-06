---
comments: false
date: "2014-06-12T00:00:00Z"
categories:
- Software Engineering
title: Great SaaS products for your Open Source project
---

While working on a new [Hippo CMS](http://www.onehippo.org) add-on I chose not to take the usual route by putting all my stuff on the [Hippo Forge](http://forge.onehippo.org/).
My personal opinion about the forge is that it feels outdated, hard to navigate and lacks features with regards to what modern-day software developers would want.
Sure the Hippo Forge gives us one central place to go to, but that can be solved by other solutions as well.
For this particular project I chose to see how far I would come by combining different free for open source SaaS products and see how much value they could give me.

## Source control

Well first things first. To be able to open source your project you need to be able to store the source code somewhere, so a publicly available source control management system was my number one priority. I chose to put my code on [GitHub](http://github.com). Other services like [Bitbucket](http://bitbucket.org), [Google code](http://code.google.com) or [SourceForge](http://sourceforge.net) would do fine as well, but I really like how Github works, navigates and looks. Also it seems to be the most adopted SCM out there at the moment. I'm not sure if there are any numbers available, but my guess is that GitHub also has the most (active) users, so Github gives your project the best exposure and largest possible community. Github also gives your project a Wiki, Issue management and a documentation website which can be automatically generated from markdown files. This is a huge amount of infrastructure which you get all at once. For me this replaces most of the tools I need and use for projects on the Hippo Forge.

## Continuous integration

Having a place to store the source code is one thing, but modern software developers are used to having more tools at their disposal.
To make sure the project always builds successfully we need to have a Continuous Integration server.
With the rise of 'the cloud' and SaaS providers there is quite a number of freely available CI services to choose from.
To name a few: [Cloudbees](http://www.cloudbees.com) (Jenkins), [Wercker](http://wercker.com/), [Codeship](http://codeship.io), [Drone](http://drone.io), [Snap](http://snap-ci.com) and probably the more well-known (at least on Github) [Travis](http://travis-ci.org).
This is just a small list of services and some of them do more than just providing a CI service. It really depend on the programming language of the project and your specific requirements which CI solution would suit your project best.
For my particular project I chose to use Travis, because it integrates really well with GitHub and was really easy to set up. Most of these CI services use the available Github APIs to for instance tell you what the status would be once a certain pull request would get merged.
A selection of these services also offer a nice little feature called a 'status badge', which can be really handy and shows the latest build status.

![Travis build status](/assets/travis-build-status.png)

With this little button you can inform developers about the current status of the build before they do a clone / checkout of the code. You see these badges a lot in Github based projects. It's really easy to embed the status in your project readme file.

Adding Travis to a Java based project is really simple. You need to add a file called ```.travis.yml``` to the root of your project and tell Travis how to build your project. Below you see a short example of the .travis.yml of my own project.

```
language: java
jdk:
  - oraclejdk7
script: mvn verify
```

As you can see the configuration file tells Travis the language of the project and additionally some extra options to explain how to build your project. In my case I can explicitly tell Travis which maven command should be executed to perform a proper build of my project. This is really useful in case you need to use a maven profile or something similar. In my case I chose to use ```mvn verify```, because I want Travis to also execute my integrations tests, which run in within the verify phase of my project.

Now the last step is to sign into Travis and enable the build for your project. This is as easy is flipping a switch.

![Enable Travis builds for your project.](/assets/travis-ci-project-switch.png)

Easy right? It took me less than 5 minutes to set this up and get the project going.

## Code coverage

I personally care about the quality of the code I write. Even more if the project is open source. Now at the office we use [SonarQube](http://www.sonarqube.org/) for measuring the quality of our code over time, but unfortunately there is no free instance available for open source projects or you need to host it yourself. However there are some really nice alternatives available. While exploring the market I came across [CodeClimate](https://codeclimate.com) (unfortunately no Java yet) and the really awesome [Coveralls](https://coveralls.io/). Coveralls integrates really nice with the Github API and is also able to show you the result of a pull request.

![Coveralls project coverage.](/assets/coveralls-feature-github-pull.jpg)

It's really easy to enable it for your project just like Travis by just flipping a switch. I like that it has the ability to show the coverage over time and can even give you line by line coverage reporting per file.

![Coveralls timeline for your project.](/assets/coveralls-coverage-timeline.png)

To use Coveralls in my project I had to set up the ```coveralls-maven-plugin```. In that sense it works sort of the same as the Maven SonarQube plugin. During the build phase my coverage data is gathered by the ```jacoco-maven-plugin``` and once the data is collected it's send to the Coveralls service. This was as easy as just adding the following plugin to the Maven pom.xml file and enable the project within the coveralls web UI.

``` xml
<plugin>
  <groupId>org.eluder.coveralls</groupId>
  <artifactId>coveralls-maven-plugin</artifactId>
  <version>2.2.0</version>
</plugin>
```

Same as Travis, Coveralls also has these nice little badges which you can embed within your project documentation to share the code coverage of the project.

## Storing artifacts

Now my last outstanding question is where do I store my release artifacts? I guess this really depends on the programming language being used, but in my case it's Java and I've seen several approaches. You could store it in a separate
repository on Github which acts as a maven repository, but this is not really recommended and is not a long-term solution. A better approach is to use the [Sonatype Open Source Repository](http://central.sonatype.org/pages/ossrh-guide.html), which is publicly available to open source projects. There are some limitations like all your project dependencies should be available in Maven Central, but in general this is a really good way to have your release artifacts available for others to use. In case you store your maven artifacts in the OSSRH you can promote release binaries and let them sync to the Central Maven Repository, which is a really nice bonus.

## Summary

If I look at the available services there is some really amazing stuff out there. It's easy to decentralizing the required infrastructure these days and you can even get more value from choosing the right combination. I've seen some interesting services like Snap, which also offer build pipelines and more and I will definitely take a look at how I can use these services more effectively.
