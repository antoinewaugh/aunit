######################################################################
# AUnit README
######################################################################

# aunit

A packaging and unit test framework for Apama. 

Enables developers to write apama unit tests in native EPL, performing asserts on any part of their epl application. Aunit also ships with a basic apama package management solution to handle project-level dependency injection.

It is a command line tool, designed to work on both windows and linux, the CLI samples in this document are in bash.

Currently aunit tests support:

    * Synchronous test actions
    * Asynchronous test actions
    * Setup/Teardown actions
    * Initialise action 
    * External Project Referencing
    * External File Referencing
  
License: aunit is distributed under the terms of the MIT license, free and open source.

For comments and suggestions please email antoine AT reltech.com

# Installation

To install, download and unzip the latest version from github. Export the `$AUNIT_HOME` environment variable. From an *apama command prompt* type the following:

```
wget https://github.com/antoinewaugh/aunit/archive/master.zip
unzip aunit-master.zip

export AUNIT_HOME=/path/to/aunit-master
```

To test the success of the installation, run the aunit build and aunit test commands from an apama command prompt:

```
cd $AUNIT_HOME/bin
aunit build
aunit test HelloWorld
```
    //@Initialise
    action init(action<> cbInit) {
        cbInit();
    }

    //@Setup
    action setup(action<> cbSetup) {
        cbSetup();
    }

    //@Teardown
    action teardown(action<> cbTeardown) {
        cbTeardown();
    }
The test result should be written to the screen.

```
2016-09-09 09:06:46,552 INFO  ==============================================================
2016-09-09 09:06:46,552 INFO  Id   : HelloWorldTest
2016-09-09 09:06:46,552 INFO  ==============================================================
2016-09-09 09:06:48,927 INFO
2016-09-09 09:06:48,927 INFO  cleanup:
2016-09-09 09:06:48,979 INFO  Executed shutdown <correlator>, exit status 0
2016-09-09 09:06:49,079 INFO
2016-09-09 09:06:49,081 INFO  Test duration: 1.82 secs
2016-09-09 09:06:49,082 INFO  Test final outcome:  PASSED
2016-09-09 09:06:49,082 INFO
2016-09-09 09:06:49,085 CRIT
2016-09-09 09:06:49,085 CRIT  Test duration: 1.84 (secs)
2016-09-09 09:06:49,086 CRIT
2016-09-09 09:06:49,086 CRIT  Summary of non passes:
2016-09-09 09:06:49,088 CRIT    THERE WERE NO NON PASSES
```

**NB:** Due to a bug with the version of ant which ships with apama, please ignore any *[xslt]: Warning* messages referring to the JAXSAXParser. It does not affect the result of the build.

# HelloWorld

The HelloWorld project located in `$AUNIT_HOME/workspace/HelloWorld` demonstrates a working aunit *TestEvent*, with all supported annotations. 

## HelloWorldTest.mon example:

```
package com.aunit.sample;

using com.aunit.Asserter;

event SampleEvent {
    string value;
}

//@Depends
event HelloWorldTest {
    
    Asserter asserter;
    
    SampleEvent expected;

    //@Test     
    action test_001 {
        // This synchronous test will complete immediately after the function returns.
        asserter.assertTrue("test_001", "hello world" = "hello world");  
    }

    //@Test
    action test_002(action<> cbDone) {

        // This asynchronous test will complete once cbDone() is called. Failure to call cbDone() will result in a hanging test.
    
        SampleEvent s;

        on SampleEvent():s 
            and not wait(1.0) {
                asserter.assertString("SampleEvent valid", s.toString(), expected.toString());
                cbDone();
        }

        on wait(1.0) 
            and not SampleEvent() {
                asserter.assertTrue("SampleEvent not routed", false);
                cbDone();
        }

        route SampleEvent("hello world");
    }

    //@Initialise
    action init(action<> cbInit) {

        // defined here to demonstrate initialise action
        expected := SampleEvent("hello world");
        
        cbInit();
    }

    //@Setup
    action setup(action<> cbSetup) {
        cbSetup();
    }

    //@Teardown
    action teardown(action<> cbTeardown) {
        cbTeardown();
    }
}
```

