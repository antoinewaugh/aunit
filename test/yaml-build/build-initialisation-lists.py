import yaml
import fnmatch
import os

"""
	Todo:
		- write parser of existing *.bnd files to create aunit yaml files from source
		- cleanup get_task_batches to support a single batch

"""

"""
	Dependency resolution function get_task_batches taken 
	from http://winappdbg.sourceforge.net/blog/example-dependencies.py
"""

class Project(object):
    def __init__(self, name, *depends):
        self.__name    = name
        self.__depends = set(depends)

    @property
    def name(self):
        return self.__name

    @property
    def depends(self):
        return self.__depends


# "Batches" are sets of tasks that can be run together
def get_task_batches(nodes):

    # Build a map of node names to node instances
    name_to_instance = dict( (n.name, n) for n in nodes )

    # Build a map of node names to dependency names
    name_to_deps = dict( (n.name, set(n.depends)) for n in nodes )

    # This is where we'll store the batches
    batches = []

    # While there are dependencies to solve...
    while name_to_deps:

        # Get all nodes with no dependencies
        ready = {name for name, deps in name_to_deps.iteritems() if not deps}

        # If there aren't any, we have a loop in the graph
        if not ready:
            msg  = "Circular dependencies found!\n"
            raise ValueError(msg)

        # Remove them from the dependency graph
        for name in ready:
            del name_to_deps[name]
        for k,deps in name_to_deps.items():
            deps.difference_update(ready)

        # Add the batch to the list
        batches.append( {name_to_instance[name] for name in ready} )

    # Return the list of batches
    return batches


def valid_project_file(content):

	if not 'type' in content: return False 
	if not content['type'] == 'aunit': return False

	if not 'name' in content: return False 
	if not type(content['name']) == str : return False

	if not 'files' in content: return False 
	if not type(content['files']) == list: return False

	if 'depends' not in content \
		or content['depends'] is None:
			content['depends'] = []

	return True		


def expand_dependency(name_to_deps, dep_list, name):
	for dep in name_to_deps[name]['depends']:
		if dep not in dep_list:
			dep_list.append(dep)
			expand_dependency(name_to_deps, dep_list, dep)


if __name__=="__main__":


	# Recursively search for all aunit yaml files
	yaml_filepaths = []
	for root, dirnames, filenames in os.walk('.'):
	    for filename in fnmatch.filter(filenames, '*.yaml'):
	        yaml_filepaths.append(os.path.join(root, filename))


	# Build project object from yaml file matches
	projects_files = {}
	for yamlfile in yaml_filepaths:
		with open(yamlfile, "r") as y:
			try:
				project = yaml.load(y)

				if valid_project_file(project):	
					projects_files[project['name']] = project

			except yaml.YAMLError as e:
				pass


	# For each project, expand & order project depdendency list 

	inject_sequence = {}

	for project in projects_files:

		inject_sequence[project] = []

		expanded_dependency_list = []
		expand_dependency(projects_files, expanded_dependency_list, project)	

		# Given expanded dependency list, build injection order
		nodes = []
		for dep in expanded_dependency_list:
			nodes.append(Project(dep, *projects_files[dep]['depends'])	)

		try:
	 		for bundle in get_task_batches(nodes):
	 			for node in bundle:
	 				inject_sequence[project].append(node.name)

		except ValueError as e:
	 		print(e)

	# For each project, build filelist

	project_to_filelist = {}
	for project in projects_files:
		filelist = []
		for dep in inject_sequence[project]:
			filelist.extend(projects_files[dep]['files'])
		filelist.extend(projects_files[project]['files'])

		project_to_filelist[project] = filelist

	print(project_to_filelist)

		

