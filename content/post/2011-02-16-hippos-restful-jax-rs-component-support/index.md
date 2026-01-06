---
categories:
- Software Engineering
comments: false
date: "2011-02-16T00:00:00Z"
title: HIPPOs RESTful JAX-RS Component Support and Spring Android
aliases:
- hippos-restful-jax-rs-component-support
---


The new <a href="http://www.onehippo.com/en/products/cms/try">Hippo CMS 7.5 release</a> brings some quite interesting features. The most interesting new feature for me was support for RESTful components within the Hippo Site Toolkit (HST-2 v2.20.01). Being able to expose data in a RESTful manner opens up a whole new set of possibilities for external application developers.

As you might have read in my <a href="http://blog.jeroenreijn.com/2011/02/working-with-android-layouts-and.html">previous post</a>, I'm building a sample application to get acquainted with the Android platform. My previous post was mainly focussed on layouts and ListViews, but this time I will be focussing on information retrieval from an external <a href="http://en.wikipedia.org/wiki/Representational_State_Transfer">REST</a> service. That's why I've used the default REST service that comes with the online <a href="http://www.demo.onehippo.com/">Hippo GoGreen demo</a> as my source of information.  The GoGreen REST service exposes a list of 'top products' with additional information about the products that can be used nicely for this demo project, but first let's start at the beginning.

## Getting started with RESTful HST-2 components

From what I've seen in the documentation and in the GoGreen source code, there are two different methods of exposing data with the RESTful components.
<ol><li>The data can be exposed based on the primary JCR NodeType of a resource inside the Hippo repository. The HST-2 sitemap will determine the URLs of the items based on the relative path of the items inside the repository. This approach can be done with the `JaxrsRestContentPipeline`.</li><li>A sitemap item (or mount) can be configured as a <span class="Apple-style-span" style="font-family: 'Courier New',Courier,monospace;">JaxrsRestPlainPipeline</span><i>.</i> By doing so, the HST will try to match the request within a <a href="http://en.wikipedia.org/wiki/JAX-RS">Jax-RS</a> based resource provider component that handles all the (relative) URL matching from there on.   </li></ol><ul></ul>In this example I will use the `JaxrsRestPlainPipeline` approach, which is also used by the Hippo GoGreen demo to create the 'top products' resource. The response output of a REST pipeline can be in all kinds of different formats. For this example we will use <a href="http://en.wikipedia.org/wiki/JSON">JSON</a>, but you can also use XML instead.

### Configuration

The first step in the proces of setting up our own REST service is to create an HST mount. The configuration for our mount has to look something similar to :

``` xml
<sv:node sv:name="restapi">
  <sv:property sv:name="jcr:primaryType" sv:type="Name">
      <sv:value>hst:mount</sv:value>
  </sv:property>
  <sv:property sv:name="hst:alias" sv:type="String">
    <sv:value>restapi</sv:value>
  </sv:property>
  <sv:property sv:name="hst:authenticated" sv:type="Boolean" >
    <sv:value>false</sv:value >
  </sv:property>
  <sv:property sv:name="hst:isSite" sv:type="Boolean">
    <sv:value>false</sv:value>
  </sv:property>
  <sv:property sv:name="hst:mountpoint" sv:type="String">
    <sv:value>/hst:hst/hst:sites/rest-live</sv:value>
  </sv:property>
  <sv:property sv:name="hst:mountsite" sv:type="String">
    <sv:value>site</sv:value>
  </sv:property>
  <sv:property sv:name="hst:namedpipeline" sv:type="String">
    <sv:value>JaxrsRestContentPipeline</sv:value>
  </sv:property>
  <sv:property sv:name="hst:roles" sv:type="String">
    <sv:value>everybody</sv:value>
  </sv:property>
  <sv:property sv:name="hst:showport" sv:type="Boolean">
    <sv:value>true</sv:value>
  </sv:property>
  <sv:property sv:name="hst:subjectbasedsession" sv:type="Boolean">
    <sv:value>true</sv:value>
  </sv:property>
  <sv:property sv:name="hst:types" sv:type="String">
    <sv:value>rest</sv:value>
  </sv:property>
</sv:node >
```

As you can see there is lot to configure for a mount, but I don not want to go into much detail. The next step is to setup an HST sitemap for this mount. In the configuration above, our mount uses a default namedpipeline of type `JaxrsRestContentPipeline`, since we want to use a  `JaxrsRestPlainPipeline`, we can override the type of pipeline by specifying the `hst:namedpipeline` property on an HST sitemap item for this mount, for example for the sitemap item called 'topproducts'.