## Running HelloWorld sample

To run the HelloWorld sample, first follow the installation instructions, and then open an apama command prompt and type:

```
cd $AUNIT_HOME/bin
aunit build
aunit test HelloWorld
```

Upon executing the above commands, the result of all unit tests should be written to the console

``` 
2016-09-09 09:06:46,552 INFO  ==============================================================
2016-09-09 09:06:46,552 INFO  Id   : HelloWorldTest
2016-09-09 09:06:46,552 INFO  ==============================================================
2016-09-09 09:06:48,927 INFO
2016-09-09 09:06:48,927 INFO  cleanup:
2016-09-09 09:06:48,979 INFO  Executed shutdown <correlator>, exit status 0
2016-09-09 09:06:49,079 INFO
2016-09-09 09:06:49,081 INFO  Test duration: 1.82 secs
2016-09-09 09:06:49,082 INFO  Test final outcome:  PASSED
2016-09-09 09:06:49,082 INFO
2016-09-09 09:06:49,085 CRIT
2016-09-09 09:06:49,085 CRIT  Test duration: 1.84 (secs)
2016-09-09 09:06:49,086 CRIT
2016-09-09 09:06:49,086 CRIT  Summary of non passes:
2016-09-09 09:06:49,088 CRIT    THERE WERE NO NON PASSES
```

You'll notice the `aunit build` command is run prior to running the test. This is because the HelloWorldTest.mon has a project-level dependency on the `UnitTest` project (the same is true for any *TestEvents*). By default, the UnitTest bundle is injected when running *TestEvents* and so it is optional to specify it in the //@Depends. If a *TestEvent* contains user-level project dependencies, changes must be built with the `aunit build` command proior to running `aunit test` to ensure the tests are run against the latest codebase.

Changes to *TestEvent* files and single file dependency references, however, do not require a rebuild prior to running the `aunit test` command.

For information on defining user-level project dependencies please see *Defining custom project-level dependencies*.

# TestEvents & Test Build Process

## Aunit Commands

Aunit supports two primary commands, `build` and `test`.

The `build` command takes no arguments, and builds all projects located in the $AUNIT_PROJECT_HOME directory ($AUNIT_HOME/workspace by default). 

The `test` command has two optional arguments:

`aunit test` runs all tests located under $AUNIT_PROJECT_HOME
`aunit test ProjectName` runs all tests located under the folder matching `ProjectName` within $AUNIT_PROJECT_HOME.
`aunit test ProjectName TestEvent` applies the same filter as above, but also ensures only test events whose filename match the TestEvent filter will run.

For example, the 'Math' project located in $AUNIT_HOME/workspace can be run using the command `aunit test Math`. If a user wishes to run the IntegerTest.mon specifically, they can call `aunit test Math IntegerTest.mon`.

Finally, filtering is supported, such that `aunit test Math Integer*` would run any test whos name starts with 'Integer' and is located under the Math project.

## TestEvent Signature

A *TestEvent* is any *.mon file which matches the aunit *TestEvent* template - that is, it contains all of the following annotations:

    * //@Depends 
    * //@Test           (multiple permitted)
    * //@Initialise     (optional)
    * //@Setup          (optional)
    * //@Teardown       (optional)

**NB:** aunit is very particular about the location of annotation(s) within a *TestEvent* file. Annotations must be on exactly the line preceding the epl keyword it is expecting. 

## Test Build Process

When the `aunit test [ProjectName TestEvent]` command is executed, aunit scans the `$AUNIT_PROJECT_HOME` directory for any *.mon files which match the *TestEvent* signature as described above. 

For every *TestEvent* a corresponding pysys test is created in the `$AUNIT_HOME/.__test` directory. These pysys tests are then run with a custom ant loader which injects any project and file-level dependencies, with the result printed to console. For example when running `aunit test HelloWorld` the following folder structure is made:

