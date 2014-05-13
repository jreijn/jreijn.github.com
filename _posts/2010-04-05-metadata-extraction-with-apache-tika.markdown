---
layout: post
title: "Metadata extraction with Apache Tika"
date: 2010-04-05
comments: false
categories:
 - java
 - hippo
---

<div class='post'>
<div class="separator" style="clear: both; text-align: center;"><a href="http://1.bp.blogspot.com/_hd6Y7yyFK7E/S7pGYKIkWSI/AAAAAAAAAX4/LLz_aNEujsM/s1600/tika.png" imageanchor="1" style="clear: left; float: left; margin-bottom: 1em; margin-right: 1em;"><img border="0" src="http://1.bp.blogspot.com/_hd6Y7yyFK7E/S7pGYKIkWSI/AAAAAAAAAX4/LLz_aNEujsM/s320/tika.png" /></a></div>At&nbsp;<a href="http://www.onehippo.com/">Hippo</a>&nbsp;I work with/for customers that have quite a lot of content. The&nbsp;projects I work on have content in the range of 5.000 to 500.000 document gathered in one content repository. This can be just textual content, but most of the time this is a variety of different content types.&nbsp;You might think of images, PDFs and Microsoft office document formats. By default <a href="http://jackrabbit.apache.org/">Apache JackRabbit</a>, the layer underneath <a href="http://docs.onehippo.org/">Hippo Repository</a>, indexes this kind of content by using extractors, so that the information can be found within the&nbsp;<a href="http://docs.onehippo.org/">Hippo CMS 7</a>&nbsp;search or from any application connected to the Hippo Repository which is performing a search on the content repository. Being able to search on content found within a file is interesting, but there is so much more that you can do with this kind of information.<br /><br /><h2>Content metadata</h2><br />Having all this content inside the repository is nice, but a certain piece of content uploaded to the repository can contain much more information than the file itself and sometimes this metadata is ignored in content management systems. As an example you might want to be able to see the number of pages of a PDF document inside your CMS or view the <a href="http://en.wikipedia.org/wiki/Exchangeable_image_file_format">EXIF</a> information of an image stored inside your content repository. There are a number of parser libraries out there that can extract information from a specific file format, but you can get quite lost. Within the ASF there is also a very nice toolkit called <a href="http://lucene.apache.org/tika/">Apache Tika</a>, which provides parsers for a lot of different file formats.<br /><br /><h2>What is Apache Tika?</h2><br /><div>Apache Tika is a subproject of the <a href="http://lucene.apache.org/">Apache Lucene</a> project and is a toolkit for extracting content and metadata from different kind of file formats. The content extraction logic is not located inside Tika itself, but&nbsp;Tika&nbsp;defines a standard API and makes use of existing libraries like <a href="http://poi.apache.org/">POI</a>&nbsp;and <a href="http://pdfbox.apache.org/">PDFBox</a>&nbsp;for it's content extraction.&nbsp;While writing this post the current release of Tika is version 0.6 and the following file formats are already supported:&nbsp;</div><ul><li>HyperText Markup Language</li><li>XML and derived formats</li><li>Microsoft Office document formats</li><li>OpenDocument Format</li><li>Portable Document Format</li><li>Electronic Publication Format</li><li>Rich Text Format</li><li>Compression and packaging formats</li><li>Text formats</li><li>Audio formats</li><li>Image formats</li><li>Video formats</li><li>Java class files and archives</li><li>The mbox format</li></ul><div>As you can see this is already quite a lot. The team behind Tika is working hard on improving the current parser possibilities and adding more formats for the upcoming releases. Tika is actually already being used by a number of other Apache projects like JackRabbit and <a href="http://lucene.apache.org/solr/">Solr</a>. Now let's see how we can use Tika ourselves.<br /><br /></div><h2>Getting started</h2><br />I always work with <a href="http://maven.apache.org/">Maven</a> as my build system, so let's start of with a piece of pom.xml. First add the Tika parser dependency to our pom.xml.<br /><br /><pre class="brush: xml">&lt;dependency&gt;<br />  &lt;groupId&gt;org.apache.tika&lt;/groupId&gt;<br />  &lt;artifactId&gt;tika-parsers&lt;/artifactId&gt;<br />  &lt;version&gt;0.6&lt;/version&gt;<br />&lt;/dependency&gt;<br /></pre><br />By depending on <i>tika-parsers</i>&nbsp;Maven will automatically gather the required parser libraries, which are needed to parse certain file formats. Since my Java code example will be based on a unit test, we will also need to add JUnit as a dependency to our pom.xml.<br /><br /><pre class="brush: xml">&lt;dependency&gt;<br />&nbsp;&nbsp;&lt;groupId&gt;junit&lt;/groupId&gt;<br />&nbsp;&nbsp;&lt;artifactId&gt;junit&lt;/artifactId&gt;<br />&nbsp;&nbsp;&lt;version&gt;4.7&lt;/version&gt;<br />&lt;/dependency&gt;<br /></pre><br />In this post I want to see what kind of&nbsp;<a href="http://en.wikipedia.org/wiki/Exchangeable_image_file_format">EXIF</a>&nbsp;information can be retrieved from an image by using Tika.&nbsp;One of my hobbies is photography and therefor I have tons of images, which contain a lot of metadata about for instance the ISO speed or dimensions of an image.&nbsp;Now let's write some actual code to see how Tika works.<br /><br /><h2>The actual code</h2><br />As I mentioned before, my&nbsp;example&nbsp;code is written as a <a href="http://www.junit.org/">JUnit</a> test. If you are not familiar with writing tests or JUnit itself please have a look at the JUnit <a href="http://www.junit.org/">website</a>.<br />To be able to run this test, I've added one of my images on the test classpath, so my test class will be able to find the image resource. The following piece of code shows my entire test class.<br /><br /><pre class="brush: java">public class ImageMetaDataTest {<br /><br />    private static final String fileName = "IMG_2659.JPG";<br /><br />    private Tika tika;<br />    private InputStream stream;<br /><br />    @Before<br />    public void setUp() {<br />        tika = new Tika();<br />        stream = this.getClass().getResourceAsStream(fileName);<br />    }<br /><br />    @Test<br />    public void testImageMetadataCameraModel() throws IOException, SAXException, <br />            TikaException {<br /><br />        Metadata metadata = new Metadata();<br />        ContentHandler handler = new DefaultHandler();<br />        Parser parser = new JpegParser();<br />        ParseContext context = new ParseContext();<br /><br />        String mimeType = tika.detect(stream);<br />        metadata.set(Metadata.CONTENT_TYPE, mimeType);<br /><br />        parser.parse(stream,handler,metadata,context);<br />        assertTrue("The expected Model is not correct", <br />                metadata.get("Model").equals("Canon EOS 350D DIGITAL"));<br />    }<br /><br />    @After<br />    public void close() throws IOException {<br />        if(stream!=null) {<br />            stream.close();<br />        }<br />    }<br /><br />}<br /><br /></pre><br />As you can see the code is quite small. The most important part of the above code example is using the&nbsp;JpegParser to parse the .JPG file&nbsp;and the creation of the Metadata object with the appropriate information.<br />I think this simple test case shows you how easy to use the Tika API is. Of course in the above test case I only test for the current Camera Model, but the Metadata object holds much more information then just that.<br /><br />Viewing all the&nbsp;fields found in the metadata of the image can be achieved quite easily by using for instance the following method.<br /><br /><pre class="brush: java">private void listAvailableMetaDataFields(final Metadata metadata) {<br />  for(int i = 0; i &lt;metadata.names().length; i++) {<br />    String name = metadata.names()[i];<br />    System.out.println(name + " : " + metadata.get(name));<br />  }<br />}<br /></pre><br />The output of this method can be like:<br /><br /><code><br />Easy Shooting Mode : Manual<br />Image Type : Canon EOS 350D DIGITAL<br />Model : Canon EOS 350D DIGITAL<br />Metering Mode : Evaluative<br />Quality : Fine<br />Shutter/Auto Exposure-lock Buttons : AF/AE lock<br />ISO Speed Ratings : 400<br /></code><br /><br />It's as easy as that.<br /><br /><h2>Looking ahead</h2><br />I'm currently looking for possibilities of integrating Apache Tika into Hippo CMS 7, to enhance the system with much more metadata then there currently is available in the system. I think this can become quite a powerful addition in combination with the&nbsp;facetted navigation feature introduced in&nbsp;<a href="http://www.onehippo.com/en/news/2010/03/CMS+7.3.html">Hippo CMS 7.3</a>. I've already started working on some code, which I hope to provide as a patch in the near future.</div>
<h2>Comments</h2>
<div class='comments'>
<div class='comment'>
<div class='author'>Suhaib Mustafa</div>
<div class='content'>
Hi,<br />I was looking out for libraries which i can use to validate mp3/wav files uploaded by users onto my site. I want to make sure that uploaded files are indeed mps/wav file. Also i need to extract the Duration of the audio clip. Using Tika i was able to get Duration of mp3 file from Metadata but could not for the wav format file. Any suggestion on this? you can suggest any other library also which might do just this<br /><br />Thanks</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
I think you should take a look at Apache Nutch. http://nutch.apache.org/ As far as I know it uses TIKA</div>
</div>
<div class='comment'>
<div class='author'>Sameer Shah</div>
<div class='content'>
sir is there a tool for parsing html documents and also tool for indexing the contents of wenpages in database usning clusters???  im student from computer science,INDIA, im workiing on the project of creation of web crawler</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Just adding the dependencies should be enough. You will need to add them to your pom.xml files. The versions used in this post are quite old. Tika 1.4 is the latest version. The two XML snippets in this post are used to add Tika to your project.</div>
</div>
<div class='comment'>
<div class='author'>tika_jr</div>
<div class='content'>
hi Experts,<br />i am new to apache tika,<br />how to install apache tika project to eclise with maven can u give clear steps.<br /></div>
</div>
<div class='comment'>
<div class='author'>Tesfay K. Aregay</div>
<div class='content'>
I found this post very helpful!<br />Thank you !</div>
</div>
<div class='comment'>
<div class='author'>Divyanand Tiwari</div>
<div class='content'>
Post was very helpfull... Thank you very much !<br />I have one question hoping to get answered here..<br />I have recently started to use Apache Solr and there I am  indexing some html files. I am using Tika to extract the html. I want to know that how can i configure the tika to output in html format.</div>
</div>
<div class='comment'>
<div class='author'>yesh</div>
<div class='content'>
Hi Reijn,<br /><br />I want to know whether tika parser is useful for extracting text from Microsoft office documents and PDF Documents.<br />a working example will help me a lot<br /><br />Thanks</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
I personally do not have experience with that kind of problem, so I&#39;m sorry to say that I can&#39;t help you with any source code. You might want to try the tika user list.</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Hi,<br /><br />I personally do not have experience with that kind of problem, so I&#39;m sorry to say that I can&#39;t help you with any source code. You might want to try the tika user list.<br /><br />Jeroen</div>
</div>
<div class='comment'>
<div class='author'>suresh</div>
<div class='content'>
Hi,<br /><br /> I am new to Apache Tika I need to convert the excel sheet into HTML and my sheet will have graph and images. Can i use Tika for the same? I am not been able to find a code sample which will convert the charts.Can you please provide some java code samples?<br /><br />Thanks ,<br />Suresh K  </div>
</div>
<div class='comment'>
<div class='author'>Anonymous</div>
<div class='content'>
Hi Reijn,<br />I have xml document in which html is embedded,I want to extract text from such documents.Is this parser can parse a document which has both html &amp; xml embedded in it.<br />Thanks</div>
</div>
<div class='comment'>
<div class='author'>ivanov-void</div>
<div class='content'>
very helpfull! Thanks!</div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
Hi I&#39;m not sure if there is anything for C#. Tika should be able to extract a document and convert it to HTML yes.</div>
</div>
<div class='comment'>
<div class='author'>Anil Mudalgi</div>
<div class='content'>
Hi,<br /><br />I wanted to convert doc/docx file to html. can Tika help me. If yes can you me some code sample. I&#39;m working on c# </div>
</div>
<div class='comment'>
<div class='author'>Jeroen Reijn</div>
<div class='content'>
No Tika is only helpful when you want to detects and extract metadata. You might want to take a look at Apache POI (http://poi.apache.org/).</div>
</div>
<div class='comment'>
<div class='author'>Laxman Rana</div>
<div class='content'>
Hi,<br />I want to convert html contents to word with all styles.so will tika will be helpful??<br /><br />Thanks</div>
</div>
<div class='comment'>
<div class='author'>Madhu</div>
<div class='content'>
Hi Reijn, <br /><br />I&#39;ve a requirement wherein I&#39;ll be getting the images and the text content as part of PDF/Word document from a third party. I need to parse those files and display the image and the content on site. <br /><br />Currently we are doing it manually but want to automate the process. So will Tika be helpful in this case <br /><br />Thanks <br />Madhu</div>
</div>
</div>
