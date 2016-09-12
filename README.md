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

For comments and suggestions please email antoine@reltech.com

# Installation

To install, download and unzip the latest version from github. Export the $AUNIT_HOME, $AUNIT_PROJECT_HOME environment variables. From an *apama command prompt* type the following:

```
wget https://github.com/antoinewaugh/aunit/archive/master.zip
unzip aunit-master.zip

export AUNIT_HOME=/path/to/aunit-master
export AUNIT_PROJECT_HOME=$AUNIT_HOME/workspace
```

To test the success of the installation, run the aunit build and aunit test commands from an apama command prompt:

```
cd $AUNIT_HOME/bin
aunit build
aunit test
```

The test result should be written to the screen.

```
2016-09-12 11:33:44,796 INFO  ==============================================================
2016-09-12 11:33:44,806 INFO  Id   : HelloWorldTest
2016-09-12 11:33:44,809 INFO  Title: HelloWorldTest
2016-09-12 11:33:44,812 INFO  ==============================================================
2016-09-12 11:33:46,657 INFO
2016-09-12 11:33:46,658 INFO  cleanup:
2016-09-12 11:33:46,713 INFO  Executed shutdown <correlator>, exit status 0
2016-09-12 11:33:46,714 INFO
2016-09-12 11:33:46,716 INFO  Test duration: 1.92 secs
2016-09-12 11:33:46,717 INFO  Test final outcome:  PASSED
2016-09-12 11:33:46,719 INFO
2016-09-12 11:33:46,743 INFO  ==============================================================
2016-09-12 11:33:46,744 INFO  Id   : TestingUnitTest
2016-09-12 11:33:46,746 INFO  Title: TestingUnitTest
2016-09-12 11:33:46,747 INFO  ==============================================================
2016-09-12 11:33:49,413 INFO
2016-09-12 11:33:49,414 INFO  cleanup:
2016-09-12 11:33:49,469 INFO  Executed shutdown <correlator>, exit status 0
2016-09-12 11:33:49,519 INFO
2016-09-12 11:33:49,522 INFO  Test duration: 2.77 secs
2016-09-12 11:33:49,523 INFO  Test final outcome:  PASSED
2016-09-12 11:33:49,525 INFO
2016-09-12 11:33:49,545 CRIT
2016-09-12 11:33:49,546 CRIT  Test duration: 4.75 (secs)
2016-09-12 11:33:49,549 CRIT
2016-09-12 11:33:49,549 CRIT  Summary of non passes:
2016-09-12 11:33:49,551 CRIT    THERE WERE NO NON PASSES

```

**NB:** Due to a bug with the version of ant which ships with apama, please ignore any *[xslt]: Warning* messages referring to the JAXSAXParser. It does not affect the result of the build.

# HelloWorld

The HelloWorld project located in $AUNIT_HOME/workspace/HelloWorld demonstrates a working aunit *Test Event*, with all supported annotations. 

## HelloWorldTest.mon example:

```
package com.aunit.sample;

using com.aunit.Asserter;

event SampleEvent {
    string value;
}

//@Depends UnitTest
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
$ cd $AUNIT_HOME/bin
$ aunit build
$ aunit test HelloWorld
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

You'll notice the `aunit build` command is run prior to running the test. This is because the HelloWorldTest.mon has a project dependency on `UnitTest` which an be seen on line 9 after the `//@Depends` annotation. Any time a dependent project(s) files have changed `aunit build` must be run to ensure the tests run against the latest project codebase.

Changes to TestEvent.mon files and single file dependency references, however, do not require a rebuild prior to running the `aunit test` command.

# Test Events & Test Build Process

## Test Event Signature

A test event is any *.mon file which matches the aunit test event template - that is, it contains all of the following annotations:

    * //@Depends 
    * //@Test           (multiple permitted)
    * //@Initialise
    * //@Setup
    * //@Teardown


**NB:** aunit is very particular about the location of annotation(s) within a test event file. Annotations must be on exactly the line preceding the epl keyword it is expecting. 

## Test Build Process

When the `aunit test [ProjectName]` command is executed, aunit scans the $AUNIT_PROJECT_HOME directory for any *.mon files which match the *Test Event* signature as described above. 

For every *Test Event* a corresponding pysys test is created in the `$AUNIT_HOME/.__test` directory. These pysys tests are then run with a custom ant loader which injects any project and file-level dependencies, with the result printed to console. For example when running `aunit test HelloWorld` the following folder structure is made:

