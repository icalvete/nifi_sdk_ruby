version = File.join(File.dirname(__FILE__), '/nifi_sdk_ruby/version')
require version

require 'pp' if ENV['DEBUG']
require 'httparty'
require 'curb'
require 'json'

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

    process_group = args[:pg_id] ? args[:pg_id] : 'root'

    base_url = @@base_url + "/process-groups/#{process_group}"
    res = self.class.http_client(base_url)

    if args[:attr]
      return res[args[:attr]]
    end

    return res
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
      JSON.parse(c.body_str)
    else
      puts c.body_str
    end
  end
end
