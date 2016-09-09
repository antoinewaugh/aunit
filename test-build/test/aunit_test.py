__author__ = 'antoine'

from ..src import aunit

"""
	Remove single line comments
"""	

def test_remove_single_line_comments_noannotation():
	""" Test validates single comment removed """

	input_ = """line1
				line2 
				//comment
				line3 """

	expect = """line1
				line2 
				
				line3 """

	assert aunit.remove_single_line_comments(input_) == expect

def test_remove_single_line_comments_annotation():
	""" Test validates single comment removed, annotation left """

	input_ = """line1
				line2 
				//comment
				//@Test //comment
				//comment
				line3 """

	expect = """line1
				line2 
				
				//@Test //comment
				
				line3 """

	assert aunit.remove_single_line_comments(input_) == expect

"""
	TestEvent class tests
"""

def test_load_valid_testevent():

	with open('resource/SampleTestEvent_001.mon') as f:

		test_event = aunit.TestEvent(f.read())

		assert test_event.is_valid()
		assert test_event.get_package() == 'package com.aunit.sample;'
		assert test_event.get_event_name() == 'SampleUnitTest'
		assert test_event.get_setup_action() == 'setup'
		assert test_event.get_teardown_action() == 'teardown'
		assert test_event.get_initialise_action() == 'init'
		assert test_event.get_file_dependencies() == ['test/sample.mon']
		assert test_event.get_project_dependencies() == ['UnitTest']
		assert test_event.get_test_actions() == [('test_001', False),
												 ('test_002', False),
												 ('test_003', True),
												 ('test_004', True)]

