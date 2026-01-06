---
categories:
- Software Engineering
comments: false
date: "2011-07-31T00:00:00Z"
title: Getting started with MongoDB and Spring Data
aliases:
- getting-started-with-mongodb-and-spring
---


Last month I finally found some time to play around with a NoSQL database. Getting hands on experience with a NoSQL database has been on my list for quite some time, but due to busy times at work I was unable to find the energy to get things going.

## A little background information

Most of you have probably have heard the term <a href="http://en.wikipedia.org/wiki/Nosql">NoSQL</a> before.
The term is used in situations where you do not have a traditional relation database for storing information.
There are many different sorts of NoSQL databases. To make a small summary these are probably the most well-known:

<ul>
<li>Wide Column Stores: <a href="http://hadoop.apache.org/">Hadoop</a> and <a href="http://cassandra.apache.org/">Cassandra</a></li>
<li>Document Stores: <a href="http://couchdb.apache.org/">CouchDB</a> and <a href="http://www.mongodb.org/">MongoDB</a></li>
<li>Key Value Store: <a href="http://redis.io/">Redis</a></li>
<li>Eventually Consistent Key Value Store: <a href="http://project-voldemort.com/">Voldemort</a></li>
<li>Graph Databases: <a href="http://neo4j.org/">Neo4J</a></li>
</ul>

The above types cover most of the differences, but for each type there are a lot of different implementations.
For a better overview you might want to take a look at the <a href="http://nosql-database.org/">NOSQL database website</a>.

For my own experiment I chose to use MongoDB, since I had read a lot about it and it seemed quite easy to get started with.
MongoDB is as they describe it on their website:

>A scalable, high-performance, open source, document-oriented database.

The document-oriented aspect was one of the reasons why I chose MongoDB to start with. It allows you to store rich content with data structures inside your datastore.

## Getting started with MongoDB

<a href="http://1.bp.blogspot.com/-W_1zs60Kzao/TjAAw6azBtI/AAAAAAAAAfM/GGS2KPkykAs/s1600/MongoDB-Logo-300x100.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" height="66" src="http://1.bp.blogspot.com/-W_1zs60Kzao/TjAAw6azBtI/AAAAAAAAAfM/GGS2KPkykAs/s200/MongoDB-Logo-300x100.png" width="200" /></a>
To begin with, I looked at the <a href="http://www.mongodb.org/display/DOCS/Quickstart+OS+X">Quick start page</a> for Mac OS X and I recommend you to do that too (unless you use a different OS).
It will get you going and within a couple of minutes you'll have MongoDB up and running on your local machine.

MongoDB stores it's data by default in a certain location. Of course you can configure that, so I started MongoDB with the --dbpath parameter. This parameter will allow you to specificy your own storage location.
It will look something like this:

```
$ ./mongodb-xxxxxxx/bin/mongod --dbpath=/Users/jreijn/Development/temp/mongodb/
```

If you do that you eventually will get a message saying:

```
Mon Jul 18 22:19:58 [initandlisten] waiting for connections on port 27017
Mon Jul 18 22:19:58 [websvr] web admin interface listening on port 28017
```

At this point MongoDB is running and we can proceed to the next step: using Spring Data to interact with MongoDB.

## Getting started with Spring Data

The primary goal of the <a href="http://www.springsource.org/spring-data">Spring Data</a> project is to make it easier for developers to work with (No)SQL databases.
The Spring Data project already has support for a number of the above mentioned NoSQL type of databases.

Since we're now using MongoDB, there is a specific sub project that handles MongoDB interaction.
To be able to use this in our project we first need to add a Maven dependency to our pom.xml.

``` xml
<dependency>
  <groupId>org.springframework.data</groupId>
  <artifactId>spring-data-mongodb</artifactId>
  <version>${spring.data.mongo.version}</version>
</dependency>
```

Looks easy right? Just one single Maven dependency.
Of course in the end the spring-data-mongodb artifact depends on other artifacts which it will bring into your project.
In this post I used version 1.0.2.RELEASE. Now on to some Java code!

For my first experiment I used a simple Person domain object that I'm going to query and persist inside the database.
The Person class is quite simple and looks as follows.

``` java
package com.jeroenreijn.mongodb.example.domain;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * A simple POJO representing a Person
 **/
@Document
public class Person {
  @Id
  private String personId;
  private String name;
  private String homeTown;
  private int age;

  public Person(String name, int age) {
   this.name = name;
   this.age = age;
  }

  public String getPersonId() {
   return personId;
  }

  public void setPersonId(final String personId) {
   this.personId = personId;
  }

  public String getName() {
   return name;
  }

  public void setName(final String name) {
    this.name = name;
  }

  public int getAge() {
    return age;
  }

  public void setAge(final int age) {
    this.age = age;
  }

  public String getHomeTown() {
    return homeTown;
  }

  public void setHomeTown(final String homeTown) {
    this.homeTown = homeTown;
  }

  @Override
  public String toString() {
    return "Person [id=" + personId + ", name=" + name + ", age=" + age + ", home town=" + homeTown + "]";
  }
}
```

