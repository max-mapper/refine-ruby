require 'httpclient'
require 'cgi'
require 'json'

class Refine
  def self.get_all_project_metadata(server="http://127.0.0.1:3333")
    uri = "#{server}/command/core/get-all-project-metadata"
    response = HTTPClient.new(server).get(uri)
    JSON.parse(response.body)
  end

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
        'project-name' => project_name
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

  def apply_operations(file_name_or_string)
    raise "You must create a project" unless @project_id

    if File.exists?(file_name_or_string)
      operations = File.read(file_name_or_string)
    else
      operations = file_name_or_string
    end

    body = { 'operations' => file_name_or_string }
    uri = @server + "/command/core/apply-operations?project=#{@project_id}"
    client = HTTPClient.new(@server)

    @response = client.post(uri, body)

    JSON.parse(@response.content)['code'] rescue false
  end

  def export_rows(opts={})
    format = opts["format"] || 'tsv'
    uri = @server + "/command/core/export-rows/#{@project_name}.#{format}"
    client = HTTPClient.new(@server)

    body = {
      'engine' => {
        "facets" => opts["facets"] || [],
        "mode" => "row-based"
      }.to_json,
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

  # this pattern is pulled from mailchimp/mailchimp-gem

  def call(method, params = {})
    uri = "#{@server}/command/core/#{method}"
    params = { "project" => @project_id }.merge(params)
    client = HTTPClient.new(@server)

    response = if method.start_with?('get-')
      client.get(uri, params)
    else
      client.post(uri, params)
    end

    begin
      response = JSON.parse(response.body)
    rescue
      response = JSON.parse('[' + response.body + ']').first
    end

    # if @throws_exceptions && response.is_a?(Hash) && response["error"]
    #   raise Mailchimp::APIError.new(response['error'],response['code'])
    # end

    response
  end

  def method_missing(method, *args)
    # translate: get_column_info --> get-column-info
    call(method.to_s.gsub('_', '-'), *args)
  end

end