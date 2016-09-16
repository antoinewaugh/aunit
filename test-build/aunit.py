__author__ = 'antoine waugh: antoine@reltech.com'

import shutil
import getopt
import os, sys
from glob import glob
from collections import namedtuple

TestAction = namedtuple('TestAction', 'name is_async')

SINGLE_LINE_COMMENT = '//'
ANNOTATION = '//@'
NEWLINE = '\n'

def usage():
    print "Usage: aunit.py --aunit_home=dir --aunit_project_home=dir"
    print
    print "Scans test source directory for aunit test files and creates associated pysys tests"
    print
    print "  -a, --aunit_home=dir             Look for aunit home in specified directory."
    print "  -p, --aunit_project_home=dir     Look for test files in specified directory."
    print "  -s, --source_filename            Run only test event file provided."
    print "  -h, --help           Display this help message and exit"
    print
    sys.exit();

def remove_single_line_comments(content):
    """ Removes single line comments from a block of text

    Args: 
        content (string) 

    Returns: 
        string

    """
    lines = content.splitlines()
    for i,l in enumerate(lines):
        if ( l.find(SINGLE_LINE_COMMENT) != l.find(ANNOTATION) ) :
            l = l[:l.find(SINGLE_LINE_COMMENT)] # strip comment

        lines[i] = l    

    return NEWLINE.join(lines)

class TestEvent(object):

    """AUnit TestEvent File

    This class represents a single aunit TestEvent file.

    Args: 
       filepath: location of the TestEvent (string)
       content: file contents (string)
       project_path: project's base directory (string)

    """

    def __init__(self, content):
        self._annotations = {
                "TEST_ANNOTATION": "@Test",
                "SETUP_ANNOTATION": "@Setup",
                "TEARDOWN_ANNOTATION": "@Teardown",
                "DEPENDS_ANNOTATION": "@Depends",
                "INITIALISE_ANNOTATION": "@Initialise" }

        self._content = content.splitlines()
        self._test_actions = [] # [TestAction(name, is_async)]

        # Traverse file contents, populate member variables
        for i, line in enumerate(self._content):

            # Look ahead to next_line requires traversing to stop at linenumber -1
            if i == len(self._content)-1:
                return

            next_line = self._content[i+1]

            if self._line_contains_annotation(line):

                # Initialise Action
                if (self._line_contains(line, self._annotations["INITIALISE_ANNOTATION"]) and
                    self._line_contains_action(next_line) ):
                        self._initialise_action = self._get_action_name(next_line)

                # Setup Action
                elif (self._line_contains(line, self._annotations["SETUP_ANNOTATION"]) and
                      self._line_contains_action(next_line) ):
                        self._setup_action = self._get_action_name(next_line)

                # Teardown Action
                elif (self._line_contains(line, self._annotations["TEARDOWN_ANNOTATION"]) and
                      self._line_contains_action(next_line) ):
                        self._teardown_action = self._get_action_name(next_line)

                # Depends Annotation
                elif (self._line_contains(line, self._annotations["DEPENDS_ANNOTATION"])):

                    self._project_depends = self._get_project_dependencies(line)
                    self._file_depends = self._get_file_dependencies(line)

                    # Test Event Definition
                    if self._line_contains_event(next_line):
                        self._event_name = self._get_event_name(next_line)

                # Test Action
                elif (self._line_contains(line, self._annotations["TEST_ANNOTATION"]) and
                      self._line_contains_action(next_line) ):
                        action = TestAction(
                            name=self._get_action_name(next_line),
                            is_async=self._is_action_async(next_line)
                        )

                        self._test_actions.append(action)

            elif self._line_contains_package(line):
                self._package = line

    def get_content(self):
        """ Returns raw contents of test event (string) """
        return ''.join(self._content)

    def is_valid(self):
        """ Returns true if all annotation requirements,
            action and event definitions are met 

        """
        return ( 
            hasattr(self, '_file_depends') and
            hasattr(self, '_project_depends') and
            hasattr(self, '_package') and
            hasattr(self, '_event_name') and
            hasattr(self, '_initialise_action') and
            hasattr(self, '_setup_action') and
            hasattr(self, '_teardown_action') and
            len(self._test_actions) > 0
        )

    def get_package(self):
        """ Returns package declaration (string) """
        return self._package               

    def get_event_name(self):
        """ Returns test event name (string) """
        return self._event_name

    def get_setup_action(self):
        """ Returns setup action name (string) """
        return self._setup_action

    def get_teardown_action(self):
        """ Returns setup action name (string) """
        return self._teardown_action

    def get_initialise_action(self):
        """ Returns setup action name (string) """
        return self._initialise_action

    def get_test_actions(self):
        """ 
            Provides test action list in order of definition within TestEvent

            Returns:
                list(NamedTuple(string,boolean) )

                Where: string=action name, boolean: is_async

        """
        return self._test_actions

    def get_file_dependencies(self):
        """ Return monitor file dependency (list) """
        return self._file_depends

    def get_project_dependencies(self):
        """ Return project bundle dependency (list) """
        return self._project_depends
    
    def _line_contains_package(self, line):
        """ Returns True if package declaration found """
        return ( line.find('package ') > -1 and line.find(';') > -1 )
                
    def _line_contains(self, line, search):
        """ Returns True if search string found """
        return line.find(search) > -1                

    def _line_contains_annotation(self, line):
        """ Returns if line has recognised annotation (boolean) """
        for k,v in self._annotations.items():
            if self._line_contains(line, v):
                return True
        return False

    def _line_contains_action(self, line):
        """ Returns True if line contains 'action' """
        return self._line_contains(line, 'action ')

    def _line_contains_event(self, line):
        """ Returns True if line contains 'action' """
        return self._line_contains(line, 'event ')

    def _get_action_name(self, line):
        """ Returns action name, delimited by { or (} """
        action_str = 'action '
        start, end = line.find(action_str), line.find('{')

        if line.find('(') > -1:
            end = line.find('(')

        return line[start+len(action_str):end].strip()

    def _is_action_async(self, line):
        """ Retruns True if action contains callback parameter in signature """
        return self._line_contains(line, '(action<> ')

    def _get_event_name(self, l):
        """ Returns event name, delimited by { """
        event_str = 'event '
        return l[l.find(event_str)+len(event_str): l.find('{')-1].strip()

    def _get_project_dependencies(self, line):
        """ Returns list bundle dependency names """
        annotation = self._annotations["DEPENDS_ANNOTATION"]

        project_dependencies = ['UnitTest']
        for depend in line[line.find(annotation)+len(annotation):].split(","):
            if depend.find('.mon') == -1:
                if depend.strip() != "":
                    project_dependencies.append(depend.strip())
        return project_dependencies

    def _get_file_dependencies(self, line):
        """ Returns list of file dependency names """
        annotation = self._annotations["DEPENDS_ANNOTATION"]

        file_dependencies = []
        for depend in line[line.find(annotation)+len(annotation):].split(","):
            if depend.find('.mon') > -1:
                file_dependencies.append(depend.strip())
        return file_dependencies


