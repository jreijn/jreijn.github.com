---
layout: post
title: "Getting started with MongoDB and Spring Data"
date: 2011-07-31
comments: false
categories:
 - java
 - nosql
---

<div class='post'>
Last month I finally found some time to play around with a NoSQL database. Getting hands on experience with a NoSQL database has been on my list for quite some time, but due to busy times at work I was unable to find the energy to get things going.<br /><br /><h2> A little background information</h2><br />Most of you have probably have heard the term <a href="http://en.wikipedia.org/wiki/Nosql">NoSQL</a> before. The term is used in situations where you do not have a traditional relation database for storing information. There are many different sorts of NoSQL databases. To make a small summary these are probably the most well-known:<br /><br /><ul><li>Wide Column Stores: <a href="http://hadoop.apache.org/">Hadoop</a> and <a href="http://cassandra.apache.org/">Cassandra</a></li><li>Document Stores: <a href="http://couchdb.apache.org/">CouchDB</a> and <a href="http://www.mongodb.org/">MongoDB</a></li><li>Key Value Store: <a href="http://redis.io/">Redis</a></li><li>Eventually Consistent Key Value Store: <a href="http://project-voldemort.com/">Voldemort</a></li><li>Graph Databases: <a href="http://neo4j.org/">Neo4J</a></li></ul><br />The above types cover most of the differences, but for each type there are a lot of different implementations. For a better overview you might want to take a look at the <a href="http://nosql-database.org/">NOSQL database website</a>. <br /><br />For my own experiment I chose to use MongoDB, since I had read a lot about it and it seemed quite easy to get started with. <br /><br />MongoDB is as they describe it on their website:<br /><blockquote><span style="font-size: large;"><i>A scalable, high-performance, open source, document-oriented database.</i></span></blockquote>The document-oriented aspect was one of the reasons why I chose MongoDB to start with. It allows you to store rich content with data structures inside your datastore.<br /><br /><h2> Getting started with MongoDB</h2><a href="http://1.bp.blogspot.com/-W_1zs60Kzao/TjAAw6azBtI/AAAAAAAAAfM/GGS2KPkykAs/s1600/MongoDB-Logo-300x100.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" height="66" src="http://1.bp.blogspot.com/-W_1zs60Kzao/TjAAw6azBtI/AAAAAAAAAfM/GGS2KPkykAs/s200/MongoDB-Logo-300x100.png" width="200" /></a><br />To begin with, I looked at the <a href="http://www.mongodb.org/display/DOCS/Quickstart+OS+X">Quick start page</a> for Mac OS X and I recommend you to do that too (unless you use a different OS). It will get you going and within a couple of minutes you'll have MongoDB up and running on your local machine. <br /><br />MongoDB stores it's data by default in a certain location. Of course you can configure that, so I started MongoDB with the --dbpath parameter. This parameter will allow you to specificy your own storage location. It will look something like this:<br /><br />$ ./mongodb-xxxxxxx/bin/mongod --dbpath=/Users/jreijn/Development/temp/mongodb/<br /><br />If you do that you eventually will get a message saying:<br /><br /><code><br />Mon Jul 18 22:19:58 [initandlisten] waiting for connections on port 27017<br />Mon Jul 18 22:19:58 [websvr] web admin interface listening on port 28017<br /></code><br /><br />At this point MongoDB is running and we can proceed to the next step: using Spring Data to interact with MongoDB.<br /><br /><h2> Getting started with Spring Data</h2>The primary goal of the <a href="http://www.springsource.org/spring-data">Spring Data</a> project is to make it easier for developers to work with (No)SQL databases. The Spring Data project already has support for a number of the above mentioned NoSQL type of databases.<br />Since we're now using MongoDB, there is a specific sub project that handles MongoDB interaction. To be able to use this in our project we first need to add a Maven dependency to our pom.xml.<br /><br /><pre class="brush:xml">&lt;dependency&gt;<br />  &lt;groupId&gt;org.springframework.data&lt;/groupId&gt;<br />  &lt;artifactId&gt;spring-data-mongodb&lt;/artifactId&gt;<br />  &lt;version&gt;${spring.data.mongo.version}&lt;/version&gt;<br />&lt;/dependency&gt;<br /></pre><br />Looks easy right? Just one single Maven dependency. Of course in the end the spring-data-mongodb artifact depends on other artifacts which it will bring into your project. In this post I used version 1.0.2.RELEASE.&nbsp; Now on to some Java code!<br /><br />For my first experiment I used a simple Person domain object that I'm going to query and persist inside the database. The Person class is quite simple and looks as follows.<br /><br /><pre class="brush:java">package com.jeroenreijn.mongodb.example.domain;<br /><br />import org.springframework.data.annotation.Id;<br />import org.springframework.data.mongodb.core.mapping.Document;<br /><br />/**<br /> * A simple POJO representing a Person<br /> *<br /> */<br />@Document<br />public class Person {<br /><br />    @Id<br />    private String personId;<br /><br />    private String name;<br />    private String homeTown;<br />    private int age;<br /><br />    public Person(String name, int age) {<br />        this.name = name;<br />        this.age = age;<br />    }<br /><br />    public String getPersonId() {<br />        return personId;<br />    }<br /><br />    public void setPersonId(final String personId) {<br />        this.personId = personId;<br />    }<br /><br />    public String getName() {<br />        return name;<br />    }<br />    public void setName(final String name) {<br />        this.name = name;<br />    }<br /><br />    public int getAge() {<br />        return age;<br />    }<br /><br />    public void setAge(final int age) {<br />        this.age = age;<br />    }<br /><br />    public String getHomeTown() {<br />        return homeTown;<br />    }<br /><br />    public void setHomeTown(final String homeTown) {<br />        this.homeTown = homeTown;<br />    }<br /><br />    @Override<br />    public String toString() {<br />        return "Person [id=" + personId + ", name=" + name + ", age=" + age + ", home town=" + homeTown + "]";<br />    }<br /><br />}<br /></pre><br />Now if you look at the class more closely you will see some Spring Data specific annotations like <i>@Id</i> and <i>@Document</i> . The <i>@Document</i> annotation identifies a domain object that is going to be persisted to MongoDB. Now that we have a persistable domain object we can move on to the real interaction.<br /><br />For easy connectivity with MongoDB we can make use of Spring Data's <i>MongoTemplate</i> class. Here is a simple PersonRepository object that handles all 'Person' related interaction with MongoDB by means of the MongoTemplate.<br /><br /><pre class="brush:java">package com.jeroenreijn.mongodb.example;<br /><br />import java.util.Iterator;<br />import java.util.List;<br /><br />import com.jeroenreijn.mongodb.example.domain.Person;<br /><br />import org.slf4j.Logger;<br />import org.slf4j.LoggerFactory;<br />import org.springframework.beans.factory.annotation.Autowired;<br />import org.springframework.data.mongodb.core.MongoTemplate;<br />import org.springframework.stereotype.Repository;<br /><br />/**<br /> * Repository for {@link Person}s<br /> *<br /> */<br />@Repository<br />public class PersonRepository {<br /><br />    static final Logger logger = LoggerFactory.getLogger(PersonRepository.class);<br /><br />    @Autowired<br />    MongoTemplate mongoTemplate;<br /><br />    public void logAllPersons() {<br />        List&lt;Person&gt; results = mongoTemplate.findAll(Person.class);<br />        logger.info("Total amount of persons: {}", results.size());<br />        logger.info("Results: {}", results);<br />    }<br /><br />    public void insertPersonWithNameJohnAndRandomAge() {<br />        //get random age between 1 and 100<br />        double age = Math.ceil(Math.random() * 100);<br /><br />        Person p = new Person("John", (int) age);<br /><br />        mongoTemplate.insert(p);<br />    }<br /><br />    /**<br />     * Create a {@link Person} collection if the collection does not already exists<br />     */<br />    public void createPersonCollection() {<br />        if (!mongoTemplate.collectionExists(Person.class)) {<br />            mongoTemplate.createCollection(Person.class);<br />        }<br />    }<br /><br />    /**<br />     * Drops the {@link Person} collection if the collection does already exists<br />     */<br />    public void dropPersonCollection() {<br />        if (mongoTemplate.collectionExists(Person.class)) {<br />            mongoTemplate.dropCollection(Person.class);<br />        }<br />    }<br />}<br /><br /></pre><br />If you look at the above code you will see the <i>MongoTemplate</i> in action. There is quite a long list of method calls which you can use for inserting, querying and so on. The MongoTemplate in this case is <i>@Autowired</i> from the Spring configuration, so let's have a look at the configuration.<br /><br /><pre class="brush:xml">&lt;?xml version="1.0" encoding="UTF-8"?&gt;<br />&lt;beans xmlns="http://www.springframework.org/schema/beans"<br />       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"<br />       xmlns:context="http://www.springframework.org/schema/context"<br />       xsi:schemaLocation="http://www.springframework.org/schema/beans<br />        http://www.springframework.org/schema/beans/spring-beans-3.0.xsd<br />        http://www.springframework.org/schema/context<br />        http://www.springframework.org/schema/context/spring-context-3.0.xsd"&gt;<br /><br />  &lt;!-- Activate annotation configured components --&gt;<br />  &lt;context:annotation-config/&gt;<br /><br />  &lt;!-- Scan components for annotations within the configured package --&gt;<br />  &lt;context:component-scan base-package="com.jeroenreijn.mongodb.example"&gt;<br />    &lt;context:exclude-filter type="annotation" expression="org.springframework.context.annotation.Configuration"/&gt;<br />  &lt;/context:component-scan&gt;<br /><br />  &lt;!-- Define the MongoTemplate which handles connectivity with MongoDB --&gt;<br />  &lt;bean id="mongoTemplate" class="org.springframework.data.mongodb.core.MongoTemplate"&gt;<br />    &lt;constructor-arg name="mongo" ref="mongo"/&gt;<br />    &lt;constructor-arg name="databaseName" value="demo"/&gt;<br />  &lt;/bean&gt;<br /><br />  &lt;!-- Factory bean that creates the Mongo instance --&gt;<br />  &lt;bean id="mongo" class="org.springframework.data.mongodb.core.MongoFactoryBean"&gt;<br />    &lt;property name="host" value="localhost"/&gt;<br />  &lt;/bean&gt;<br /><br />  &lt;!-- Use this post processor to translate any MongoExceptions thrown in @Repository annotated classes --&gt;<br />  &lt;bean class="org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor"/&gt;<br /><br />&lt;/beans&gt;<br /></pre><br />The <i>MongoTemplate</i> is configured with a reference to a <i>MongoDBFactoryBean</i> (which handles the actual database connectivity) and is setup with a database name used for this example.<br /><br />Now that we have all components in place, let's get something in and out of MongoDB.<br /><br /><pre class="brush:java">package com.jeroenreijn.mongodb.example;<br /><br />import org.slf4j.Logger;<br />import org.slf4j.LoggerFactory;<br />import org.springframework.context.ConfigurableApplicationContext;<br />import org.springframework.context.support.ClassPathXmlApplicationContext;<br /><br />/**<br /> * Small MongoDB application that uses spring data to interact with MongoDB.<br /> * <br /> */<br />public class MongoDBApp {<br /><br />  static final Logger logger = LoggerFactory.getLogger(MongoDBApp.class);<br /><br />  public static void main( String[] args ) {<br />    logger.info("Bootstrapping MongoDemo application");<br /><br />    ConfigurableApplicationContext context = new ClassPathXmlApplicationContext("META-INF/spring/applicationContext.xml");<br /><br />    PersonRepository personRepository = context.getBean(PersonRepository.class);<br /><br />    // cleanup person collection before insertion<br />    personRepository.dropPersonCollection();<br /><br />    //create person collection<br />    personRepository.createPersonCollection();<br /><br />    for(int i=0; i&lt;20; i++) {<br />      personRepository.insertPersonWithNameJohnAndRandomAge();<br />    }<br /><br />    personRepository.logAllPersons();<br />    logger.info("Finished MongoDemo application");<br />  }<br />}<br /><br /></pre>All this application does for now is setup a connection with MongoDB, insert 20 persons (documents),&nbsp; fetch them all and write the information to the log. As a first experiment this was quite fun to do.<br /><br /><h2> Conclusion</h2>As you can see with Spring Data it's quite easy to get some basic functionality within only a couple of minutes. All the sources mentioned above and a working project can be found on <a href="https://github.com/jreijn/spring-mongo-demo">GitHub</a>. It was a fun first experiment and I already started working on a bit more advanced project, which combines Spring Data, MongoDB, HTML5 and CSS3. It will be on GitHub shortly together with another blog post here so be sure to come back.</div>
<h2>Comments</h2>
<div class='comments'>
<div class='comment'>
<div class='author'>Tuan Minh</div>
<div class='content'>
Very clear and easy to understand. Thanks Jeroen</div>
</div>
<div class='comment'>
<div class='author'>Tallahassee</div>
<div class='content'>
Very useful code. Thanks Jeroen</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Hi Jeryl,<br /><br />it seems to me that you can do this quite easily with geospatial support in spring data. See http://static.springsource.org/spring-data/data-mongodb/docs/current/reference/html/mongo.core.html#mongo.geospatial for more info.<br /><br />Jeroen</div>
</div>
<div class='comment'>
<div class='author'>Jeryl Cook</div>
<div class='content'>
Can&#39;t filter? say you want to filter the results? is that possible?  like you want all persons near point(1,1) with age of 35.....i can&#39;t figure out how to do this in Spring Data/MongoDB GeoNear ?</div>
</div>
<div class='comment'>
<div class='author'>santosh yadav</div>
<div class='content'>
This sample is really very help full for me, so thanks!!!!!!</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
The sources can be found here: https://github.com/jreijn/spring-mongo-demo</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Can you add source codes of this example?</div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Do we have to use maven? I just want to create console application and I want to send some data to MongoDB.<br />Can you do configuration not only xml but also annotations.<br />Regards</div>
</div>
<div class='comment'>
<div class='author'>Sarthak</div>
<div class='content'>
Using your &#39;seed&#39; project, i was able to get things going:<br /><br />I was following up more on how to create Repository Interfaces mentioned in ,<br />http://static.springsource.org/spring-data/data-mongo/docs/current/reference/html/, section 6, as it looks like I want to delegate the work of creating query methods to spring and only define my custom query methods with @Query annotations in the Repository interface. This way, i can delegate the responsibility of creating methods for custom queries to spring. <br /><br />In your example, you have used Repository class and annotated it with @Repository and left it up to spring&#39;s auto-scanning to identify the repo objects. <br /><br />Have you used the way mentioned in the link that i have shared ? What do you think will be the best way to proceed?<br /><br />I appreciate your help on this. <br /><br />Thanks <br />Sarthak</div>
</div>
<div class='comment'>
<div class='author'>Sarthak</div>
<div class='content'>
this was really helpful.. i am able to use your code as &#39;seed&#39; code to get all the integration going...!! this is simply great..!! <br /><br />Thanks again..</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Hi John,<br /><br />Thank you for the feedback! I had already updated the sample on Github some time ago. I&#39;ve now also updated the article!<br /><br />Jeroen</div>
</div>
<div class='comment'>
<div class='author'>John Kern</div>
<div class='content'>
Hello, <br /><br />First I would like to thank Jeroen for publishing this. I found it helpful. <br /><br />For future readers, I noticed the packages have changed around a bit. Classes in package org.springframework.data.document.mongodb have moved to org.springframework.data.mongodb.core. <br /><br />-john</div>
</div>
<div class='comment'>
<div class='author'>Shubham | Techcrank</div>
<div class='content'>
will try this.. mongo db looks impressive..</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
@KCOtzen: You can provide an extra constructor argument to the MongoTemplate that contains the user credentials. See http://support.cloudfoundry.com/entries/20018322-alert-mongo-bindings-have-changed for a small example at the bottom of the topic.</div>
</div>
<div class='comment'>
<div class='author'>KCOtzen</div>
<div class='content'>
what if i want to connect with a mongo db with auth mode? I mean with user and pass.</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
@Rameez:<br /><br />I do not fully understand what you want to achieve? If you have a domain object you want to skip the value only once of all the time?</div>
</div>
<div class='comment'>
<div class='author'>Rameez Raja</div>
<div class='content'>
How to skip the value in domain objects without changing the domain object class or using @Transient..</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Awesome! I think both technologies are really interesting. I hope this post gave you a quick starter.</div>
</div>
<div class='comment'>
<div class='author'>Jose Fernandez</div>
<div class='content'>
I was just about to try this very same thing, so thanks!</div>
</div>
</div>