```
$AUNIT_HOME/.__test
│
└───HelloWorldTest
│   │   pysystest.xl
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

If a *Test Event* or the build itself has any errors (such as invalid syntax), or you simply want to see more details such as the correlator.log,  the output of the pysys test run can be found in $AUNIT_HOME/.__test/ProjectName/Output. Looking to the files in this directory will give guidance on exactly what is occurring during the test run. Future versions of aunit may look to provide this information in the console output.

It is recommended when starting out with aunit that you use the HelloWorldTest.mon as a template for other tests to ensure you start off with a valid test event signature. Further details on the annotations can be found below.

**NB:** Be careful to never save any content to the `$AUNIT_HOME/.__test` directory as its content is purged on every `aunit test` run. 

# Supported Annotations

As previously mentioned, aunit supports the following annotations:

    * //@Depends 
    * //@Test           (multiple permitted)
    * //@Initialise
    * //@Setup
    * //@Teardown

The current version of aunit requires all annotations exist in a *Test Event* file for it to be considered valid.

## //@Depends

Used to specify any test event dependencies. Aunit supports single *.mon file dependencies and project-level dependencies.

Sample: SampleTestEvent.mon
```
//@Depends test/sample.mon, UnitTest
event SampleTestEvent { 
...
}
```

Before running the tests within SampleTestEvent.mon a correlator will be initilised with test/sample.mon and UnitTest project injected respectively. Please note that changes to project-level dependencies require an `aunit build` to be run prior to testing to ensure the tests run against the latest codebase.

Changes to test event files and single file dependencies do not require an `aunit build` to take effect.

## //@Test

Used to define a test action. Aunit runs all test actions defined within a test file sequentially, with each prior test completing prior to starting the next. Two action signatures are supported: synchronous and asynchronous. Synchronous tests are assumed to be complete once the action returns, asynchronous tests wait for the cbDone callback to be called.

Sample: SampleTestEvent.mon

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
            and not on wait(1.0) {
                asserter.assertString(s.toString(), expected.toString());
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

Initiailse action is called once prior to running a test event's suite of test actions. The annotation must be on the line preceding the epl initialise action definition. Once initialisation is complete the usercode should call cbInit() to return execution back to the test runner to start running the unit tests.

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

# Aunit Build Process

Invariably once the project you are testing grows larger than a few files you will want to define it as a project-level dependency. This prevents the need to manually list the single file dependencies, and allows for multi-project dependencies to be resolved and their injection sequence managed. 

The aunit build process is responsible for creating user defined project-level dependencies. 

Using a `*.aunit` extension file, users can add a project to the build process.

When the `aunit build` command is run, the `$AUNIT_PROJECT_HOME` directory is scanned for any projects containing a `*.aunit` definition. Each user-defined project is then compiled in to a *.cdp, with a corresponding *.bnd and ant-macro.xml definition created.

The resulting files are placed in the `$AUNIT_HOME/.__repository` directory.

User Test Events can then reference the project(s) using the `//@Depends` annotation. Additionally, users can add the `$AUNIT_HOME/.__repository/bundles` directory to their SoftwareAG Design Studio path to add built projects as dependencies within their studio. The aunit.xml macro definitions located in `$AUNIT_HOME/.__repository/ant_macros` can also be leveraged for production deployments.

## Defining custom project-level dependencies

Any valid apama project can be defined as a project-level dependency with a single *.aunit file (located in the projects root directory). 

A project-level *.aunit file specifies:

* Injection order of *.mon files
* User project-level dependencies
* SoftwareAG project-level dependencies

**NB:** Test Event *.mon files should NEVER be defined at the project level. They are automatically injected at runtime by the test loader. Adding them to the project-level *.aunit definition can cause unexpected behaviour.

The below sample is taken from `$AUNIT_HOME/workspace/UnitTest/UnitTest.aunit` and is an example of a user-defined project-level dependency which itself, does not have any dependencies other than the project files:

```
<bundle name="UnitTest"
        description="A framework for providing UnitTest functionality in EPL. To be used with AUnit."
        dir="../projects/UnitTest"
        depends="UnitTest">

    <source ext="" macro="UnitTest">
        <fileset dir="src">
            <include name="objects/AUnit.mon"/>
        </fileset>
    </source>

    <cdp ext="" macro="UnitTest">
        <fileset>
            <include name="UnitTest.cdp"/>
        </fileset>
    </cdp>

    <dependencies>
    </dependencies>
    
    <macros>
        <macro name="UnitTest" unless="onlyMonitors">
        </macro>
    </macros>

</bundle>
```

Use the above file as a template when defining user project-level dependencies. Users could take this file, replacing references to `UnitTest` and replacing with `UserProjectName` and updating the *.mon injection order as per the below:

```
<fileset dir="src">
    <include name="objects/UserFile1.mon"/>
    <include name="objects/UserFile2.mon"/>
    <include name="objects/UserFile3.mon"/>
</fileset>

```

Once a *.aunit file is created and placed in the `$AUNIT_HOME/workspace/ProjectName` directory, run the `aunit build` command to update your local repository.

## Defining Software-AG project-level dependencies

SoftwareAG provides *.bnd, *.cdp and ant-macro.xml files for some of their products (i.e. Capital Markets Framework).

Although slightly more involved, a *.aunit file can be extended to include such dependencies. 

Firstly, the ant-macros.xml or equivalent file needs to be added to aunit's known macro list. This can be found in $AUNIT_HOME/project-build/ant-macros/aunit-imports.xml. A sample from this file is below where the currently commented import statement would be replaced with a valid path.

``` 
    <!-- Base APAMA CMF ant macro files, uncomment if CMF available -->
    <!-- import file="${env.APAMA_FOUNDATION_HOME}/ASB/ant_macros/adapter-support-macros.xml" / -->
```

Once the aunit-imports.xml is updated the *.aunit file must be updated to include relevant dependencies. Below is a sample of the UnitTest.aunit which has been extended to include the memory store as a dependency.

```
<bundle name="UnitTest"
        description="A framework for providing UnitTest functionality in EPL. To be used with AUnit."
        dir="../projects/UnitTest"
        depends="UnitTest">

    <source ext="" macro="UnitTest">
        <fileset dir="src">
            <include name="objects/AUnit.mon"/>
        </fileset>
    </source>

    <cdp ext="" macro="UnitTest">
        <fileset>
            <include name="UnitTest.cdp"/>
        </fileset>
    </cdp>

    <dependencies>
        <dependency bundle-filename="MemoryStore.bnd" catalog="${APAMA_HOME}/catalogs/bundles" />
    </dependencies>
    
    <macros>
        <macro name="UnitTest" unless="onlyMonitors">
            <depends name="memory-store-bundle" />
        </macro>
    </macros>

</bundle>

```

For more information on utilising existing softwareAG packages please email me: antoine@reltech.com