#####################################
# Helper Actions
#####################################

def write_file(source_path, dest_path, substitutions={}):
    with open(dest_path, "wt") as fout:
        with open(source_path, "rt") as fin:
            for line in fin:
                for k, v in substitutions.items():
                    line = line.replace(str(k), str(v))
                fout.write(line)

def load_contents(filepath):
    with open(filepath, "rt") as f:
        return f.read()

def list_files(path, filenameFilter='*', source_dir=None):
    if source_dir:
        path = os.path.join(path, source_dir)
    return [y for x in os.walk(path) for y in glob(os.path.join(x[0], filenameFilter))]

def create_pysys_test(aunit_test, filename, aunit_template_dir, source_dir, output_dir):
    """ Creates a runnable pysys test.

        Using substitutions attainable from aunit_test, 
        creates all required *.py, *.mon and folder structure 
        for a pysys test.

        Uses *.template files located in $AUNIT_HOME/test-build/template for reference(s).
        
    """

    file_dependencies = []
    # Copy File References to resources directory

    for file in aunit_test.get_file_dependencies():

        dependency_filename = os.path.basename(file) 
        source_filepath = os.path.join(source_dir, file)

        dest_path = os.path.join(output_dir, 'resources')
        dest_filepath = os.path.join(dest_path, dependency_filename)

        if not os.path.isdir(dest_path):
            os.mkdir(dest_path)

        if os.path.isfile(source_filepath):
            # print copy in verbose mode
            print '\nCopying {} to {}\n'.format(source_filepath, dest_filepath)
            
            shutil.copy(
                source_filepath, 
                dest_filepath
            )

            file_dependencies.append(dependency_filename)

        else:
            print '\nInvalid file dependency listed within {}: {}. Moving to next test. \n'.format(
                aunit_test.get_event_name(),
                source_filepath
            ) 

            return

    pysys_asserts=''
    testrunner_load_list=''

    # For each test action:
    #   - write EPL load command to be substituted into TestRunner.mon template
    #   - write pysys assert command to be substituted into run.py template

    for test_action in aunit_test.get_test_actions():

        # Load Asynchronous action into EPL test runner
        if test_action.is_async:

            testrunner_load_list += 't.loadAsynchronous("{}:{}",tests.{});\n'.format(
                aunit_test.get_event_name(), 
                test_action.name, 
                test_action.name)

        # Load Synchronous action into EPL test runner
        else:

            testrunner_load_list += 't.loadSynchronous("{}:{}",tests.{});\n'.format(
                aunit_test.get_event_name(), 
                test_action.name, 
                test_action.name)

        # Pysys assert command for current test action
        pysys_asserts += """\t\tself.assertLineCount(file="correlator.log", expr="{}:{} : PASSED.", condition="==1", assertMessage="{}:{}") \n""".format(
                aunit_test.get_event_name(),
                test_action.name, 
                aunit_test.get_event_name(), 
                test_action.name)


    # Define File Dependencies (if any)
    resources_dir = '"{}"'.format(os.path.join(output_dir, 'resources'))
    if len(file_dependencies) > 0:
        file_dependencies = 'correlator.injectMonitorscript(filenames={}, filedir={})'.format(
            file_dependencies,
                resources_dir.replace('\\', '\\\\')
            )
    else:
        file_dependencies = ''

    substitutions = {
            '{!depends_bundles}': aunit_test.get_project_dependencies(),
            '{!inject_depends_file_command}': file_dependencies,
            '{!asserts}': pysys_asserts,
            '{!packagename}': aunit_test.get_package(),
            '{!eventname}': aunit_test.get_event_name(),
            '{!load_list}': testrunner_load_list,
            '{!setupaction}': aunit_test.get_setup_action(),
            '{!teardownaction}': aunit_test.get_teardown_action(),
            '{!initialiseaction}': aunit_test.get_initialise_action()
        }

    # Ensure target directory does not yet exist

    # Prepare the pysys test directories
    test_path = os.path.join(output_dir, aunit_test.get_event_name())
    test_input_path = os.path.join(test_path, 'Input')

    if not os.path.isdir(test_path):
        os.mkdir(test_path)

    if not os.path.isdir(test_input_path):
        os.mkdir(test_input_path)

    # Write pysystest.xml
    write_file(
        os.path.join(aunit_template_dir, 'pysystest.template'), 
        os.path.join(test_path, 'pysystest.xml'), 
        {'{!eventname}':aunit_test.get_event_name()}
    )
    
    # Write run.py
    write_file(
        os.path.join(aunit_template_dir, 'run_fast.py.template'), 
        os.path.join(test_path, 'run.py'), 
        substitutions
    )

    # Write TestEvent.mon
    write_file(
        filename,
        os.path.join(test_input_path, 'TestEvent.mon'),
        {}
    )       

    # Write TestRunner.mon
    write_file(
        os.path.join(aunit_template_dir, 'TestRunner_fast.mon.template'),
        os.path.join(test_input_path, 'TestRunner.mon'),
        substitutions
        )
    
