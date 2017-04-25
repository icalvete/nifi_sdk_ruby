# NifiSdkRuby

A RUBY SDK to use [APACHE NIFI](https://nifi.apache.org/) API.

See more at [APACHE NIFI API](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html).

https://rubygems.org/gems/nifi_sdk_ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nifi_sdk_ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nifi_sdk_ruby

## Usage

### Instanciate the client

```ruby
require 'nifi_sdk_ruby'

nifi_client = Nifi.new()
nifi_client.set_debug(true)

```

### Get root id

```ruby
# Get Root Process Group
pg_root = nifi_client.get_process_group()
puts "PG Root's ID"
puts pg_root['id']
```

### Create new PG

```ruby
new_pg = nifi_client.create_process_group(:name => 'test')
puts new_pg
```

### Get all attrs of the Process Group with ID 9c3ebb60-015b-1000-1027-b27d47832152 (PG Root's child)

```ruby
puts  nifi_client.get_process_group(:id => new_pg['id'])
```

### Delete some PG

```ruby
puts nifi_client.delete_process_group(new_pg['id'])
```

# Upload a template to Root PG

```ruby
puts nifi_client.upload_template(:path => 'IN.hmStaff.taskStatus.xml')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/icalvete/nifi_sdk_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Authors:

Israel Calvete Talavera <icalvete@gmail.com>
