require 'httpclient'
require 'cgi'
require 'json'

class Refine
  def initialize(project_name, file_name, server="http://127.0.0.1:3333")
    project_name = CGI.escape(project_name)
    @server = server
    @project_id = create_project(project_name, file_name)
    @project_name = project_name if @project_id
  end
  
  def create_project(project_name, file_name)
    uri = @server + "/command/core/create-project-from-upload"
    project_id = false
    client = HTTPClient.new(@server)
    File.open(file_name) do |file|
      body = { 
        'project-file' => file,
        'project-name' => "awesome"
      }
      response = client.post(uri, body)
      url = response.header['Location']
      unless url == []
        project_id = CGI.parse(url[0].split('?')[1])['project'][0]
      end
    end
    raise "Error creating project: #{response}" unless project_id
    project_id
  end

  def apply_operations(file_name)
    raise "You must create a project" unless @project_id
    uri = @server + "/command/core/apply-operations?project=#{@project_id}"
    client = HTTPClient.new(@server)
    File.open(file_name) do |file|
      body = { 
        'operations' => file.read
      }
      @response = client.post(uri, body)
    end
    JSON.parse(@response.content)['code'] rescue false
  end

  def export_rows(format='tsv')
    uri = @server + "/command/core/export-rows/#{@project_name}.#{format}"
    client = HTTPClient.new(@server)
    body = {
      'engine' => '{"facets":[],"mode":"row-based"}',
      'project' => @project_id,
      'format' => format
    }
    @response = client.post(uri, body)
    @response.content
  end

  def delete_project
    uri = @server + "/command/core/delete-project"
    client = HTTPClient.new(@server)
    body = {
      'project' => @project_id
    }
    @response = client.post(uri, body)
    JSON.parse(@response.content)['code'] rescue false
  end
end