``` xml
<sv:node sv:name="topproducts">
  <sv:property sv:name="jcr:primaryType" sv:type="Name">
    <sv:value>hst:sitemapitem</sv:value>
  </sv:property>
  <sv:property sv:name="hst:namedpipeline" sv:type="String">
    <sv:value >JaxrsRestPlainPipeline</sv:value>
  </sv:property >
</sv:node>
```

### Spring Configuration
Now after we stored the HST-2 configuration in the repository, the next step is to register our new component as a plain resource provider in our website Spring configuration. We can do this by creating a file called ```custom-jaxrs-resources.xml``` in the ```src/main/resources/META-INF/hst-assembly/overrides/``` folder of our Hippo site project with the following content.

``` xml
<?xml version="1.0" encoding="UTF-8"? >
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
  xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.0.xsd" >
  <import resource="classpath:/org/hippoecm/hst/site/optional/jaxrs/SpringComponentManager-rest-jackson.xml" />
  <import resource="classpath:/org/hippoecm/hst/site/optional/jaxrs/SpringComponentManager-rest-plain-pipeline.xml" / >
  <import resource="classpath:/org/hippoecm/hst/site/optional/jaxrs/SpringComponentManager-rest-content-pipeline.xml" / >
  <!-- Custom JAX-RS REST Plain Resource Providers to be overriden.-->
  <bean id="customRestPlainResourceProviders" class="org.springframework.beans.factory.config.ListFactoryBean">
      <property name="sourceList">  
        <list>    
          <bean class="org.apache.cxf.jaxrs.lifecycle.SingletonResourceProvider">      <constructor-arg>        
            <bean class="com.onehippo.gogreen.jaxrs.services.TopProductsResource" />
          </constructor-arg>
        </bean>
      </list>
    </property>
  </bean>
</beans>
```
With this configuration in place the HST-2 has knowledge of our custom resource and the `TopProductsResource` can start creating the response.Now let's take a look at our `TopProductsResource`.

``` java
@Path("/topproducts/")
public class TopProductsResource extends AbstractResource {

  @GET@Path("/topproducts/")
  public List<ProductLinkRepresentation> getProductResources(@Context HttpServletRequest servletRequest, @Context HttpServletResponse servletResponse, @Context UriInfo uriInfo,          @QueryParam("sortby") @DefaultValue("hippogogreen:rating") String sortBy,           @QueryParam("sortdir") @DefaultValue("descending") String sortDirection,          @QueryParam("max") @DefaultValue("10") String maxParam) {
    List<ProductLinkRepresentation > productRepList = new ArrayList<ProductLinkRepresentation >();    
    HstRequestContext requestContext = getRequestContext(servletRequest);          
    try {  
      Node mountContentNode = getNodeFromMount(requestContext);        
      HstQueryResult result = getHstQueryResult(sortBy, sortDirection, maxParam, requestContext, mountContentNode);        
      HippoBeanIterator iterator = result.getHippoBeans();        
      while (iterator.hasNext()) {            
        Product productBean = (Product) iterator.nextHippoBean();                          
        if (productBean != null) {
          ProductLinkRepresentation productRep = new ProductLinkRepresentation(requestContext).represent(productBean); productRepList.add(productRep);            
        }        
      }    
    } catch (Exception e) {      
      log.warn("Failed to retrieve top products. {}", e);              
      throw new WebApplicationException(e);    
    }          
    return productRepList;
  }
}
```

The `TopProductsResource` has a `@Path("/topproducts/")` annotation set on the class level. This is what's making the request to '/topproducts' being handled by this specific resource. As you can see the only other thing the resource does is perform the query from the `getProductResources()` method. Take a look at the full <a href="http://svn.onehippo.org/repos/hippo/hippo-demos/hippo-go-green/trunk/site/src/main/java/com/onehippo/gogreen/jaxrs/services/TopProductsResource.java">source code</a> for more details on the `TopProductsResource` class.

### Response output

Now that we've setup the configuration and put the component in place, let's take a look at our actual response.  You can see what the response of the <span class="Apple-style-span" style="font-family: 'Courier New',Courier,monospace;">TopProductsResource</span> is if you go to the following URL:<code>http://www.demo.onehippo.com/restapi/topproducts?_type=json</code>

<i>Note: the URL might not be available at the time you try it, because the GoGreen demo is restarted every 30 minutes with a fresh set of content. If the URL does not work try again in 5 minutes.</i>

