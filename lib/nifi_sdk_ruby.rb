version = File.join(File.dirname(__FILE__), '/nifi_sdk_ruby/version')
require version

require 'pp' if ENV['DEBUG']
require 'httparty'
require 'curb'
require 'json'
require 'securerandom'
require 'active_support/all'

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
      abort 'missing debug'
    end

    if !(!!debug == debug)
      abort 'debug msut be a boolean'
    end

    @@debug = debug
  end

  def get_debug()
    @@debug
  end

  def set_async(async = nil)
    if async.nil?
      abort 'missing async'
    end

    if !(!!async == async)
      abort 'async msut be a boolean'
    end

    @@async = async
  end

  def get_async()
    @@async
  end

  def get_api_key()
    @@api_key
  end

  def get_schema()
    @@schema
  end

  def get_host()
   	@@host
  end

  def get_base_url()
   	@@base_url
  end

  def get_process_group(*args)

    args = args.reduce Hash.new, :merge

    process_group = args[:id] ? args[:id] : 'root'

    base_url = @@base_url + "/process-groups/#{process_group}"
    self.class.http_client(base_url)
  end

  def create_process_group(*args)
    args = args.reduce Hash.new, :merge

    if args[:name].nil?
      abort 'name params is mandatory.'
    end

    params = '{"revision":{"clientId":"' + @@client_id + '","version":0},"component":{"name":"' + args[:name] + '","position":{"x":274.54776144527517,"y":-28.886681059739686}}}'

    process_group = args[:id] ? args[:id] : 'root'
    base_url = @@base_url + "/process-groups/#{process_group}/process-groups"
    self.class.http_client(base_url, 'POSTRAW', params)
  end

  def delete_process_group(id = nil)

    if id.nil?
      abort 'id is mandatory.'
    end

    base_url = @@base_url + '/process-groups/' + id + '?clientId=' + @@client_id + '&version=1'
    self.class.http_client(base_url, 'DELETE')
  end

  def upload_template(*args)

    args = args.reduce Hash.new, :merge
    
    if args[:path].nil?
      abort 'path params is mandatory.'
    end
    path = args[:path]

    if not File.file? path or not File.readable? path
      abort "Access to #{path} failed"
    end
    params = Array.new
    params << Curl::PostField.file('template', path)

    process_group = args[:id] ? args[:id] : 'root'

    base_url = @@base_url + "/process-groups/#{process_group}/templates/upload"
    res = self.class.http_client(base_url, 'POST', params)

    return res['templateEntity']['template']
  end

  private

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
        c.put(params)
      when 'DELETE'
        c.delete
      else
        abort 'HTTP method not supported.'
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
