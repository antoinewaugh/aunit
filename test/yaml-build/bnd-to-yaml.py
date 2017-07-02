
from xml.dom.minidom import parse, parseString
import os

"""
    Converts a traditional apama *.bnd project
    descriptor to aunit yaml format.
"""
def build_yaml(filename):

    dom = parse(filename)

    for monitor in dom.getElementsByTagName('monitors'):
        for fileset in monitor.getElementsByTagName('fileset'):
            for include in monitor.getElementsByTagName('include'):
                print os.path.join(fileset.getAttribute('dir'), include.getAttribute('name'))
   
    for dependencies in dom.getElementsByTagName('dependencies'):
        for dependency in dependencies.getElementsByTagName('dependency'):

            path = os.path.join(
                    dependency.getAttribute('catalog'),
                    dependency.getAttribute('bundle-filename')
            )

            print path
        
        



"""
    Idea to support dependent injection list(s) ideally for aunit's use but works otherwise.

    Extend to do builds in sublime

    Steps:

        Scan all *.bnd files and generate equivalent yaml

"""
    
    
if __name__=="__main__":
    build_yaml('/home/antoine/softwareag/ApamaCapitalMarketsFoundation/bundles/Adapter Bridging.bnd')

