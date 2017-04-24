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


```ruby
require 'nifi_sdk_ruby'

nifi_client = Nifi.new()
nifi_client.set_debug(true)

# Get the ID of Root Process Group
pg_root_id = nifi_client.get_process_group(:attr => 'id')
puts "\n"
puts "PG Root's ID"
puts "\n"
puts pg_root_id
puts "\n"

# Get all attrs of the Process Group with ID 9c3ebb60-015b-1000-1027-b27d47832152 (PG Root's child)
some_pg = nifi_client.get_process_group(:pg_id => '9c3ebb60-015b-1000-1027-b27d47832152')
puts "PG 9c3ebb60-015b-1000-1027-b27d47832152`s attrs"
puts "\n"
puts some_pg
puts "\n"

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/icalvete/nifi_sdk_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Authors:

Israel Calvete Talavera <icalvete@gmail.com>
