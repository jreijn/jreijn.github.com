---
comments: false
date: "2019-11-29T00:00:00Z"
image: /assets/2019/kotlin-spring-boot2.png
categories:
- Software Engineering
tags:
- java
- spring-boot
- kotlin
title: Migrating a Spring Boot service from Java 11 to Kotlin
---

At my current project we’ve just finished migrating a Spring Boot 2.1.x service from Java 11 to [Kotlin](https://kotlinlang.org/). While doing so we’ve learned quite a few things along the way and I created some notes that I wanted to share in case somebody else runs into the same issues. It was our first Kotlin migration and getting to know the Kotlin language better was/is a lot of fun, but also confusing at times.

## The lack of *static* properties in Kotlin

In Java, having a static property for something like a Logger is a very common use case. It’s pretty straight forward, but in Kotlin there are a few different ways to solve the problem of defining a logger. Kotlin does not know the static keyword, so for instance one option is to use a companion object

```java
class SomeService {
    companion object {
        private val LOGGER = LoggerFactory.getLogger(SomeService::class.java)
    }
}
```

The whole concept of a companion object was something I really needed to get used to. The above example was what we went with in our code, but there are several different ways do define a logger with their own pros and cons. Before I repeat a detailed explanation I would like to point you to [this insightful article on Baeldung](https://www.baeldung.com/kotlin-logging) about Kotlin and Loggers.

## Data classes

In our Java based version of the service we were using Lombok to avoid most of the Java boilerplate code. We leveraged Lombok mostly for our Value or Data classes. It’s also very easy to add a builder for for instance a DTO class.
Lombok does a lot for you in the background and you really should know the effect of adding a certain annotation, because it will generate quite some code. Getting rid of this ‘magic’ was one of the reasons we started looking at migrating some parts of our code base to Kotlin and leverage Kotlin Data classes with named parameters. Now let’s take an example Person class which we will convert from Java + Lombok to a Kotlin data class.

```java
import java.time.LocalDate;
import lombok.Value;

@Value
@Builder
public class Person {
    private String name;
    private String country;
}
```

That’s a pretty straightforward class right? Now in Kotlin you can create a data class by adding the **data** classifier before the class name.

```java
data class Person(val name: String, val country: String)
```

Using named parameters in Kotlin allows you to use a similar construction as to using a Builder, but without having to generate a lot of boilerplate code like in plain Java.

```java
val person = Person(name="Jeroen", country = "The Netherlands")
```

## Be careful with manual conversion

After converting our main Spring Boot *Application.java* class and some modifications to the code, we tried to run our Spring Boot application and ended up with the following strange message:

``` 
Execution failed for task ':demoservice:bootJar'.> Main class name has not been configured and it could not be resolved
```

Spring Boot has been supporting Kotlin for a while now, so that could’t be it. Generating a new Spring Boot project from https://start.spring.io. with Kotlin as the default language also did not immediately show an obvious answer, but the answer was staring us right in the face. Let’s take a look at a basic Java version of an Application class.

```java
@SpringBootApplication
public class MainApplication {

    private static final Logger LOGGER = LoggerFactory.getLogger(MainApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(MainApplication.class, args);
    }
}
```

If you’re new to Kotlin and would manually convert the Java class to Kotlin you might end up with something like this:

```java
class MainApplication {
    private val LOGGER = LoggerFactory.getLogger(MainApplication::class.java)
    
    fun main(args: Array) {
        SpringApplication.run(MainApplication::class.java, *args)
    }
}
```

Coming from a Java background this still *looks* fine, but there is a slight difference if we compare that to the Spring Boot initializer generated Application class as seen below.

```java
@SpringBootApplication
class MainApplication

fun main(args: Array) {
	runApplication(*args)
}
```

Those of you that read both code snippets carefully will notice there are no curly braces after the MainApplication class definition in the second example compared to the first code snippet. So the above example has the main function as a package level function. You might also notice that there is also no static keyword. Kotlin represents package-level functions as static methods. Kotlin can also generate static methods for functions defined in named objects or companion objects if you annotate those functions as [@JvmStatic](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.jvm/-jvm-static/index.html). If you use the @JvmStatic annotation, the compiler will generate both a static method in the enclosing class of the object and an instance method in the object itself. It turned out Spring really needed that static main method and after we moved the function out of the class the Spring Boot Gradle plugin was able to start our application just fine.

## Spring boot 2.1.x and Kotlin 1.3
We also ran into a problem when introducing [detekt](https://arturbosch.github.io/detekt/), a static code analyzer for Kotlin, into our build cycle. After adding the Detekt Gradle plugin (version 1.1.1) we ran into a strange exception during the Kotlin compile phase:

```
> Task :springcommon:compileKotlin FAILED
e: java.lang.NoClassDefFoundError: kotlin/coroutines/jvm/internal/RestrictedSuspendLambda
       at java.base/java.lang.ClassLoader.defineClass1(Native Method)
       at java.base/java.lang.ClassLoader.defineClass(ClassLoader.java:1016)
       at java.base/java.security.SecureClassLoader.defineClass(SecureClassLoader.java:174)
       at java.base/java.net.URLClassLoader.defineClass(URLClassLoader.java:550)
       at java.base/java.net.URLClassLoader$1.run(URLClassLoader.java:458)
       at java.base/java.net.URLClassLoader$1.run(URLClassLoader.java:452)
       at java.base/java.security.AccessController.doPrivileged(Native Method)
       at java.base/java.net.URLClassLoader.findClass(URLClassLoader.java:451)
       at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:588)
       at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:521)
       at org.jetbrains.kotlin.scripting.definitions.ScriptiDefinitionsFromClasspathDiscoverySource
```

This had to be some sort of classpath or dependency issue so it required some more debugging and looking at dependency trees to figure out what was going on. Apparently Spring boot (2.1.x) manages the Kotlin version for several of its modules, which for Spring Boot 2.1 is version 1.2.x of Kotlin. That specific version was conflicting with the version of our project, which was 1.3.x, and also with the version of Kotlin used by the detekt plugin. Luckily the fix was pretty simple. You can explicitly set the Kotlin version in your *build.gradle* so it will be used for all plugins within your project.

```
ext['kotlin.version'] = '1.3.10'
```

Luckily we were not the first to encounter this issue and there was already a thread on the specific problem. See https://github.com/spring-gradle-plugins/dependency-management-plugin/issues/235 for more background information.