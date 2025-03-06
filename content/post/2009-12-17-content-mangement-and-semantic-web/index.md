---
categories:
- Software Engineering
comments: true
date: "2009-12-17T00:00:00Z"
title: Content mangement and the semantic web
---

<img align="left" alt="" border="0" id="BLOGGER_PHOTO_ID_5390347010206616578" src="http://4.bp.blogspot.com/_hd6Y7yyFK7E/Ss5cC-d0TAI/AAAAAAAAASM/JtnIYqZivhU/s320/Semantic-Web-Logo-by-W3C.png" style="padding-bottom: 10px; padding-right: 10px;" /> I came across the term 'semantic web' a couple of years ago, when <a href="http://www.betaversion.org/~stefano/linotype/">one of the original creators</a> of <a href="http://cocoon.apache.org/">Apache Cocoon</a> went of to work on the <a href="http://simile.mit.edu/wiki/SIMILE:About">SIMILE Project</a> at MIT. I didn't pay much attention to the concept of 'semantic web' back then, because I just started learning Apache Cocoon and still had a lot to learn.But over the last couple of months I've been doing some research on the currently available standards for providing semantic data on the web with a strong focus on <a href="http://en.wikipedia.org/wiki/RDFa">RD<span id="goog_1260951462840"></span><span id="goog_1260951462841"></span>Fa</a>.

## Content management

Working at <a href="http://www.onehippo.com/">Hippo</a>, a <a href="http://en.wikipedia.org/wiki/Content_management_system">CMS</a> vendor based in the Netherlands & USA, makes me think in content and publishing strategies. Publishing information to the web is one of our core businesses, but I've learned over the last couple of month we can enrich our publishing platform even more by providing semantic data. I started my journey by looking around if other CMS vendors are paying attention to semantic web standards. I noticed that only a few of the enormous amount of&nbsp; content management vendors actually put effort in providing semantic web functionalities for their end-users. I think that's a shame, because enrich your pages a lot.

This post should give you an insight on how you could create a website with embedded meta data (with Hippo), but let's first start with some basics.

## What's the idea behind the semantic web?

The current web is very well suited for being read by people like you and me. Computers however can only analyze the words on a page, but can not see the semantics of a piece of information on that specific page, that we as people <i>do</i> see. If you would allow the information on you page to be machine-readable, the computer would be able to analyze your page and extract much more information from it then just being a piece of text. That's where semantic web standards can help out. Standards for providing semantic data on the web are not new and some of them have already been available for quite some time. Probably the two most well known are: <a href="http://www.w3.org/RDF/">RDF</a> and <a href="http://microformats.org/">Microformats</a>. However recently <a href="http://en.wikipedia.org/wiki/RDFa">RDFa</a> has been getting a lot of attention by <a href="http://googlewebmastercentral.blogspot.com/2009/05/introducing-rich-snippets.html">Google</a>, <a href="http://developer.yahoo.com/searchmonkey/smguide/semantic_web.html">Yahoo</a> and now also the <a href="http://coi.gov.uk/guidance.php?page=315#section3d">UK government</a>.

## What is RDFa?

RDFa is short for “Resource Description Framework in attributes”.  This sounds a bit descriptive, but it means that RDFa provides a set of XHTML attributes, which in their turn provide a way of translating visual data on a page into machine-readable hints. So let's take a look at an example of how a simple web page is currently structured.

```
<html>
   <body>
     <h1>Content management and the semantic web</h1>
     <h2>Jeroen Reijn</h2>    
     <p>some information</p>
   </body>
</html>
```

As you can see in the above XHTML fragment, we have a page with a title, a subtitle and a small snippet of text inside the body of the page. By rendering this HTML fragment in the browser the visitor of this page will recognize this piece of text as being the title and author of the current article on the page. A machine however would need a bit more information to be sure the content can be identified as a title and author. That's where RDFa can help out. By using vocabularies, you can give meaning to specific pieces of content on a page.

Let's see what the above XHTML fragment would look like if we would use RDFa.
```
<html>
  <body xmlns:dc="http://purl.org/dc/elements/1.1/">
    <h1 property="dc:title">Content management and the semantic web</h1>
    <h2 property="dc:creator">Jeroen Reijn</h2>
    <p>some information</p>
  </body>
</html>
```

As shown in the example, the Dublin Core vocabulary is added to the page first. This is important to be able to use the properties inside the vocabulary later on. Once the vocabulary is in place, we can give meaning to fragments on the page. In the HTML fragment above the h1 is marked as the Dublin Core <i>title</i> attribute and the h2 as the Dublin Core <i>creator</i> attribute. With these properties in place a machine, like a search engine crawler, can now also store this as additional meta data of the page.One of the main advantages of RDFa is that your content can processed in a more efficient way, which in turn can make your page rank higher then it might have been before. Big search engines like Google and Yahoo already scan your website for RDFa embedded information, so why not use it?

