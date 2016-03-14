gem 'minitest'
require 'minitest/autorun'
require_relative '../lib/refine.rb'

class TestRefine < MiniTest::Unit::TestCase
	
  def setup
    @refine_project = Refine.new({ "project_name" => 'date_cleanup', "file_name" => '../test/dates.txt' })
  end
	
	def test_refine_initializer_has_instance_variable_project_name
		assert_equal 'date_cleanup', @refine_project.project_name
	end
  
  def test_refine_initializer_has_instance_variable_project_id
    assert @refine_project.project_id.match(/^[0-9]+$/)
  end
  
  def test_get_all_project_metadata
    assert Refine.get_all_project_metadata.instance_of? Hash
  end
  
  def test_apply_operations
    assert @refine_project.apply_operations( '../test/operations.json' )
  end
  
  def test_call
     assert @refine_project.call( 'apply-operations', 'operations' => File.read( 'operations.json' ) )
  end
    
  def after_tests
    @refine_project.delete_project
  end
  
end
