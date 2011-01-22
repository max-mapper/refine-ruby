load '../lib/refine.rb'

prj = Refine.new('date cleanup', 'dates.txt')
prj.apply_operations('operations.json')
puts prj.export_rows('csv')
prj.delete_project