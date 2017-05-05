version = File.join(File.dirname(__FILE__), '/nifi_sdk_ruby/version')
require version

require 'pp' if ENV['DEBUG']
require 'httparty'
require 'curb'
require 'json'
require 'securerandom'
require 'active_support/all'
require 'open-uri'
require 'nokogiri'

class Nifi

  DEFAULT_HOST   = 'localhost'
  DEFAULT_SCHEMA = 'http'
  DEFAULT_PORT   = '8080'
  DEFAULT_DEBUG  = false
  DEFAULT_ACYNC  = false

  @@auth
  @@schema
  @@host
  @@port
  @@base_url
  @@debug
  @@async
  @@sdk_name
  @@sdk_version
  @@client_id

  def initialize(*args)

    args = args.reduce Hash.new, :merge

    @@schema      = args[:schema] ? args[:schema] : DEFAULT_SCHEMA
    @@host        = args[:host] ? args[:host] : DEFAULT_HOST
    @@port        = args[:port] ? args[:port] : DEFAULT_PORT
    @@base_url    = @@schema + '://' + @@host + ':' + @@port + '/nifi-api'
    @@debug       = DEFAULT_DEBUG
    @@async       = DEFAULT_ACYNC
    @@sdk_name    = 'ruby'
    @@sdk_version = NifiSdkRuby::VERSION
    @@client_id   = SecureRandom.uuid
  end

  def set_debug(debug = nil)
    if debug.nil?
      raise ArgumentError.new('missing debug')
    end

    if !(!!debug == debug)
      raise TypeError.new('debug must be a boolean')
    end

    @@debug = debug
  end

  def get_debug
    @@debug
  end

  def set_async(async = nil)
    if async.nil?
      raise ArgumentError.new('missing async')
    end

    if !(!!async == async)
      raise TypeError.new('async must be a boolean')
    end

    @@async = async
  end

  def get_async
    @@async
  end

  def get_api_key
    @@api_key
  end

  def get_schema
    @@schema
  end

  def get_host
    @@host
  end

  def get_base_url
    @@base_url
  end

  def get_process_group(id = nil)

    process_group = id ? id : 'root'

    base_url = @@base_url + '/process-groups/' << process_group
    self.class.http_client(base_url)
  end

  def create_process_group(*args)
    args = args.reduce Hash.new, :merge

    if args[:name].nil?
      raise ArgumentError.new('name params is mandatory.')
    end
    name = args[:name].to_s
    if self.process_group_by_name? name
      raise ArgumentError.new('The process group ' << name << ' already exists')
    end

    params = '{"revision":{"clientId":"' << @@client_id << '","version":0},"component":{"name":"' << name <<
        '","position":{"x":274.54776144527517,"y":-28.886681059739686}}}'

    process_group = args[:id] ? args[:id] : 'root'
    base_url = @@base_url + '/process-groups/' << process_group << '/process-groups'
    self.class.http_client(base_url, 'POSTRAW', params)
  end

  def delete_process_group(id = nil)

    if id.nil?
      raise ArgumentError.new('id is mandatory.')
    end

    base_url = @@base_url + '/process-groups/' << id << '?clientId=' << @@client_id << '&version=1'
    self.class.http_client(base_url, 'DELETE')
  end

  def get_process_group_by_name(name = nil)

    if name.nil?
      raise ArgumentError.new('name is mandatory.')
    end

    res = self.class.exists

    pg = res.select do |r|
      r['name'] == name and r['identifier'] =~ /process-groups/
    end

    if pg.count == 1
      self.class.get pg[0]['identifier']
    else
      raise ArgumentError.new('Unable to locate group with name ' << name)
    end
  end

  def get_process(id = nil)
    if id.nil?
      raise ArgumentError.new('id is mandatory.')
    end

    url = @@base_url + '/processors/' << id
    self.class.http_client(url)
  end

  def start_process(*args)
    args = args.reduce Hash.new, :merge
    if args[:id].nil? or args[:version].nil?
      raise ArgumentError.new('id and version params are mandatory')
    end

    id = args[:id].to_s
    version = args[:version].to_s

    params = '{"revision":{"version":' << version << '},"id":"' << id << '","component":{"id":"' << id <<
        '","state":"RUNNING"},"status":{"runStatus":"Running"}}'
    base_url = @@base_url + '/processors/' << id
    self.class.http_client(base_url, 'PUT', params)
  end

  def stop_process(*args)
    args = args.reduce Hash.new, :merge
    if args[:id].nil? or args[:version].nil?
      raise ArgumentError.new('id and version params are mandatory')
    end

    id = args[:id].to_s
    version = args[:version].to_s

    params = '{"revision":{"version":' << version << '},"id":"' << id << '","component":{"id":"' << id <<
        '","state":"STOPPED"},"status":{"runStatus": "Stopped"}}'
    base_url = @@base_url + '/processors/' << id
    self.class.http_client(base_url, 'PUT', params)
  end

  def update_process(*args)
    args = args.reduce Hash.new, :merge
    if args[:id].nil? or args[:update_json].nil?
      raise ArgumentError.new('id and update_json params are mandatory')
    end

    id = args[:id].to_s
    params =

    base_url = @@base_url + '/processors/' << id
    self.class.http_client(base_url, 'PUT', params)
  end

  def process_group_by_name?(name = nil)

    if name.nil?
      raise ArgumentError.new('name is mandatory.')
    end

    res = self.class.exists

    pg = res.select do |r|
      r['name'] == name and r['identifier'] =~ /process-groups/
    end

    pg.count == 1 ? true : false
  end

  def create_template_instance(*args)
    args = args.reduce Hash.new, :merge

    if args[:id].nil? and args[:name].nil?
      raise ArgumentError.new('either specify id of the template or it\'s name ')
    end

    if args[:name]
      raise StandardError.new('Could not find template called ' << args[:name]) unless template_by_name?(args[:name])
      id = get_template_by_name(args[:name])[0][0]
    else
      raise StandardError.new('Could not find template with id ' << args[:id]) unless template_by_id?(args[:id])
      id = args[:id]
    end

    originX = args[:originX] ? args[:originX].to_s : '0.0'
    originY = args[:originY] ? args[:originY].to_s : '0.0'
    process_group = args[:process_group_id] ? args[:process_group_id] : 'root'
    params = '{"templateId": "' << id << '", "originX": ' << originX << ', "originY": ' << originY << '}'
    base_url = @@base_url + '/process-groups/' << process_group << '/template-instance'
    self.class.http_client(base_url, 'POSTRAW', params)
  end

  def upload_template(*args)

    args = args.reduce Hash.new, :merge

    if args[:path].nil?
      raise ArgumentError.new('path params is mandatory.')
    end
    path = args[:path]

    if path =~ URI::regexp

      download_s = open(path)
      download_t = '/tmp/' << download_s.base_uri.to_s.split('/')[-1]
      IO.copy_stream(download_s, download_t)
      path = download_t
    end

    if not File.file? path or not File.readable? path
      raise IOError.new('Access to ' <<path << ' failed')
    end

    t = File.open(path) { |f| Nokogiri::XML(f) }
    name = t.xpath('//template/name').text

    if self.template_by_name? name
      raise StandardError.new('The template ' << name << ' already exists')
    end

    params = Array.new
    params << Curl::PostField.file('template', path)

    process_group = args[:id] ? args[:id] : 'root'

    base_url = @@base_url + '/process-groups/' << process_group << '/templates/upload'
    res = self.class.http_client(base_url, 'POST', params)

    return res['templateEntity']['template']
  end

  def delete_template(id = nil)

    if id.nil?
      raise ArgumentError.new('id is mandatory.')
    end

    base_url = @@base_url + '/templates/' << id
    self.class.http_client(base_url, 'DELETE')
  end

  def get_template_by_name(name = nil)

    if name.nil?
      raise ArgumentError.new('name is mandatory.')
    end

    res = self.class.exists

    t = res.select do |r|
      r['name'] == name and r['identifier'] =~ /templates/
    end


    if t.count == 1
      t[0]['identifier'].scan(/\/templates\/(.*)/)
    else
      raise StandardError.new('Unable to locate template with name ' << name)
    end

  end

  def template_by_name?(name = nil)

    if name.nil?
      raise ArgumentError.new('name is mandatory.')
    end

    res = self.class.exists

    pg = res.select do |r|
      r['name'] == name and r['identifier'] =~ /templates/
    end

    pg.count == 1 ? true : false
  end

  def template_by_id?(id = nil)

    if id.nil?
      raise ArgumentError.new('id is mandatory.')
    end

    res = self.class.exists

    pg = res.select do |r|
      r['identifier'] == '/templates/' << id
    end

    pg.count == 1 ? true : false
  end

  private

  def self.exists
    base_url = @@base_url + '/resources'
    res = self.http_client(base_url)
    puts base_url
    return res['resources']
  end

  def self.get(resource)
    base_url = @@base_url + resource
    self.http_client(base_url)
  end

  def self.http_client(url, method = 'GET', params = nil, filename = nil)
    c = Curl::Easy.new
    #c.http_auth_types              = :basic
    #c.username                     = @@api_key
    #c.password                     = ''
    c.url                         = url
    c.useragent                   = @@sdk_name + '_' + @@sdk_version
    c.headers['NIFI-SDK-Name']    = @@sdk_name
    c.headers['NIFI-SDK-Version'] = @@sdk_version
    c.ssl_verify_peer             = false
    #c.verbose                     = true

    case method
      when 'GET'
        c.get
      when 'POSTRAW'
        c.headers['Content-Type'] = 'application/json'
        c.post(params)
      when 'POST'
        c.multipart_form_post = true
        c.post(params)
      when 'PUT'
        c.headers['Content-Type'] = 'application/json'
        c.put(params)
      when 'DELETE'
        c.delete
      else
        raise ArgumentError.new('HTTP method ' << method << ' not supported.')
    end

    if c.response_code.to_s.match(/20./) and not c.body_str.empty?
      begin
        JSON.parse(c.body_str)
      rescue
        if c.content_type == 'application/xml'
          JSON.parse(Hash.from_xml(c.body_str).to_json)
        end
      end
    else
      puts c.body_str
    end
  end
end