---
comments: false
date: "2015-02-26T00:00:00Z"
title: A RESTful API for the Hippo CMS content repository
aliases:
- a_rest_api_for_the_hippocms_content_repository
---

Over the last 2-3 years I've seen many moments during a project implementation where having an out of the box JCR RESTful API could have helped. Key areas where having such an API were deployment automation and data imports/exports. As a starting point having an API for managing JCR nodes and properties would have been a first step in the right direction. By default Apache Jackrabbit 2.X does not have this out of the box. However Apache Jackrabbit 3.0 (Oak) and current versions of JBoss Modeshape do support this, so in case Hippo CMS switches over to Apache Oak we might need to revise this add-on.

A few months ago I decided that it was long due to have this kind of support for Hippo CMS, so I decided to start a new project on Github. I’ve named it the "Hippo RESTful web services add-on” and the project focusses on providing a RESTful API directly on top of the content repository, so in that sense it takes a different approach from the [RESTful API support Hippo CMS offers in it's delivery tier](http://www.onehippo.org/library/concepts/rest/restful-jax-rs-component-support-in-hst-2.html). The main focus for now is on data export/import and deployment automation.

While developing the add-on I’ve read many different opinions on REST api design and what REST truly means. If you would ask people what they think REST stands for you might be quite surprised. Last year I attended a talk by Stefan Tilkov on ["REST: I don't Think it Means What You Think it Does”](https://www.youtube.com/watch?v=pspy1H6A3FM). While he asked the audience what REST meant to them there were quite some different answers. If you haven’t seen the talk you should take a look. For now I took the most pragmatic approach and we'll need to see how you guys are working with the API before we can improve it.

The add-on does not just focus on providing JCR REST endpoints, so the project contains other endpoints (user and group management) and I'm planning to add more endpoints in the next couple of months. You might be interested in the next [milestones](https://github.com/jreijn/hippo-addon-restful-webservices/milestones) for the add-on.

## The available JCR endpoints

The add-on contains 3 JCR based API endpoints:

```
/nodes{path:.*}
/properties{path:.*}
/_query
```  

As you can see they are pretty self explaining. Using them is quite easy and straight forward. For interaction with the system all you need is a command line utility like [curl](http://en.wikipedia.org/wiki/CURL) or [HTTPie](http://httpie.org). If you don't know HTTPie (an alternative command line client to talk to JSON based REST APIs) it's really worth checking out. Talking to REST endpoints most of the time happens from a piece of code, so in that case all you need is a http client library, which is available in many different frameworks and programming languages.

The API only exposes JSON based endpoints, because I think JSON is developer friendly, lightweight, easy to read and there are many libraries available for parsing JSON responses.

## Communicating with the endpoints

Now let's see some examples of the usage of the API. To communicate with the RESTful API we will need to use Basic authentication. For these examples we'll use ``curl`` to communicate with the endpoints. I personally prefer HTTPie more, because it saves you some additional headers.

### Working with JCR nodes
Let's start out with a simple fetch of the root JCR node.

``` bash
$ curl -X GET -u admin:admin http://localhost:8080/cms/rest/api/nodes/
```

which will result in:

``` json
{
    "identifier": "cafebabe-cafe-babe-cafe-babecafebabe",
    "mixinTypes": [
        "mix:referenceable"
    ],
    "name": "",
    "nodes": [],
    "path": "/",
    "primaryType": "rep:root",
    "properties": []
}
```

Now the Node API allows us also to iterate more deep down the tree by using the ``depth`` query parameter.

``` bash
$ curl -X GET -u admin:admin http://localhost:8080/cms/rest/api/nodes/?depth=1
```

In case we want to add a new node all we need to do is:

``` bash
$ curl -H "Content-Type: application/json" -X POST -u admin:admin http://localhost:8080/cms/rest/api/nodes/ -d '
{
  "name": "test",
  "primaryType": "nt:unstructured"
}'
````

Which will create a new node called _test_ of type 'nt:unstructured' directly under the root node.

### Working with JCR properties

Now in case we want to just add a property to the newly created test node we can use the _/properties_ endpoint like this:

``` bash
$ curl -H "Content-Type: application/json" -X POST -u admin:admin http://localhost:8080/cms/rest/api/properties/test -d '
{ "name": "test",
  "type": "String",
  "multiple":"false",
  "values":["test value"]
}'
```

### Querying the JCR repository

Querying the repository is just as straight forward. The /_query endpoint allows you to use both GET and POST, but for larger request bodies I usually tend to use the POST method.

``` bash
curl -H "Content-Type: application/json" -XPOST -u admin:admin http://localhost:8080/cms/rest/api/_query -d '{
  "statement": "/jcr:root/content//element(*,hippo:document)",
  "language": "xpath",
  "limit": 10
}'
```

Which will return nodes found inside the repository.

``` json
{
    "hits": 5,
    "nodes": [
        {
            "fields": {
                "jcr:path": "/content/documents/myhippoproject",
                "jcr:primaryType": "hippostd:folder",
                "jcr:score": "95"
            },
            "link": "http://localhost:8080/cms/rest/api/nodes/content/documents/myhippoproject",
            "score": 0.09479197859764099
        },
        {
            "fields": {
                "jcr:path": "/content/documents/myhippoproject/common/homepage/homepage",
                "jcr:primaryType": "myhippoproject:textdocument",
                "jcr:score": "95"
            },
            "link": "http://localhost:8080/cms/rest/api/nodes/content/documents/myhippoproject/common/homepage/homepage",
            "score": 0.09479197859764099
        },
        ...
    ],
    "took": 4
}

```

Now if you're not such a command line hero, you can also play around with the Swagger UI, which is incorporated in the [demo project](https://github.com/jreijn/hippo-addon-restful-webservices-demo). If you build the demo project you can just navigate to http://localhost:8080/cms/swagger/ and play around with the API.

![Swagger UI for Hippo CMS](/assets/rest/swagger-rest-api.png)

The nice thing about [Swagger](http://swagger.io/) is that it allows you to easily documment your REST API by means of annotations inside your resource and representation code. I've used that throughout the project, so that the documentation can be generated.

## Final thoughts

In this post we've discussed the low-level JCR RESTful API. This can be useful in several scenarios, but the goal of the add-on is also to provide more high level resource APIs. The first two are already added to the add-on; endpoints for managing Users and Groups. Next up will be a resource endpoint for adding assets to the system.

Having such an API also allows for the development of some lightweight tools that can interact with the API. I've already created a bulk asset import tool, which I will be open sourcing soon. In case you are interested be sure to follow me on github.

Now if you have other ideas, make sure to create an issue in the [github project](https://github.com/jreijn/hippo-addon-restful-webservices/) or in case you want to contribute be sure to send in a pull request or request to become a team member of the project.
