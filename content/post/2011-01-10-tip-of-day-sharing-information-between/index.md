---
categories:
- Software Engineering
comments: true
date: "2011-01-10T00:00:00Z"
title: 'Tip of the day: sharing information between HST components'
aliases:
- tip-of-day-sharing-information-between
---

If you're working as a web developer with <a href="http://www.onehippo.org/">Hippo CMS</a>, I guess you have written quite a few HST components. I presume that by now you will have a basic understanding of what HST components can and can't do.
I've had the situation myself where I wanted to share some information between components on a single page. I first thought I could simply achieve this by adding an attribute to the request, but that didn't work. To show you what you **can** do, let's first start of with a bit of background information about what's actually going on inside the HST, when an incoming request is being processed.

## HST request processing

Let's first have a look at a page definition. In a traditional HST page definition you have a tree of components. The figure below describes a normal page layout definition.

<div class="separator" style="clear: both; text-align: center;"><a href="http://3.bp.blogspot.com/_hd6Y7yyFK7E/TSotWDmyVCI/AAAAAAAAAbE/JU5pIKNV2G4/s1600/page-definition.png" imageanchor="1"><img border="0" src="http://3.bp.blogspot.com/_hd6Y7yyFK7E/TSotWDmyVCI/AAAAAAAAAbE/JU5pIKNV2G4/s1600/page-definition.png" /></a></div>

As you can see the page definition in the above figure has a root component (the page definition itself) with three child components: component 1, component 2 and component 3. Now the follow flow chart shows what the HST will do when it's handling a request.
<div class="separator" style="clear: both; text-align: center;"><a href="http://4.bp.blogspot.com/_hd6Y7yyFK7E/TSoujHT4oNI/AAAAAAAAAbM/4cegvK5fH9U/s1600/HST-request-process-simple.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" src="http://4.bp.blogspot.com/_hd6Y7yyFK7E/TSoujHT4oNI/AAAAAAAAAbM/4cegvK5fH9U/s1600/HST-request-process-simple.png" /></a></div>
This flow chart of course does not show all the steps taken by the HST,
but it should give you a good impression of what's going on.

At first the HST will lookup the correct page definition based on the HST sitemap. Once the correct page definition has been found the HST will start processing.

The entire component tree for the current page definition is fetched and once the tree is there, the HST will use the AggregationValve to run down the component tree and invoke the doBeforeRender() methods of all of the available components.

Once the entire component three has been processed in the 'before render phase', it will start processing the doRender() methods of all the components, so that the output of every single component will be generated and aggregated to end up in the end result.

Now the important part to know here is that each invoked component will have it's own individual HStRequest object. Now if you want to share any kind of information you cannot simply use the HstRequest, because all the information is gone while processing the next component.

However there is an object attached to these individual HstRequest objects and that is the HstRequestContext. The HstRequestContext hold some quite useful information, which you help support your components, but you can also add your own information by setting some attribute.

Enough theory for now. If you would like to have a deeper knowledge of the HST request processing, the proces is described in much more detail on the <a href="https://wiki.onehippo.com/display/HST2/HST-2+Request+Processing">HST2 wiki</a>.

## Now for some code

As an example let's take the usage of banners on a page. Let's say we have a boolean flag configured somewhere, which will define if banners should be shown on our page.

Let's presume that a banner can be shown by multiple components on a page. If we take figure 1, we could say that a banner could appear above component 2 and underneath component 3.
Now we could let both component 2 and component 3 figure out if the banners should be shown, but we could also share the information if component 2 or 3 is executed first, so that the other component does not have to read the configuration over again. The resulting code is quite simple. Let's have a look.

``` java
@Override
public void doBeforeRender(HstRequest request, HstResponse response) {

  boolean isBannerEnabled;
  HstRequestContext requestContext = request.getRequestContext();

  //let's see if the flag has been set on the request context
  if(requestContext.getAttribute(IS_BANNER_ENABLED_ATTRIBUTE)!=null){
    isBannerEnabled = (Boolean)requestContext.getAttribute(IS_BANNER_ENABLED_ATTRIBUTE);
  } else {
    //nothing on the request context, so lets figure it out
    isBannerEnabled = isBannerEnabled(request);
    //put the result on the request context so all other components can benefit
    requestContext.setAttribute(IS_BANNER_ENABLED_ATTRIBUTE, isBannerEnabled);
  }
  //put on the request for the current component
  request.setAttribute(IS_BANNER_ENABLED_ATTRIBUTE, isBannerEnabled);
}

/**
 * Simply return true for this example.
 */
boolean isBannerEnabled(HstRequest request) {
  return true;
}
```

As you will see the actual code is really simple. All you will have to do is store information on the HstRequestContext. That's it. Well these were my 2 cents for today. Go and have fun and try to leverage the power of the HST2.