```
$AUNIT_HOME/.__test
│
└───HelloWorldTest
│   │   pysystest.xml
│   │   run.py
│   │
│   └───Input
│       │   TestEvent.mon
│       │   TestRunner.mon
│       │   ...
│   
└───lib
│   │
│   └───aunit 
│       │
│       └─framework
│           AUNITCorrelator.py    

```

Pysys then runs against the above directory structure.

If a *TestEvent* or the build itself has any errors (such as invalid syntax), or you simply want to see more details such as the correlator.log,  the output of the pysys test run can be found in `$AUNIT_HOME/.__test/ProjectName/Output`. Looking to the files in this directory will give guidance on exactly what is occurring during the test run. Future versions of aunit may look to provide this information in the console output.

It is recommended when starting out with aunit that you use the HelloWorldTest.mon as a template for other tests to ensure you start off with a valid *TestEvent* signature. Further details on the annotations can be found below.

**NB:** Be careful to never save any content to the `$AUNIT_HOME/.__test` directory as its content is purged on every `aunit test` run. 

# Supported Annotations

As previously mentioned, aunit supports the following annotations:

    * //@Depends 
    * //@Test           (multiple permitted)
    * //@Initialise     (optional)
    * //@Setup          (optional)
    * //@Teardown       (optional)

NB: If a //Test annotation is identified and no corresponding //@Depends a warning is output to the console, and the TestEvent is not considered valid.

## //@Depends

Used to specify any *TestEvent* dependencies. Aunit supports both single *.mon file dependencies and project-level dependencies. Single file dependencies should be relativeily pathed, with $AUNIT_PROJECT_HOME ($AUNIT_HOME/workspace) as the default root directory.

Single file dependency sample: Math/test/FloatTest.mon

```
//@Depends Math/src/Float.mon
event MathFloatTest {
...
}
```

User-defined project dependency sample: Math/test/IntegerTest.mon

```
//@Depends Math
event MathIntegerTest {
...
}
```

Upon running `aunit test Math`, two pysys projects are created: `MathFloatTest` and `MathIntegerTest`. MathFloatTest will have Math/src/Float.mon injected upon running, whereas MathIntegerTest will have the whole of the Math project injected.

Please note that changes to project-level dependencies require an `aunit build` to be run prior to testing to ensure the tests run against the latest codebase.

Changes to *TestEvent* files and single file dependencies *do not* require an `aunit build` to take effect.

## //@Test

Used to define a test action. Aunit runs all test actions defined within a test file sequentially, with each prior test completing prior to starting the next. Two action signatures are supported: synchronous and asynchronous. Synchronous tests are assumed to be complete once the action returns, asynchronous tests wait for the cbDone callback to be called.

Test action sample: HelloWorld/test/HelloWorldTest.mon

```
//@Test     
action test_001 {
    // This synchronous test will complete immediately after the function returns.
    asserter.assertTrue("test_001", "hello world" = "hello world");  
}

//@Test
action test_002(action<> cbDone) {

    // This asynchronous test will complete once cbDone() is called. Failure to call cbDone() will result in a hanging test.

    SampleEvent s;

    on SampleEvent():s 
        and not wait(1.0) {
            asserter.assertString("SampleEvent valid", s.toString(), expected.toString());
            cbDone();
    }

    on wait(1.0) 
        and not SampleEvent() {
            asserter.assertTrue("SampleEvent not routed", false);
            cbDone();
    }

    route SampleEvent("hello world");
}
```

## //@Initialise

Initialise action is called once prior to running a *TestEvent*'s suite of test actions. The annotation must be on the line preceding the epl initialise action definition. Once initialisation is complete the usercode should call cbInit() to return execution back to the test runner to start running the unit tests.

```
//@Initialise
action init(action<> cbInit) {
    ...
    cbInit();
}
```

## //@Setup