################################################################################
#
# Entry point
#

def main(argv):

    source_project = None
    
    aunit_home = os.environ.get('AUNIT_HOME')
    aunit_project_home = os.environ.get('AUNIT_PROJECT_HOME')

    try:
        opts, args = getopt.getopt(argv, "ha:p:s:", ["help", "aunit_home=", "aunit_project_home=", "source_project="])
    except getopt.GetoptError, err:
        print err
        print
        usage()
    for o, a in opts:
        if o in ["-h", "--help"]:
            usage()
        if o in ["-a", "--aunit_home"]:
            aunit_home = a
        if o in ["-p", "--aunit_project_home"]:
            aunit_project_home = a
        if o in ["-s", "--source_project"]:
            source_project = a

    print "AUNIT_HOME: {}".format(aunit_home)
    print "AUNIT_PROJECT_HOME: {}".format(aunit_project_home)

    # Validate AUNIT_HOME and AUNIT_PROJECT_HOME exist
    if not os.path.isdir(aunit_home) or \
        not os.path.isdir(aunit_project_home):
            print "AUNIT_HOME/AUNIT_PROJECT_HOME provided were not valid directories."
            sys.exit(2)


    # Purge AUNIT_HOME/.__test directory if it exists
    test_output_dir = os.path.join(aunit_home, '.__test')

    if os.path.isdir(test_output_dir):
        if not os.access(test_output_dir, os.W_OK):
            os.chmod(path, stat.S_IWUSR)
        shutil.rmtree(test_output_dir, ignore_errors=True)
    if not os.path.isdir(test_output_dir):
        os.mkdir(test_output_dir)

    # Copy Common Test Directories and Files
    aunit_test_build_dir = os.path.join(aunit_home, 'test-build')
    aunit_template_dir = os.path.join(aunit_test_build_dir, 'template')

    shutil.copy(
        os.path.join(aunit_template_dir, 'runtests.bat'), 
        os.path.join(test_output_dir,'runtests.bat')
    )

    shutil.copy(
        os.path.join(aunit_template_dir, 'runtests.sh'), 
        os.path.join(test_output_dir,'runtests.sh')
    )

    shutil.copy(
        os.path.join(aunit_template_dir, 'pysysproject.xml'), 
        os.path.join(test_output_dir,'pysysproject.xml')
    )

    shutil.copytree(
        os.path.join(aunit_test_build_dir, 'lib'), 
        os.path.join(test_output_dir,'lib')
    )

    # For Each Valid TestEvent located in $AUNIT_PROJECT_HOME, 
    # create pysys test
    for file in list_files(aunit_project_home, '*.mon', source_project): 
       
        aunit_test = TestEvent(load_contents(file))

        # Determine if *.mon matches test event signature
        if aunit_test.is_valid():
            create_pysys_test(aunit_test=aunit_test, 
                              filename=file,
                              aunit_template_dir=aunit_template_dir,
                              source_dir=aunit_project_home,
                              output_dir=test_output_dir)


if __name__ == "__main__":

    main(sys.argv[1:])
   