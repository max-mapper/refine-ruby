load 'refine.rb'

project_name = 'woot'
project_id = create_project(project_name, '/dates.txt')
apply_operations(project_id, '/operations.json')
p export_rows(project_id, project_name)
delete_project(project_id)