######################################################################
# AUnit README
######################################################################

# aunit

A packaging and unit test framework for Apama. 

Enables developers to write apama unit tests in native EPL, performing asserts on any part of their epl application. Additionally, to best support unit test's project-level dependency injection, aunit provides a means to package apama projects.

It is a command line tool, designed to work on both windows and linux. 

Currently aunit tests support:

    * Synchronous test actions
    * Asynchronous test actions
    * Setup/Teardown actions
    * Initialise action
    * External Project Referencing
    * External File Referencing
  
License: aunit is distributed under the terms of the MIT license, free and open source.

# HelloWorldTest.mon example:

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

The above test file can be found under $AUNIT_HOME/workspace/HelloWorld. 

To run the sample, follow the installation instructions below, and then open an apama command prompt and type:

```
$ aunit build
$ aunit test HelloWorldTest
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

You'll notice the `aunit build` command is run prior to running the test. This is because the HelloWorldTest.mon has a project dependency on `UnitTest` which an be seen on line 9 after the //@Depends annotation. Any time a dependent project(s) files have changed `aunit build` must be run to ensure the tests run against the latest project codebase.

Changes to TestEvent.mon files and single file dependency references, however, do not require a rebuild prior to running the `aunit test` command.

# Test Events & Test Build process

A test event is any *.mon file which match the aunit test event template - that is, it contains all of the following annotations:
    * //@Depends 
    * //@Test           (multiple permitted)
    * //@Initialise
    * //@Setup
    * //@Teardown

NB: aunit is very particular about the location of annotation(s) within a test event file. Annotations must be on exactly the line preceding the epl keyword it is expecting. 

For example, the line below a //@Test annotation must be an epl action definition. It is perfectly valid to have action definitions within a test event which are not themselves test actions, and as such the //@Test annotation must be used to signify to aunit that an assert is expected as a result of calling that action.

Similarly, the line after the //@Depends annotation must be an event definition. It is perfectly valid to have multiple event definitions within a test event file, although each test event file is limited to containing exactly one test event definition.

It is recommended when starting out with aunit that you use the HelloWorldTest.mon as a template for other tests to ensure you start off with a valid test event signature. Further details on the annotations can be found below.

To build and run the epl unit tests, users run `aunit test` from the command line. This process scans the $AUNIT_PROJECT_HOME directory for any *.mon files which match the test event signature, and create a corresponding pysys test (which is later run) in the $AUNIT_HOME/.__test directory. Be careful to never save any content to the $AUNIT_HOME/.__test directory as its content is puged on every `aunit test` run. The results of test are written to the console, however for further debugging and analysis users can refer to the `$AUNIT_HOME/.__test/<TestEventName>/Output` directory. 

# Supported Annotations

//@Depends

Used to specify any test event dependencies. Aunit supports single *.mon file dependencies and project-level dependencies.

Sample: SampleTestEvent.mon
```
//@Depends test/sample.mon, UnitTest
```

Before running the tests within SampleTestEvent.mon a correlator will be initilised with test/sample.mon and UnitTest project injected respectively. Please note that changes to project-level dependencies require an `aunit build` to be run prior to testing to ensure the tests run against the latest codebase.

Changes to test event files and single file dependencies do not require an `aunit build` to take effect.

//@Test

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

//@Initialise

Initiailse action is called once prior to running a test event's suite of test actions. The annotation must be on the line preceding the epl initialise action definition.

//@Setup

Setup action called prior to running each test action. The annotation must be on the line preceding the epl setup action definition.

//@Teardown

Teardown action called after each test action completes. The annotation must be on the line preceding the epl teardown action definition.

# Installation

To install, download and unzip the latest version from github. Next, export the $AUNIT_HOME, $AUNIT_PROJECT_HOME environment variables and add $AUNIT_HOME/bin to the $PATH.

```
wget github.com/aunit/latest.zip
unzip latest.zip -d /path_to_aunit

export AUNIT_HOME=/path_to_aunit
export AUNIT_PROJECT_HOME=$AUNIT_HOME/workspace
export PATH=$PATH:$AUNIT_HOME/bin
```

To test the success of the installation, run the aunit build and aunit test commands from an apama command prompt:

```
aunit build
aunit test
```

The test result should be written to the screen.

# Defining custom project-level dependencies

Invariably once the project you are testing is larger than a few files you will want to define it as a project-level dependency. This prevents the need to manually list the single file dependencies, and allows for multi-project dependencies to be resolved and their injection sequence managed. 

Creating aunit.xml files also has the added benefit of being able to reference the project in softwareAGs design studio as a dependency and also leveraging the generated $AUNIT_HOME/.__repository/aunit.xml ant macro file for ant (production) injection. 

NB: TestEvent files should NEVER be listed in the aunit.xml file. This will ensure that they are never compiled nor run in production. Instead, the `aunit test` process will manage their injection only in the test envirionment.

To define a project-level dependency, an aunit.xml file must be located in the root of the project. Projects should be defined withing the $AUNIT_HOME/workspace directory.

$AUNIT_HOME/workspace
                ProjectA/
                    aunit.xml
                    src/
                        fileA-1.mon
                        fileA-2.mon
                        fileA-3.mon
                        fileA-4.mon
                    test/
                        projectAtest.mon

To build this project, run `aunit build`.

This creates a *.cdp, *.bnd and aunit.xml file within the $AUNIT_HOME/.__repository which can be leveraged by the test runner. A sample output from the above would look like.

$AUNIT_HOME/.__repository
                /cdp
                    ProjectA.cdp
                /bnd
                    ProjectA.bnd
                /ant-macros
                    aunit.xml

# aunit.xml Sample file

The below snippet is from the UnitTest project located in $APAMA_HOME/workspace/UnitTest/UnitTest.xml. 

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
