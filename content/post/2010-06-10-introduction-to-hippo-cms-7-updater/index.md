---
categories:
- Software Engineering
comments: true
date: "2010-06-10T00:00:00Z"
title: An introduction to Hippo CMS 7 updater modules
aliases:
- introduction-to-hippo-cms-7-updater
---

Once your <a href="http://www.onehippo.org/">Hippo CMS</a> project is in production, there is always the case that you or your customer wants to add extra features to the website or portal. This might mean that the data model has to change The data model for a piece of content in Hippo CMS is stored based on a JCR nodetype definition.
As you might know the editor templates, which are related to the data model, can be edited live in the CMS. When you're done editing the editor templates, you can use the 'Update all content' button to persist the changes in your existing content model. This might be a nice way of doing things during development, but performing such an operation on a live clustered environment can be quite tricky and you might want to do it in a more controlled and tested way.

As of Hippo CMS 7.2 it's possible to perform these changes by writing updater modules in plain Java. In this post I will try to explain the concept of updater modules and will show you how to write these updater modules and use them for updating your data model.

<i><b>Note</b>: For those of you reading this post and are using Hippo CMS version 7.8+ this mechanism has changed. From version 7.8 onwards you  can use the Updater Editor to create Groovy based scripts within the CMS  to perform these kind of operations. See the <a href="http://www.onehippo.org/7_8/library/concepts/upgrade/using-the-updater-editor.html" target="_blank">official Hippo CMS documentation</a> page for further information. </i>

## Writing an Updater module

When you start writing an updater module you can start out with the following simple class file:

``` java
import org.hippoecm.repository.ext.UpdaterModule;
import org.hippoecm.repository.ext.UpdaterContext;

public class MyProjectUpdater implements UpdaterModule {

    public void register(final UpdaterContext context) {
       .....
    }

}
```

As you can see in the above code snippet the MyProjectUpdater extends the UpdaterModule interface, which requires you to implement the register() method. On your classpath you will need the hippo-ecm-api library, which comes with the Hippo CMS 7 war package or you can get it from the maven 2 repository.

## Updaters and versioning

Performing such an update on your data model is most of the time specific for the current release of your project. The engine behind the updater modules can be instructed to only trigger certain updater modules if certain requirements (like the version of your project) are met. You can instruct the updater engine to trigger a specific updater module by registering a start tag on the UpdaterContext. In the following example we will:
<ul><li>register a unique name for our updater module</li><li>register a start tag for which this updater module should be triggered</li><li>register an end tag to which this version should change once the update was successful</li></ul>

``` java
import org.hippoecm.repository.ext.UpdaterModule;
import org.hippoecm.repository.ext.UpdaterContext;

public class MyProjectUpdater implements UpdaterModule {

    public void register(final UpdaterContext context) {
        context.registerName("myproject-updater-v1-to-v1_1");
        context.registerStartTag("myproject-v1");
        context.registerEndTag("myproject-v1_1");
   }

}
```

In the above updater module we will update our project from version 1 to version 1.1.
Our updater module does not do any radical changes so far. It will only change the start version in the repository for our project. You can find the current registered version(s) inside the Hippo repository with the Hippo CMS Console view on the path:

```
/hippo:configuration/hippo:initialize/hippo:version.
```

If you don't have a project specific version yet, I would recommend creating one, because it will help you with using these updater modules.
Now let's continue with some more interesting stuff.

## Visitors

You might want to change the data model with some simple operations like: adding a field, removing a field or introducing some new nodetypes. The hippo repository provides several visitors for doing changes inside the repository while performing an update. By default Hippo CMS 7.3 comes with 4 types of visitors. The following diagram shows you the class hierarchy for the ItemVisitor interface.
<div class="separator" style="clear: both; text-align: center;"><a href="http://1.bp.blogspot.com/_hd6Y7yyFK7E/TA-hx6QkNXI/AAAAAAAAAY4/MpeeqjGgZMc/s1600/visitor-diagram.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" height="196" src="http://1.bp.blogspot.com/_hd6Y7yyFK7E/TA-hx6QkNXI/AAAAAAAAAY4/MpeeqjGgZMc/s640/visitor-diagram.png" width="640" /></a></div>

As you can see the following visitors are available:

* NodeTypeVisitor - visits nodes of a specific primary type
* PathVisitor - visits nodes based on their path in the repository
* QueryVisitor - visits nodes found based on a JCR query
* NamespaceVisitor - visits specified namespaces

Of course you can also write your own visitor if you want, but I guess the provided visitors are the most commonly used.

<i>Note: The NamespaceVisitor is a special case and is not supposed to be used in a clustered Hippo setup. If you really need to use it make sure you run the updater on a non-clustered repository node.</i>

## How to use a visitor in your module

Now that we've seen the available visitors, let's see how we can use them. I think the most common use for updaters is when you need to update your data model without any extra processing involved. Let's say our current datamodel (cnd) version 1.0 looks like this:

