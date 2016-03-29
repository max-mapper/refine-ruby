### NOTE: The internal client-server protocol used by OpenRefine is not yet maintained as a stable external API, subject to change. ###
### Therefore, plase indicate changes you notice to kittelmann@sub.uni-goettingen.de ###
### Some examples require cURL http://curl.haxx.se ###
### It is assumed that examples are run from the 'test' directory. Otherwise paths need to be adjusted. 
load '../lib/refine.rb'

##########################
### create initial project
##########################
prj = Refine.new({ 'project_name' => 'date_cleanup', 'file_name' => 'dates.csv' })


##########################
### create another project 
##########################
prj.create_project( 'date_cleanup', 'dates.txt' )                          # return value = project id, example: 1484090391100


################
### do something
################
prj.apply_operations( 'operations.json' )                                  # return value = status code, example: {'code'=>'ok'}


######################
### extract operations
######################
prj.get_operations                                                          # return value = operations as Hash

######################################
### save extracted operations to file:
######################################
extracted_operations = prj.get_operations
File.open('../test/extracted_operations.json', 'w') do |f|
  f.write extracted_operations
end


###############
### export data
###############
prj.export_rows                                                              # return value = exported data as tsv 
prj.export_rows( {'format'=>'tsv'} )                                         # return value = exported data as tsv   
prj.export_rows( {'format'=>'csv'} )                                         # return value = exported data as csv

### export data in custom table format
prj.export_rows( { 'options'=>{'separator'=>';','lineSeparator'=>'\n'} } )   # return value = exported data as *sv with semicolon for separator

### additional options available:
prj.export_rows( { 'options'=>{'separator'=>';','lineSeparator'=>'\n', 'outputColumnHeaders'=>true, 'outputBlankRows'=>true, 'columns'=>[{'name'=>'Date1'}] } } )
prj.export_rows( { 'options'=>{'separator'=>';','lineSeparator'=>'\n', 'outputColumnHeaders'=>false, 'outputBlankRows'=>false } } )

### save extracted data to file:
exported_data = prj.export_rows( {'format'=>'csv'} )
File.open('../test/exported_data.csv', 'w') do |f| # works
  f.write exported_data
end


##################################
### export data using own template
##################################

### construct template as url-encoded string
prefix = '%7B%0D%0A++%22rows%22+%3A+%5B%0D%0A'
suffix = '%0D%0A++%5D%0D%0A%7D'
separator = '%2C%0D%0A'
row_template = '++++%7B%0D%0A++++++%22Column+1%22+%3A+%7B%7Bjsonize%28cells%5B%22Column+1%22%5D.value%29%7D%7D%0D%0A++++%7D'

### call (using cURL http://curl.haxx.se)
data = "engine=%7B%22facets%22%3A%5B%5D%2C%22mode%22%3A%22row-based%22%7D&project=#{prj.project_id}&format=template&sorting=%7B%22criteria%22%3A%5B%5D%7D&prefix=#{prefix}&suffix=#{suffix}&separator=#{separator}&template=#{row_template}"
system "curl --data #{'"' + data + '"'} http://127.0.0.1:3333/command/core/export-rows/"

### save extracted data to file:
system "curl --data #{'"' + data + '"'} http://127.0.0.1:3333/command/core/export-rows/ > exported_data.json"

### let Ruby do the URL encoding of the template
prefix       = CGI.escape('{
  "rows" : [
')
suffix       = CGI.escape('
  ]
}')
separator    = CGI.escape(',
')
row_template = CGI.escape('    {
      "Column 1" : {{jsonize(cells["Column 1"].value)}}
    }')
data = "engine=%7B%22facets%22%3A%5B%5D%2C%22mode%22%3A%22row-based%22%7D&project=#{prj.project_id}&format=template&sorting=%7B%22criteria%22%3A%5B%5D%7D&prefix=#{prefix}&suffix=#{suffix}&separator=#{separator}&template=#{row_template}"
system "curl --data #{'"' + data + '"'} http://127.0.0.1:3333/command/core/export-rows/"


#################
### rename column
#################
prj.rename_column( { 'oldColumnName'=>'Date', 'newColumnName'=>'Date1' } )   # return value = status Hash, e.g. {"code"=>"ok", "historyEntry"=>{"id"=>1438598625335, "description"=>"Rename column Date to Date1", "time"=>"2015-08-03T12:29:53Z"}}


############
### metadata
############
prj.get_project_metadata                                                     # return value = metadata as Hash
prj.get_all_project_metadata                                                 # return value = metadata for all projects as Hash


##################
### delete project
##################
prj.delete_project                                                           # return value = status, e.g. ok