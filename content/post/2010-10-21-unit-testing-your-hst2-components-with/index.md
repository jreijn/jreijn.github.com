---
categories:
- Software Engineering
comments: true
date: "2010-10-21T00:00:00Z"
title: Unit testing your HST2 components with EasyMock
aliases:
- unit-testing-your-hst2-components-with
---

Quality is an important aspect of every software development project. Writing unit tests is just one part of keeping an eye on quality. In this post I will try to explain how you can unit test your <a href="http://www.onehippo.org/site-toolkit/index.html">Hippo Site Toolkit (HST2)</a> components, so you can be sure that the component still behaves as expected even after multiple maintenance cycles.

## A mocking framework
Unit testing is the testing of software units (for instance HST2 components) in isolation. However, most units do not work alone, but they collaborate with other units, like the HST2 does for instance with a running JCR repository and a live HttpServletRequest (wrapped inside an HstRequest). To test a unit in isolation, we have to simulate these collaborations in our tests.
One way of working around such collaborations is by using Mock objects. A Mock Object is a test-oriented replacement for such a collaborator. It is configured to simulate the object that it replaces in a simple way. For this post I use <a href="http://www.easymock.org/">EasyMock</a>, but there are other mocking frameworks out there.

## Setting up your environment
If you are regular reader, you might have noticed that I've been using Maven2 in most of my posts, so this time will not be different. To be able to test your HST components, you will need to add the following dependencies to your project/module pom.xml.

``` xml
<dependency>
  <groupId>junit</groupId>
  <artifactId>junit</artifactId>
  <version>4.5</version>
  <scope>test</scope>
</dependency>

<dependency>
  <groupId>org.easymock</groupId>
  <artifactId>easymock</artifactId>
  <version>2.5.2</version>
  <scope>test</scope>
</dependency>

<dependency>
  <groupId>org.easymock</groupId>
  <artifactId>easymockclassextension</artifactId>
  <version>2.5.2</version>
  <scope>test</scope>
  <exclusions>
    <exclusion>
      <groupId>cglib</groupId>
      <artifactId>cglib-nodep</artifactId>
    </exclusion>
  </exclusions>
</dependency>

<dependency>
  <groupId>org.onehippo.cms7.hst</groupId>
  <artifactId>hst-mock</artifactId>
  <scope>test</scope>
</dependency>
```
Now that we have setup all the needed dependencies let's create an HST component to get started.

## Basic HST2 Component
So let's start of with a simple/basic HST2 component. Here we have a simple component that tries to get a HippoBean wrapping a JCR node for the current request and puts the bean as an attribute on the request.

```java
import org.hippoecm.hst.component.support.bean.BaseHstComponent;
import org.hippoecm.hst.content.beans.standard.HippoBean;
import org.hippoecm.hst.core.component.HstComponentException;
import org.hippoecm.hst.core.component.HstRequest;
import org.hippoecm.hst.core.component.HstResponse;

public class AbstractBaseHstComponent extends BaseHstComponent{

    @Override
    public void doBeforeRender(HstRequest request, HstResponse response)
        throws HstComponentException {

        HippoBean bean = getContentBean(request);
        if(bean!=null) {
            request.setAttribute("document",bean);
        }
    }
}
```
Looks quite simple right? Now let's move on to the test.

## The actual test
Now that we've seen what our component looks like, let's take a look at how we can test this class. The component doesn't do a lot, but there are a couple of things that we want to test:

<ul><li>that the getContentBean method is called</li><li>when the bean is not null the bean is set as an attribute on the request</li><li>there is an attribute on the request with the name document</li><li>the document from the request attribute is the same as the one put on the request</li></ul>
So now let's translate that into some code.

Before we can actually test our doBeforeRender method we need to do some setup before we can continue.

```java
MockHstRequest fakeRequest;
MockHstResponse fakeResponse;
AbstractBaseHstComponent component;

@Before
public void setUp() throws Exception {
    fakeRequest = new MockHstRequest();
    fakeResponse = new MockHstResponse();
    component = createMockBuilder(AbstractBaseHstComponent.class).
                addMockedMethod("getContentBean", HstRequest.class).
                createMock();
}
```
Now looking at this setUp() method, you will notice that at first we create mocked versions of a request and response. These objects are necessary because they are parameters for our method under test. In a normal environment these objects will be created by the servlet container, but since we're unit testing we have to create these ourselves.  

Next to that we create a mocked version of our AbstractBaseHstComponent. We do this because we need to mock the getContentBean method, which in a normal live environment performs interaction to a live JCR repository. The logic for getting the bean based on repository configuration is not useful for our test, so we mock the method and create a partial mock of the class.

Now let's have a look at the total test case and the actual test method.

``` java
import org.hippoecm.hst.content.beans.standard.HippoBean;
import org.hippoecm.hst.content.beans.standard.HippoDocument;
import org.hippoecm.hst.core.component.HstRequest;
import org.junit.Before;
import org.junit.Test;
import org.hippoecm.hst.mock.core.component.MockHstRequest;
import org.hippoecm.hst.mock.core.component.MockHstResponse;
import static org.easymock.classextension.EasyMock.*;
import static org.junit.Assert.*;

/**
 * Test for {@link com.jeroenreijn.site.components.AbstractBaseHstComponent}
 */
public class AbstractBaseHstComponentTest {

    MockHstRequest fakeRequest;
    MockHstResponse fakeResponse;
    AbstractBaseHstComponent component;

    @Before
    public void setUp() throws Exception {
        fakeRequest = new MockHstRequest();
        fakeResponse = new MockHstResponse();
        component = createMockBuilder(AbstractBaseHstComponent.class).
                addMockedMethod("getContentBean", HstRequest.class).
                createMock();
    }

    @Test
    public void testDocumentOnRequestAfterDoBeforeRender() throws Exception {

        HippoBean bean = new HippoDocument();

        //record the expected behavior
        expect(component.getContentBean(fakeRequest)).andReturn(bean);

        //stop recording and switch the mocked Object to replay state.
        replay(component);

        component.doBeforeRender(fakeRequest,fakeResponse);

        //verify the specified behavior has been used
        verify(component);

        assertSame(fakeRequest.getAttribute("document"),bean);
    }
}
```
As you might notice, the testDocumentOnRequestAfterDoBeforeRender() method tests the doBeforeRender method and checks all of the above requirements.

## The next step
Even though you can create a mock of most objects quite easily, it's much better to have some native support/provided mock objects for most HST2 classes. Therefore I've added a <a href="https://issues.onehippo.com/browse/HSTTWO-1257">patch to JIRA</a>, which adds more mocked classes that can be used for testing, so you do not have to mock explicit methods. Next to that it will create test maven artifact, which you can use when testing your HST component without having to mock explicit methods or objects yourself.
Let me know if you run into any issues or have some ideas on improvement. It can make all our lives better.

<i>Note/Update: This post was written at a time when the mock  classes were not part of Hippo core (version 7.4). In the meantime this has changed  and the classes can now be found in hst-mock artifact.</i>


ps. I've just noticed that Shane Smith of iProfs created a <a href="http://blog.iprofs.nl/2010/10/19/hst-and-mockito-sitting-on-a-tree/">similar post</a> with using <a href="http://mockito.org/">Mockito</a>.
