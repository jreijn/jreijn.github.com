---
comments: false
date: "2017-10-18T00:00:00Z"
image: /img/cucumber-bg.png
categories:
- Software Engineering
title: Running Cucumber from the command-line
---

Recently I've been spending some time with [Cucumber](https://cucumber.io) and joined the [cucumber gitter channel](https://gitter.im/cucumber/cucumber-jvm) when somebody pointed out that they were having trouble running Cucumber from the command line.
I usually run Cucumber from Maven, so I thought it would be interesting to see what was required to run cucumber from the command-line.

As described in [the documentation](https://cucumber.io/docs/reference/jvm#cli-runner) you can run Cucumber features from the command-line by using the cli-runner with the following command:

```
java cucumber.api.cli.Main
```

You can get help by using the `--help` option:

```
java cucumber.api.cli.Main --help
```

This looks pretty straightforward if you are familiar with Java, but the 'hard' part comes from understanding how to use the java command with its classpath options.

One important aspect is that the  `cucumber.api.cli.Main` class is located in the cucumber-core jar file, so when you want to run this class you need to provide the cucumber-core jar on your classpath. In this case, I take the jar(s) from my maven repository and include all required dependencies:

```
$ java -cp "/Users/jreijn/.m2/repository/info/cukes/cucumber-core/1.2.5/cucumber-core-1.2.5.jar:/Users/jreijn/.m2/repository/info/cukes/gherkin/2.12.2/gherkin-2.12.2.jar:/Users/jreijn/.m2/repository/info/cukes/cucumber-java/1.2.5/cucumber-java-1.2.5.jar:/Users/jreijn/.m2/repository/info/cukes/cucumber-jvm-deps/1.0.5/cucumber-jvm-deps-1.0.5.jar" cucumber.api.cli.Main
```
If you run this it should result in the following message:

```
Got no path to feature directory or feature file
0 Scenarios
0 Steps
0m0.000s
```

Now to be able to run we need to run a feature file you will need to provide two additional arguments:

1. Your feature file(s)
2. Your glue code (step definitions, hooks, etc)

Your feature files can be added to the end of the command line:

```
$ java -cp "/Users/jreijn/.m2/repository/info/cukes/cucumber-core/1.2.5/cucumber-core-1.2.5.jar:/Users/jreijn/.m2/repository/info/cukes/gherkin/2.12.2/gherkin-2.12.2.jar:/Users/jreijn/.m2/repository/info/cukes/cucumber-java/1.2.5/cucumber-java-1.2.5.jar:/Users/jreijn/.m2/repository/info/cukes/cucumber-jvm-deps/1.0.5/cucumber-jvm-deps-1.0.5.jar" cucumber.api.cli.Main Developer/sources/github/cucumber-jvm-extentreport/src/test/resources/cucumber/feature_one.feature
```

This will probably result in the following message:

```
UUUUUU

3 Scenarios (3 undefined)
6 Steps (6 undefined)
0m0.000s


You can implement missing steps with the snippets below:

[snip]
```

This means it can't find the step definitions, hooks, etc that correspond to your feature file.

Let's add the glue code required for running the tests. In the below example I'll use my maven projects target directory, which contains my step definitions in the test-classes directory. You can do that by adding the directory to your classpath and with `--glue com.sitture.definitions` provide the package the step definition class files are in.

```
$ java -cp "/Users/jreijn/.m2/repository/info/cukes/cucumber-core/1.2.5/cucumber-core-1.2.5.jar:/Users/jreijn/.m2/repository/info/cukes/gherkin/2.12.2/gherkin-2.12.2.jar:/Users/jreijn/.m2/repository/info/cukes/cucumber-java/1.2.5/cucumber-java-1.2.5.jar:/Users/jreijn/.m2/repository/info/cukes/cucumber-jvm-deps/1.0.5/cucumber-jvm-deps-1.0.5.jar:/Users/jreijn/Developer/sources/github/cucumber-jvm-extentreport/target/test-classes/" cucumber.api.cli.Main --glue com.sitture.definitions Developer/sources/github/cucumber-jvm-extentreport/src/test/resources/cucumber/feature_one.feature
```

This should result in something similar to:

```
......
....
.....

3 Scenarios (3 passed)
6 Steps (6 passed)
0m0.067s
```

Which seems about right and shows how we can run cucumber from the command line with the Cucumber CLI.