Setup action called prior to running each test action. The annotation must be on the line preceding the epl setup action definition. Once setup is complete the usercode should call cbSetup() to return execution back to the test runner to begin the test.

```
//@Setup
action setup(action<> cbSetup) {
    ...
    cbSetup();
}
```    

## //@Teardown

Teardown action called after each test action completes. The annotation must be on the line preceding the epl teardown action definition. Once setup is complete the usercode should call cbSetup() to return execution back to the test runner to start the next test.

```
//@Teardown
action teardown(action<> cbTeardown) {
    cbTeardown();
}
```

# Asserter Event

The com.aunit.Asserter event allows users to perform assertsions within their *TestEvent* files. 

**NB:** Asserts must be made within a test action.

To use the asserter, simply import the *.bnd file to your SoftwareAG Studio, define it as a member of your *TestEvent* and from there, the Asserter can be used without initialisation.

```
//@Depends 
event SomeTestEvent {
    
    com.aunit.Asserter asserter;

    //@Test
    action test_001() {
        asserter.assertTrue("My assert", true);            // passes
        asserter.assertFloat("My float assert", 1.0, 1.1); // fails
    }

}
```

## Asserter Event Interface

Currently the asserter event supports the following interface:

```
action assertFloat(string ref, float a, float b);
action assertDecimal(string ref, decimal a, decimal b);    
action assertInteger(string ref, integer a, integer b);    
action assertBoolean(string ref, boolean a, boolean b);
action assertTrue(string ref, boolean a);
action assertFloatWithinThreshold(string ref, float a, float b, float error);
action assertString(string ref, string a, string b);

```

To assert two events are identical, use the paradigm

```
SomeEvent a := SomeEvent(1,2,3, "Some String Value");
SomeEvent b := SomeEvent(1,2,3, "Some String Value");

asserter.assertString("Comparing events a and b",
                      a.toString(), 
                      b.toString()
);
```

For more insight, view the source at `$AUNIT_HOME/project-build/epl/UnitTest/src/objects/Aunit.mon`

# AUnit Project Structure 

When installing aunit, users are required to export the `AUNIT_HOME` environment variable. This sets the default path for the user workspace, build and test directory locations.

By default, these directories sit under `$AUNIT_HOME` in `/workspace`, `/.__repository` and `/.__test` respectively.

The below tree reflects this:

```
$AUNIT_HOME
│
└───workspace
│   │   ...
│
└───.__repository
│   │   ...
│
└───.__test
│   │   ...


```

Users can override any or all of these paths by setting the following environment variables:

* `$AUNIT_PROJECT_HOME` (project source)
* `$AUNIT_BUNDLE_HOME`   (build output)
* `$AUNIT_TEST_HOME`    (test output)

**NB:** The `$AUNIT_TEST_HOME` and `$AUNIT_BUNDLE_HOME` directories are purged on `aunit test` and `aunit build` run commands. Users should never write to these directories, nor depend on their state to remain consistent between aunit runs.


# Aunit Build Process

Invariably once the project you are testing grows larger than a few files you will want to define it as a project-level dependency. This prevents the need to manually list the single file dependencies, and allows for multi-project dependencies to be resolved and their injection sequence managed. 

The aunit build process is responsible for creating user defined project-level dependencies. 

Using a `*.aunit` extension file, users can add a project to the build process.

When the `aunit build` command is run, the `$AUNIT_PROJECT_HOME` directory is scanned for any projects containing a `*.aunit` definition. Each user-defined project's source is copied to repository directory, with a corresponding *.cdp, *.bnd and ant-macro.xml definition created.

The resulting files are placed in the `$AUNIT_HOME/.__repository` directory.

User *TestEvent*s can then reference the project(s) using the `//@Depends` annotation. Additionally, users can add the `$AUNIT_HOME/.__repository/bundles` directory to their SoftwareAG Design Studio path to add built projects as dependencies within their studio. The aunit.xml macro definitions located in `$AUNIT_HOME/.__repository/ant_macros` can also be leveraged for production deployments.

## Defining custom project-level dependencies

