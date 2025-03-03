---
categories:
- Software Engineering
comments: false
date: "2006-07-06T00:00:00Z"
title: Configurable cocoon.createObject()
---

Today I was working on a new feature in the CMS. I had to do some flowscript coding in order to implement this feature. By default you can create an instance of a Java class in flowscript by using the following syntax:
```
cocoon.createObject(Packages.nl.hippo.cms.Class);
```

Since I did not want to hardcode my class file, but wanted to create a configurable object, I had to find a solution.
So first I set the value of the variable in the DefaultsModule. (this can also be a  XMLFileInputModule so you can really make this configurable from outside of you Cocoon application.

{{< highlight xml >}}
<component-instance class="org.apache.cocoon.components.modules.input.DefaultsModule"
                    logger="core.modules.input" name="myconstants">
  <values>
    <cms-object>nl.hippo.test.XMLDemo</cms-object>
  </values>
</component-instance>
{{< / highlight >}}

So now from my flowscript I can fetch the value of the cms-object constant.
{{< highlight javascript >}}
var myConstants = cocoon.getComponent(InputModule.ROLE + "Selector").select("myconstants");
var myObject = myConstants.getAttribute("cms-object",null,null);
// Add the "" to the myObject variable, otherwise the interpreter will think that it's a scriptable object instead of a String or Class object.
var myXMLObject = cocoon.createObject(myObject+"");
{{< / highlight >}}

You will have to declare the import for  the Cocoon input package at the top of your flowscript before this will work.
{{< highlight javascript >}}
importPackage(Packages.org.apache.cocoon.components.modules.input);
{{< / highlight >}}

Well that's it! I could not find any documentation about how to do this.
I hope this small chunk of code will help others out in the future.

Usefull links:

+ <a href="http://www.mozilla.org/rhino/scriptjava.html" target="_blank">Rhino Javascript</a>
+ <a href="http://cocoon.apache.org/2.1/apidocs/org/apache/cocoon/components/flow/javascript/fom/FOM_Cocoon.html" target="_blank">Implementation of FOM (Flow Object Model)</a>