```
<hippo='http://www.onehippo.org/jcr/hippo/nt/2.0'>
<hippostd='http://www.onehippo.org/jcr/hippostd/nt/2.0'>
<hippostdpubwf='http://www.onehippo.org/jcr/hippostdpubwf/nt/1.0'>
<myproject='http://www.myproject.org/jcr/nt/1.0'>

[myproject:basedocument] > hippo:document, hippostdpubwf:document, hippostd:publishableSummary

[myproject:news] > myproject:basedocument
- myproject:title (string)
+ myproject:text (hippostd:html)
```

We want to move to version 1.1, where we added a new subtitle field. The new nodetype defintion now looks like this:

```
<hippo='http://www.onehippo.org/jcr/hippo/nt/2.0'>
<hippostd='http://www.onehippo.org/jcr/hippostd/nt/2.0'>
<hippostdpubwf='http://www.onehippo.org/jcr/hippostdpubwf/nt/1.0'>
<myproject='http://www.myproject.org/jcr/nt/1.1'>

[myproject:basedocument] > hippo:document, hippostdpubwf:document, hippostd:publishableSummary

[myproject:news] > myproject:basedocument
- myproject:title (string)
- myproject:subtitle (string)
+ myproject:text (hippostd:html)
```

Now if we want to update our namespace with an updater module our actual code will look like this:

``` java
import java.io.InputStreamReader;
import org.hippoecm.repository.ext.UpdaterItemVisitor;
import org.hippoecm.repository.ext.UpdaterModule;
import org.hippoecm.repository.ext.UpdaterContext;

public class MyProjectUpdater implements UpdaterModule {

    public void register(final UpdaterContext context) {
        context.registerName("myproject-updater-v1-to-v1_1");
        context.registerStartTag("myproject-v1");
        context.registerEndTag("myproject-v1_1");

        context.registerVisitor(new UpdaterItemVisitor.NamespaceVisitor(context, "myproject", "-",
        new InputStreamReader(getClass().getClassLoader().getResourceAsStream("myproject.cnd"))));
   }

}
```

The updater module above registers a namespace visitor on the UpdaterContext and the visitor reloads the content nodetype definition (cnd in short) from the classpath and updates the namespace to the new version. This is all you have to do to just bump a namespace from version 1.0 to 1.1.
Now if you actually want to change something during the update we can make use of one of the other visitors like the NodeTypeVisitor. Let's say we want to change a certain property of all documents of type 'myproject:news', then this is what the updater might look like:

``` java
import java.io.InputStreamReader;
import javax.jcr.Node;
import javax.jcr.RepositoryException;
import javax.jcr.Value;
import org.hippoecm.repository.ext.UpdaterItemVisitor;
import org.hippoecm.repository.ext.UpdaterModule;
import org.hippoecm.repository.ext.UpdaterContext;

public class MyProjectUpdater implements UpdaterModule {

   public void register(final UpdaterContext context) {
        context.registerName("myproject-updater-v1-to-v1_1");
        context.registerStartTag("myproject-v1");
        context.registerEndTag("myproject-v1_1");

        context.registerVisitor(new UpdaterItemVisitor.NodeTypeVisitor("myproject:news") {
            @Override
            protected void leaving(Node node, int level) throws RepositoryException {
               if (node.hasProperty("myproject:property")) {
                   node.setProperty("myproject:property", "new value");
               }
            }
        });
   }

}
```

The important part of the updater in this case is that we override the *leaving()* method, which will be called before the visitor leaves this node and moves on to the next. It will then change the value of a certain property and move on.
If you want to see more examples of how to use certain types of visitors please let me know, but I hope that the two examples above can help you get started with writing updater modules. Now let's see how to get the repository to run your updater module.

## Adding the updater module to your deployment

Now that we've seen how to write an updater module, the next step is to get the repository to run your updater module. The Hippo CMS 7 repository knows about the existence of these updater modules, but you will need to instruct the repository on where they can be found. Making an updater module available to repository is done in the similar fashion as <a href="http://blog.jeroenreijn.com/2009/03/using-daemon-modules-with-hippo-cms-7.html">adding a daemon module to the repository</a>. The location of the updater module needs to be added to the MANIFEST.MF, which will end up in your jar. Maven 2 can help you with achieving this by means of the maven-jar-plugin. See the following plugin configuration from my pom.xml file.

``` xml
<plugin>
  <groupid>org.apache.maven.plugins</groupid>
  <artifactid>maven-jar-plugin</artifactid>
  <configuration>
    <archive>
      <manifest>
        <addDefaultImplementationEntries>true</addDefaultImplementationEntries>
      </manifest>
      <manifestEntries>
        <Hippo-Modules>com.myproject.repository.update.MyProjectUpdater</Hippo-Modules>
      </manifestEntries>
    </archive>
  </configuration>
</plugin>
```

Now when you add the jar with our updater module to the CMS web application archive and start the CMS, the repository will scan all manifest files for implementations of the UpdaterModule interface. The updater modules will be registered and triggered when needed.
The updater modules are quite powerful and it's great that you can test them on your test environment, so you can make sure that when you perform an update in production it will succeed.

## References

More information about moving changes through a DTAP environment can be found in the <a href="http://www.onehippo.org/7_7/library/concepts/upgrade/dtap.html">official Hippo documentation</a>
