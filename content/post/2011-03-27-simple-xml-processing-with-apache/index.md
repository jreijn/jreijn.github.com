---
categories:
- Software Engineering
comments: false
date: "2011-03-27T00:00:00Z"
title: Simple XML processing with Apache Cocoon 3
aliases:
- simple-xml-processing-with-apache
---

It's been a while since I've last used <a href="http://cocoon.apache.org/">Apache Cocoon</a>. I can still remember the day that I was using Cocoon for doing all my web development projects. My first introduction with Cocoon was when I started at <a href="http://www.onehippo.com/">Hippo</a> about 8 years ago. In comparison to other frameworks, I sometimes miss the simplicity of the Cocoon pipeline concept when I have to work with XML. Especially processing larger XML files is pain in most IDE's.

The Cocoon team has been working on <a href="http://cocoon.apache.org/3.0/index.html">Cocoon 3</a> for a while now, so I wanted to give it a try. Having worked with both Cocoon 2.1 and 2.2, version 3 is created with two new goals in mind:

+ slim down the framework
+ make it easier to use/combine with other frameworks

From what I've seen so far, this results in that you can now do a lot more with just plain Java. Where you would need to use a sitemap XML file before, you can now do a lot with just a few lines of Java. Even though Cocoon 3 is still in alpha stage, it already looks quite promising.
<h2>Getting started</h2>To be able to process XML with Cocoon 3, all we need are the following two maven dependencies.

``` xml
<dependencies>
  <dependency>
    <groupId>org.apache.cocoon.pipeline</groupId>
    <artifactId>cocoon-pipeline</artifactId>
    <version>3.0.0-alpha-2</version>
  </dependency>
  <dependency>
    <groupId>org.apache.cocoon.sax</groupId>
    <artifactId>cocoon-sax</artifactId>
    <version>3.0.0-alpha-2</version>
  </dependency>
</dependencies>
```

These dependencies drag in just two more dependencies (commons-logging and cocoon-xml, so the end result will be quite small, which is really nice compared to for instance Cocoon 2.1, which came with quite some baggage.

## The code

Now let's have a look at some Java code. To play around with Cocoon 3, I'm going to use the RSS feed of this blog. Let's see how Cocoon's new Java based coding works. To be able to process the XML result of the RSS feed, I've created the <i>RSSFeedInfoGenerator</i>. The <i>RSSFeedInfoGenerator</i> is a simple class that will parse a provided RSS feed url.

``` java
/**
 * RSS Feed info generator
 */
public class RSSFeedInfoGenerator {
  private static final String DEFAULT_RSS_URL = "http://blog.jeroenreijn.com/feed.xml";
  public static void main(String[] args) {
    RSSParser parser = new RSSParser();
    if(args!=null &amp;&amp; args.length > 0) {
      parser.setFeedURL(args[0]);
    } else {
      parser.setFeedURL(DEFAULT_RSS_URL);
    }
    parser.parse();
  }
}
```

So now there is a start from which we can actually build the RSS parser and use Cocoon for processing the XML. Now let's take a look at
the actual <i>RSSParser</i>.

``` java
/**
 * Rss parser that uses Cocoon 3 pipelines for generating
 * and transforming the RSS feed to a simple XML response.
 */
public class RSSParser {
  private static final Log LOG = LogFactory.getLog(RSSParser.class);
  private String feedURL;

  /**
   * Parse the provided feed URL and generate the Feed INFO.
   */
  public void parse() {
    try {
      Pipeline<SAXPipelineComponent> pipeline = new NonCachingPipeline<SAXPipelineComponent>();
      XSLTTransformer xsltTransformer = new XSLTTransformer(this.getClass().getResource("simplify-rss.xsl"));
      pipeline.addComponent(new XMLGenerator(new URL(getFeedURL())));
      pipeline.addComponent(new CleaningTransformer());
      pipeline.addComponent(xsltTransformer);
      pipeline.addComponent(new XMLSerializer().setIndent(true));
      pipeline.setup(System.out);
      pipeline.execute();
    } catch (MalformedURLException e) {
       LOG.error("An exception occurred while parsing the RSS URL: " + e.getMessage());
    } catch (FileNotFoundException e) {
       LOG.error("An exception occurred while parsing the RSS URL: " + e.getMessage());
    } catch (Exception e) {
       LOG.error("An exception occurred trying to parse the RSS feed: " + e.getMessage());
    }
  }

  public String getFeedURL() {
    return feedURL;
  }
  public void setFeedURL(final String feedURL) {
    this.feedURL = feedURL;
  }
}
```

As you can see I first created a Pipeline, which in this case is SAX based. In a Cocoon pipeline you can add multiple components, so we add a Generator, two Transformers and a Serializer. The normal XML version of the RSS feed is quite large, so to make the XML result for this example quite small, we use an XSL template to remove all but the <i>title</i> and <i>lastBuildDate</i> from the RSS feed. Let's have a look at the XSL template.

``` xml
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output indent="yes"/>
  <xsl:template match="rss">
    <info>
      <xsl:copy-of select="channel/title"/>
      <xsl:copy-of select="channel/lastBuildDate"/>
    </info>
  </xsl:template>

  <xsl:template match="@*|node()|text()|comment()|processing-instruction()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()|comment()|processing-instruction()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
```

Looks quite simple right? Now when we run the above code, the <i>RSSParser</i> will output an XML snippet to the terminal/console which looks like this:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<info>
  <title>Jeroen Reijn</title>
  <lastBuildDate>Mon, 21 Mar 2011 22:54:06 +0000</lastBuildDate>
</info>
```

## Final thoughts
I was able to put this example together in about 20 minutes. That's quite fast if you compare this to the old styled processing of Cocoon.

I think the Cocoon team is really far with reaching their goals. Because you are now able to write the processing logic with just some Java, this makes it easy to integrate with any existing Java based framework. <br />I'm curious what else will get into the first official Cocoon 3 release, because it's already quite powerful. From now on I will be using Cocoon 3, when I need to process large (and small) XML files. With the new Java based model it's easy to create a small but powerful processor.
For those interested in the source code, you can find the code on <a href="https://github.com/jreijn/cocoon3-demo">GitHub</a>.