## How to use RDFa in your (hippo) website?

<p><a href="http://www.onehippo.org/">Hippo CMS</a> is a content (centered) management system and it differs from other CMS's in such a way that the information inside the Hippo CMS content repository is not stored or identified as pages, but rather as content. In most cases even reusable content. To be more precise: information stored inside the content repository is stored as <a href="http://en.wikipedia.org/wiki/Content_repository_API_for_Java">JCR</a> nodes and/or properties. Since the data is just content and not bound to any front-end technology, you can either publish it as XML, (X)HTML with some help from the <a href="http://www.onehippo.org/site-toolkit">Hippo Site Toolkit</a> (HST) or any other format you might like.Now let's take the above HTML fragment as an example and let's see what this would look like on a content level. One of the most important things to mention here is that a JCR repository has the concept of nodetype definitions in which you can configure what your data model looks like. You could compare it with for instance a XML Schema or DTD for a piece of XML, but then for the nodes and properties available in a JCR repository.</p>

Let's first start with our content definition or in content management terms the document type. We will need three fields:
<ul><li>Title</li><li>Author</li><li>Body (rich-text field)</li></ul>If you would create a document type with the <a href="http://blogs.onehippo.org/arje/2009/08/an_improved_template_editor.html">Hippo CMS template editor</a>, the resulting nodetype definition will end up looking like this:

```
<'myproject'='http://www.myproject.org/nt/myproject/1.0'>
<'hippostd'='http://www.onehippo.org/jcr/hippostd/nt/2.0'>
<'hippo'='http://www.onehippo.org/jcr/hippo/nt/2.0'>
[myproject:text] > hippostd:publishable, hippostd:publishableSummary, hippo:document
- myproject:title (string)
- myproject:author (string)
+ myproject:body (hippostd:html)
```

As you can see all three fields are available and can be used later on by any client that can read from the Java content repository. To be able to render this type of information as XHTML, we will be using the Hippo Site Toolkit. The Hippo Site Toolkit uses the concept of mapping&nbsp; JCR nodes to simple Java beans, to be able to have an easier development cycle without having to learn the entire JCR API.

A Java bean representation of the JCR 'myproject:text' nodetype will look like this:

```
import org.hippoecm.hst.content.beans.Node;
import org.hippoecm.hst.content.beans.standard.HippoDocument;
import org.hippoecm.hst.content.beans.standard.HippoHtml;

@Node(jcrType="myproject:text")
public class TextBean extends HippoDocument{    
  public String getTitle() {        
    return getProperty("myproject:title");    
  }        
  public String getAuthor() {        
    return getProperty("myproject:author");    
  }    
  public HippoHtml getBody(){        
    return getHippoHtml("myproject:body");    
  }
}
```

As you can see the Java bean is quite straight forward and easy to read.Now if we want to render the information on a webpage, we can use for instance JSP's with expression language to get the information from the Java bean. The JSP needed for outputting the RDFa enabled webpage can be as simple as this:

```
<%@ page language="java" %>
<%@ taglib uri="http://www.hippoecm.org/jsp/hst/core" prefix='hst'%>
<html>
  <body xmlns:dc="http://purl.org/dc/elements/1.1/">
  <h1 property="dc:title">${document.title}</h1>
  <h2 property="dc:creator">${document.author}</h2>
  <hst:html hippohtml="${document.body}"/>
  </body>
</html>
```

As you can see it's that easy to use RDFa inside your website if you have a template independent CMS like Hippo.

## It gets even better
Using RDFa for simple text can already be a great improvement for you website, but support for other RDFa vocabularies is added on a regular basis. Google <a href="http://googlewebmastercentral.blogspot.com/2009/09/supporting-facebook-share-and-rdfa-for.html">recently announced</a> support for RDFa enabled pages with videos (or media) on them. You can provide extra information for your media files to the Google crawler, like the url to the thumbnail that belongs to your video, which can be presented when your video is found as one of the results in a search performed at Google. The possibilities are enormous, so I can see a lot of good things coming from using RDFa in the near future.

I think the role that content management systems can have for RDFa should not be underestimated, since most website these days are backed by some sort of content management system.

For more information on RDFa see:
<ul><li><a href="http://www.w3.org/MarkUp/2009/rdfa-for-html-authors">RDFa for HTML authors, by Steven Pemberton</a></li><li><a href="http://rdfa.info/">RDFa.info</a> - A site containing news about RDFa </li><li><a href="http://googlewebmastercentral.blogspot.com/2009/09/supporting-facebook-share-and-rdfa-for.html">Google supporting FaceBook Share and RDFa for videos</a></li></ul>
