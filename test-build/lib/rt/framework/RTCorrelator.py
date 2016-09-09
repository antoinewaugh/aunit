import os, logging, sys
from pysys import log
from apama.common import stringToUnicode
from apama.correlator import CorrelatorHelper
from pysys.constants import TRUE,FALSE,FOREGROUND,BACKGROUND,PROJECT,FAILED, ENVSEPERATOR


class RTCorrelatorHelper(CorrelatorHelper):

    def __init__(self, parent, port=None, host=None):
        CorrelatorHelper.__init__(self, parent, port, host)
        self.log = self.parent.log 
        self.eventSender = None

        self.AntAunitImports = os.path.join(os.environ['AUNIT_HOME'], '.__repository', 'ant_macros', 'aunit-imports.xml')

        #################################################################
        # Set Classpath for ANT Call
        #################################################################
        
        self.ANT_HOME = os.environ['ANT_HOME']
        self.environ = {} 
        for key in os.environ: self.environ[stringToUnicode(key)] = stringToUnicode(os.environ[key])
        self.environ['CLASSPATH'] = ''
        self.environ['CLASSPATH'] = os.path.join(self.ANT_HOME) + ENVSEPERATOR + self.environ['CLASSPATH']
        self.environ['CLASSPATH'] = os.path.join(self.ANT_HOME, 'lib', 'ant-launcher.jar') + ENVSEPERATOR + self.environ['CLASSPATH']
        self.environ['CLASSPATH'] = os.path.join(getattr(PROJECT,"APAMA_HOME"), 'lib', 'engine_client%s.jar' % getattr(PROJECT,"APAMA_LIBRARY_VERSION")) + ENVSEPERATOR + self.environ['CLASSPATH']
        self.environ['CLASSPATH'] = os.path.join(getattr(PROJECT,"APAMA_HOME"), 'lib', 'util%s.jar' % getattr(PROJECT,"APAMA_LIBRARY_VERSION")) + ENVSEPERATOR + self.environ['CLASSPATH']
        self.environ['CLASSPATH'] = os.path.join(PROJECT.root, 'tools', 'classes') + ENVSEPERATOR + self.environ['CLASSPATH']
        self.environ['CLASSPATH'] = os.path.join(getattr(PROJECT,"APAMA_HOME"), 'lib') + ENVSEPERATOR + self.environ['CLASSPATH']
        self.environ['CLASSPATH'] = os.path.join(getattr(PROJECT,"APAMA_HOME"), 'bin') + ENVSEPERATOR + self.environ['CLASSPATH']
        self.environ['CLASSPATH'] = stringToUnicode(self.environ['CLASSPATH'])


    def activateServiceFramework(self):
        self.sendLiteral("com.apama.config.Activate()")
        
    def sendLiteral(self, string):
        if self.eventSender == None:
            self.eventSender = self.send(state=BACKGROUND)
        self.eventSender.write(string)
        
    def injectBundles(self, targets=[], verbose=FALSE):
        self.launchAnt(buildFile=self.AntAunitImports, targets=targets, verbose=verbose)
        
    def launchAnt(self, buildFile, properties={}, targets=[], verbose=FALSE):
        """Run an ant task in the supplied working directory.
          
        """
        properties['correlator.host'] = self.host
        properties['correlator.port'] = self.port
        
        # set the command and display name
        command = os.path.join(self.environ['JAVA_HOME'], 'bin', 'java')
        displayName = 'ANT'
        
        tempFilePath = os.path.join(self.parent.output,'build.xml')
        file = open(tempFilePath,'w')
        file.write('<project default="go">\n')
        file.write('\t<target name="go">\n')
        file.write('\t\t<ant inheritAll="true" antfile="%s">\n' % buildFile)
        for target in targets:
            file.write('\t\t\t<target name="%s"/>\n' % target)
        file.write('\t\t</ant>\n')
        file.write('\t</target>\n')
        file.write('</project>')
        file.flush()
        file.close()
        
        #setup args
        args=[]
        args.append("-classpath")
        args.append(self.environ['CLASSPATH'])        
        args.append("-Dant.home=%s" % self.ANT_HOME)
        for property in properties.keys():
            args.append("-D%s=%s" % (property, properties[property]))  
        args.append("org.apache.tools.ant.launch.Launcher")
        if verbose:
            args.append("-verbose")
        args.append("-f")
        args.append(tempFilePath)
            
        self.log.info('Running ant')
       
        dstdout = "%s/ant.out"%self.parent.output
        dstderr = "%s/ant.err"%self.parent.output
	
        # run the process and return the handle
        return self.parent.startProcess(command, args, self.environ, self.parent.project.root, state = FOREGROUND, stdout = dstdout, stderr = dstderr, displayName = displayName)
 