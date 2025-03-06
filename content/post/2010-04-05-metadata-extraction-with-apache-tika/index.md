---
categories:
- Software Engineering
comments: true
date: "2010-04-05T00:00:00Z"
title: Metadata extraction with Apache Tika
---

At <a href="http://www.onehippo.com/">Hippo</a> I work with/for customers that have quite a lot of content. The projects I work on have content in the range of 5.000 to 500.000 document gathered in one content repository. This can be just textual content, but most of the time this is a variety of different content types. You might think of images, PDFs and Microsoft office document formats. By default <a href="http://jackrabbit.apache.org/">Apache JackRabbit</a>, the layer underneath <a href="http://docs.onehippo.org/">Hippo Repository</a>, indexes this kind of content by using extractors, so that the information can be found within the <a href="http://docs.onehippo.org/">Hippo CMS 7</a> search or from any application connected to the Hippo Repository which is performing a search on the content repository. Being able to search on content found within a file is interesting, but there is so much more that you can do with this kind of information.

## Content metadata

Having all this content inside the repository is nice, but a certain piece of content uploaded to the repository can contain much more information than the file itself and sometimes this metadata is ignored in content management systems. As an example you might want to be able to see the number of pages of a PDF document inside your CMS or view the <a href="http://en.wikipedia.org/wiki/Exchangeable_image_file_format">EXIF</a> information of an image stored inside your content repository. There are a number of parser libraries out there that can extract information from a specific file format, but you can get quite lost. Within the ASF there is also a very nice toolkit called <a href="http://lucene.apache.org/tika/">Apache Tika</a>, which provides parsers for a lot of different file formats.

## What is Apache Tika?

Apache Tika is a subproject of the <a href="http://lucene.apache.org/">Apache Lucene</a> project and is a toolkit for extracting content and metadata from different kind of file formats. The content extraction logic is not located inside Tika itself, but Tika defines a standard API and makes use of existing libraries like <a href="http://poi.apache.org/">POI</a> and <a href="http://pdfbox.apache.org/">PDFBox</a> for it's content extraction. While writing this post the current release of Tika is version 0.6 and the following file formats are already supported:

+ HyperText Markup Language
+ XML and derived formats
+ Microsoft Office document formats
+ OpenDocument Format
+ Portable Document Format
+ Electronic Publication Format
+ Rich Text Format
+ Compression and packaging formats
+ Text formats
+ Audio formats
+ Image formats
+ Video formats
+ Java class files and archives
+ The mbox format

As you can see this is already quite a lot. The team behind Tika is working hard on improving the current parser possibilities and adding more formats for the upcoming releases. Tika is actually already being used by a number of other Apache projects like JackRabbit and <a href="http://lucene.apache.org/solr/">Solr</a>. Now let's see how we can use Tika ourselves.

## Getting started
I always work with <a href="http://maven.apache.org/">Maven</a> as my build system, so let's start of with a piece of pom.xml. First add the Tika parser dependency to our pom.xml.

``` xml
<dependency>
  <groupId>org.apache.tika</groupId>
  <artifactId>tika-parsers</artifactId>
  <version>0.6</version>
</dependency>
```

By depending on <i>tika-parsers</i> Maven will automatically gather the required parser libraries, which are needed to parse certain file formats. Since my Java code example will be based on a unit test, we will also need to add JUnit as a dependency to our pom.xml.

``` xml
<dependency>
  <groupId>junit</groupId>
  <artifactId>junit</artifactId>
  <version>4.7</version>
</dependency>
```

In this post I want to see what kind of <a href="http://en.wikipedia.org/wiki/Exchangeable_image_file_format">EXIF</a> information can be retrieved from an image by using Tika. One of my hobbies is photography and therefor I have tons of images, which contain a lot of metadata about for instance the ISO speed or dimensions of an image. Now let's write some actual code to see how Tika works.

## The actual code

As I mentioned before, my example code is written as a <a href="http://www.junit.org/">JUnit</a> test. If you are not familiar with writing tests or JUnit itself please have a look at the JUnit <a href="http://www.junit.org/">website</a>.
To be able to run this test, I've added one of my images on the test classpath, so my test class will be able to find the image resource. The following piece of code shows my entire test class.

``` java
public class ImageMetaDataTest {
    private static final String fileName = "IMG_2659.JPG";
    private Tika tika;
    private InputStream stream;

    @Before
    public void setUp() {
      tika = new Tika();
      stream = this.getClass().getResourceAsStream(fileName);
    }

    @Test
    public void testImageMetadataCameraModel() throws IOException, SAXException,
        TikaException {
      Metadata metadata = new Metadata();
      ContentHandler handler = new DefaultHandler();
      Parser parser = new JpegParser();
      ParseContext context = new ParseContext();
      String mimeType = tika.detect(stream);
      metadata.set(Metadata.CONTENT_TYPE, mimeType);
      parser.parse(stream,handler,metadata,context);

      assertTrue("The expected Model is not correct",
                    metadata.get("Model").equals("Canon EOS 350D DIGITAL"));
    }

    @After
    public void close() throws IOException {
      if(stream!=null) {
        stream.close();
      }
    }
}
```

As you can see the code is quite small. The most important part of the above code example is using the JpegParser to parse the .JPG file and the creation of the Metadata object with the appropriate information.<br />I think this simple test case shows you how easy to use the Tika API is. Of course in the above test case I only test for the current Camera Model, but the Metadata object holds much more information then just that.
Viewing all the fields found in the metadata of the image can be achieved quite easily by using for instance the following method.

``` java
private void listAvailableMetaDataFields(final Metadata metadata) {
    for(int i = 0; i <metadata.names().length; i++) {
        String name = metadata.names()[i];
        System.out.println(name + " : " + metadata.get(name));
    }
}
```

The output of this method can be like:

```
Easy Shooting Mode : Manual
Image Type : Canon EOS 350D DIGITAL
Model : Canon EOS 350D DIGITAL
Metering Mode : Evaluative
Quality : Fine
Shutter/Auto Exposure-lock Buttons : AF/AE lock
ISO Speed Ratings : 400
```
It's as easy as that.

## Looking ahead

I'm currently looking for possibilities of integrating Apache Tika into Hippo CMS 7, to enhance the system with much more metadata then there currently is available in the system. I think this can become quite a powerful addition in combination with the facetted navigation feature introduced in <a href="http://www.onehippo.com/en/news/2010/03/CMS+7.3.html">Hippo CMS 7.3</a>. I've already started working on some code, which I hope to provide as a patch in the near future.