Now if you look at the class more closely you will see some Spring Data specific annotations like <i>@Id</i> and <i>@Document</i> .
The <i>@Document</i> annotation identifies a domain object that is going to be persisted to MongoDB.
Now that we have a persistable domain object we can move on to the real interaction.

For easy connectivity with MongoDB we can make use of Spring Data's <i>MongoTemplate</i> class.
Here is a simple PersonRepository object that handles all 'Person' related interaction with MongoDB by means of the MongoTemplate.

``` java
package com.jeroenreijn.mongodb.example;
import java.util.Iterator;
import java.util.List;
import com.jeroenreijn.mongodb.example.domain.Person;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Repository;

/**
 * Repository for {@link Person}s
 */
@Repository
public class PersonRepository {

  static final Logger logger = LoggerFactory.getLogger(PersonRepository.class);
  @Autowired
  MongoTemplate mongoTemplate;

  public void logAllPersons() {
    List<Person> results = mongoTemplate.findAll(Person.class);
    logger.info("Total amount of persons: {}", results.size());
    logger.info("Results: {}", results);
  }

  public void insertPersonWithNameJohnAndRandomAge() {
    //get random age between 1 and 100
    double age = Math.ceil(Math.random() * 100);
    Person p = new Person("John", (int) age);
    mongoTemplate.insert(p);
  }

  /**
    * Create a {@link Person} collection if the collection does not already exists
    */
  public void createPersonCollection() {
    if (!mongoTemplate.collectionExists(Person.class)) {
      mongoTemplate.createCollection(Person.class);
    }
  }

  /**
   * Drops the {@link Person} collection if the collection does already exists
   */
   public void dropPersonCollection() {
     if (mongoTemplate.collectionExists(Person.class)) {
       mongoTemplate.dropCollection(Person.class);
     }
   }
}
```

If you look at the above code you will see the <i>MongoTemplate</i> in action.
There is quite a long list of method calls which you can use for inserting, querying and so on.
The MongoTemplate in this case is <i>@Autowired</i> from the Spring configuration, so let's have a look at the configuration.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context" xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
       http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd">
   <!-- Activate annotation configured components -->
   <context:annotation-config/>

   <!-- Scan components for annotations within the configured package -->
   <context:component-scan base-package="com.jeroenreijn.mongodb.example">
     <context:exclude-filter type="annotation" expression="org.springframework.context.annotation.Configuration"/>
   </context:component-scan>

   <!-- Define the MongoTemplate which handles connectivity with MongoDB -->
   <bean id="mongoTemplate" class="org.springframework.data.mongodb.core.MongoTemplate">
     <constructor-arg name="mongo" ref="mongo"/>
     <constructor-arg name="databaseName" value="demo"/>
   </bean>

   <!-- Factory bean that creates the Mongo instance -->
   <bean id="mongo" class="org.springframework.data.mongodb.core.MongoFactoryBean">
     <property name="host" value="localhost"/>
   </bean>

   <!-- Use this post processor to translate any MongoExceptions thrown in @Repository annotated classes -->
   <bean class="org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor"/>
</beans>
```

The <i>MongoTemplate</i> is configured with a reference to a <i>MongoDBFactoryBean</i> (which handles the actual database connectivity) and is setup with a database name used for this example.
Now that we have all components in place, let's get something in and out of MongoDB.

``` java
package com.jeroenreijn.mongodb.example;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 * Small MongoDB application that uses spring data to interact with MongoDB.
 */
public class MongoDBApp {
  static final Logger logger = LoggerFactory.getLogger(MongoDBApp.class);

  public static void main( String[] args ) {
    logger.info("Bootstrapping MongoDemo application");
    ConfigurableApplicationContext context = new ClassPathXmlApplicationContext("META-INF/spring/applicationContext.xml");
    PersonRepository personRepository = context.getBean(PersonRepository.class);

    // cleanup person collection before insertion
    personRepository.dropPersonCollection();
    //create person collection<br />
    personRepository.createPersonCollection();

    for(int i=0; i<20; i++) {
      personRepository.insertPersonWithNameJohnAndRandomAge();
    }
    personRepository.logAllPersons();
    logger.info("Finished MongoDemo application");
  }
}
```

All this application does for now is setup a connection with MongoDB, insert 20 persons (documents), fetch them all and write the information to the log.
As a first experiment this was quite fun to do.

## Summary
As you can see with Spring Data it's quite easy to get some basic functionality within only a couple of minutes. All the sources mentioned above and a working project can be found on <a href="https://github.com/jreijn/spring-mongo-demo">GitHub</a>. It was a fun first experiment and I already started working on a bit more advanced project, which combines Spring Data, MongoDB, HTML5 and CSS3. It will be on GitHub shortly together with another blog post here so be sure to come back.</div>