Any valid apama project can be defined as a project-level dependency with a single *.aunit file (located in the projects root directory). 

A project-level *.aunit file specifies:

* Injection order of *.mon files
* User project-level dependencies
* SoftwareAG project-level dependencies

**NB:** TestEvent *.mon files should NEVER be defined at the project level. They are automatically injected at runtime by the test loader. Adding them to the project-level *.aunit definition can cause unexpected behaviour.

The below sample is taken from `$AUNIT_HOME/workspace/Math/Math.aunit` and is an example of a user-defined project-level dependency which itself, does not have any dependencies other than the project files:

```
<bundle name="Math"
        description="A basic project to demonstrate user-level project dependency testing."
        dir="../projects/Math"
        macro_dir="Math"
        depends="Math">

    <source ext="" macro="Math">
        <fileset dir="src">
            <include name="Integer.mon"/>
            <include name="Float.mon"/>
        </fileset>
    </source>

    <cdp ext="" macro="Math">
        <fileset>
            <include name="Math.cdp"/>
        </fileset>
    </cdp>

    <dependencies>
    </dependencies>
    
    <macros>
        <macro name="Math" unless="onlyMonitors">
        </macro>
    </macros>

</bundle>
```

Use the above file as a template when defining user project-level dependencies. Users could take this file, replacing references to `Math` and replacing with `UserProjectName` and updating the *.mon injection order as per the below:

```
<fileset dir="src">
    <include name="objects/UserFile1.mon"/>
    <include name="objects/UserFile2.mon"/>
    <include name="objects/UserFile3.mon"/>
</fileset>

```

Once a *.aunit file is created and placed in the `$AUNIT_PROJECT_HOME/ProjectName` directory, run the `aunit build` command to update your local repository.

## Defining Software-AG project-level dependencies

SoftwareAG provides *.bnd, *.cdp and ant-macro.xml files for some of their products (i.e. Capital Markets Framework).

Although slightly more involved, a *.aunit file can be extended to include such dependencies. 

Firstly, the ant-macros.xml or equivalent file needs to be added to aunit's known macro list. Users can define the custom ant import list by modifying $AUNIT_HOME/project-build/ant-macros/custom-imports.xml. A sample from this file is below where the currently commented import statement would be replaced with a valid path.

``` 
    <!-- Base APAMA CMF ant macro files, uncomment if CMF available -->
    <!-- import file="${env.APAMA_FOUNDATION_HOME}/ant_macros/CMF-macros.xml" / -->
```

Once the file dependency has been added to custom-imports.xml, users can update their *.aunit file to include relevant macro dependencies. Below is a sample of the Math.aunit which has been extended to include the memory store as a dependency.

```
<bundle name="Math"
        description="A basic project to demonstrate user-level project dependency testing."
        dir="../projects/Math"
        macro_dir="Math"
        depends="Math">

    <source ext="" macro="Math">
        <fileset dir="src">
            <include name="Integer.mon"/>
            <include name="Float.mon"/>
        </fileset>
    </source>

    <cdp ext="" macro="Math">
        <fileset>
            <include name="Math.cdp"/>
        </fileset>
    </cdp>

    <dependencies>
        <dependency bundle-filename="MemoryStore.bnd" catalog="${APAMA_HOME}/catalogs/bundles" />
    </dependencies>
    
    <macros>
        <macro name="Math" unless="onlyMonitors">
            <depends name="memory-store-bundle" />
        </macro>
    </macros>

</bundle>

```

For more information on utilising existing softwareAG packages please email me: antoine AT reltech.com

## AUNIT_CDP_BUILD Flag

By default, aunit builds are performed against project source. This ensures compatibility with the Apama Community and Core editions.

Users who are on a version of apama which supports custom *.cdp injection, may wish to change the build type to CDP.

This can be achieved by settin the `$AUNIT_CDP_BUILD` environment variable.

```
export AUNIT_CDP_BUILD=true
aunit build

...
*** Creating CDP Build ***
...
```