Since we specified the response type as JSON, the actual response should look something like what is shown below. For readability I've removed some properties, but I guess you get the idea.
``` javascript
[
  {  
   productLink: "http://www.demo.onehippo.com/restapi/products/food/2010/07/organic-cotton-reusable-lunch-bag./",
   price: 34,  
   rating: 5,  
   smallThumbnail: "http://www.demo.onehippo.com/binaries/smallthumbnail/content/gallery/products/2010/06/organic-lunch-bag.jpg",  
   localizedName: "Organic Cotton Reusable Lunch Bag",  
   primaryNodeTypeName: "hippogogreen:product"
 },
 {  
  productLink: "http://www.demo.onehippo.com/restapi/products/food/2010/07/birch-wood-compostable-cutlery./",
  price: 5,  
  rating: 4.25,  
  smallThumbnail: "http://www.demo.onehippo.com/binaries/smallthumbnail/content/gallery/products/2010/07/wooden-cutlery.png",  
  localizedName: "Birch Wood Compostable Cutlery",  
  primaryNodeTypeName: "hippogogreen:product"
 }
]
```

As you can see the response is quite simple and contains an array of product items with their properties.If you want to know more about RESTful Component support there is a nice <a href="https://wiki.onehippo.com/display/HST2/RESTful+JAX-RS+Component+Support+in+HST-2">page</a> on the HST-2 wiki. Now let's move on with the Android part of this post.

## Spring Android

Android version 2.2 has native support for handling JSON. I tried that, but I recently discovered <a href="http://www.springsource.org/spring-android">Spring Android</a>. Spring Android is quite new and gives you an easy to use <a href="http://static.springsource.org/spring-android/docs/1.0.x/reference/html/rest-template.html" target="_blank">REST client</a>.
The reason I chose to use Spring Android is that it takes less code to handle requests then by doing it the native Android way with the default HttpClient. Now when we combining Spring Android with <a href="http://jackson.codehaus.org/">Jackson</a> it makes working with JSON really easy. All you have to do is create a mapping class, so that Jackson knows how to map the response array.To be able to work with the JSON response we will need the following three libraries in our Android project.

<ul><li>spring-android-rest-template-1.0.0.M2.jar</li><li>jackson-core-asl-1.7.1.jar</li><li>jackson-mapper-asl-1.7.1.jar</li></ul>

### Using Spring Android

For my Android application I've created a service class called `ProductService`.

``` java
public class ProductService {

  private static final String RESTAPI_BASE_URI = "http://www.demo.onehippo.com/restapi";
  private static final String RESTAPI_RESPONSE_TYPE = "_type=json";

  public static ArrayList<Product > getAllProductsFromHippo() {
    ArrayList<Product > products = new ArrayList<Product >();  
    RestTemplate restTemplate = new RestTemplate();    
    List<HttpMessageConverter<? > > messageConverters = restTemplate.getMessageConverters();
     //add the Jackson mapper for easy mapping of JSON to POJO's  
    messageConverters.add(new MappingJacksonHttpMessageConverter());  

    String url = RESTAPI_BASE_URI + "/topproducts./?" + RESTAPI_RESPONSE_TYPE;  
    Product[] productsFromHippo = restTemplate.getForObject(url, Product[].class);  products.addAll(Arrays.asList(productsFromHippo));

    return products;
  }
}
```
As you can see the `getAllProductsFromHippo` method uses the Spring Android `RestTemplate` in combination with the `MappingJacksonHttpMessageConverter` to map the JSON response to an array of `Product` classes. Let's have a closer look at a `Product` class.

``` java
package org.onehippo.gogreen.android.data;

import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.codehaus.jackson.annotate.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Product {

  @JsonProperty
  private String localizedName;

  public String getLocalizedName() {    
    return localizedName;
  }
  public void setLocalizedName(final String localizedName) {    
    this.localizedName = localizedName;
  }
}
```

<a href="http://3.bp.blogspot.com/-rs4t8FsokCc/TVvDXoPj15I/AAAAAAAAAcg/Tp_4bhVK2NM/s1600/android_products_list.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" src="http://3.bp.blogspot.com/-rs4t8FsokCc/TVvDXoPj15I/AAAAAAAAAcg/Tp_4bhVK2NM/s320/android_products_list.png" height="320" width="193" /></a>The `Product` class is quite simple. It only contains the localized name (for now). To make sure the mapping succeeds, I've also added the annotation `JsonIgnoreProperties` , so that it will ignore unknown properties during the mapping phase. Now if we provide the list of `Product` items to the Android `ArrayAdapter`, which is used by our ListView we will see all the items in the list returned by the HST-2 REST service.

## Resources used

The following resources were used to create this post:
<ul><li><a href="http://svn.onehippo.org/repos/hippo/hippo-demos/hippo-go-green/trunk/">Hippo GoGreen demo source code</a></li><li><a href="http://jackson.codehaus.org/">Jackson (JSON parser)</a></li><li><a href="http://www.springsource.org/spring-android">Spring Android</a></li><li><a href="https://wiki.onehippo.com/display/HST2/RESTful+JAX-RS+Component+Support+in+HST-2">RESTful Jax-RS component support in HST-2</a></li></ul>
