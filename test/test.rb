load '../lib/refine.rb'

prj = Refine.new({ "project_name" => 'date cleanup', "file_name" => 'dates.csv' })
prj.apply_operations('operations.json')
puts prj.export_rows('csv')
prj.delete_project