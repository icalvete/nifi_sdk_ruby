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
nifi_client.set_debug true

```

### Get Root's Process Group id

```ruby
# Get Root Process Group
pg_root = nifi_client.get_process_group
puts "PG Root's ID"
puts pg_root['id']
```

### Create new Process Group

```ruby
new_pg = nifi_client.create_process_group(:name => 'test')
puts new_pg
```

### Check if Process Group exists

```ruby
puts nifi_client.process_group_by_name? test
```

### Get all attrs a the Process Group by ID (PG Root's child)

```ruby
puts  nifi_client.get_process_group(new_pg['id'])
```

### Get all attrs a the Process Group by Name (Root's childs)

```ruby
puts nifi_client.get_process_group_by_name 'test'
```

### Delete some Process Group

```ruby
puts nifi_client.delete_process_group(new_pg['id'])
```

### Upload a template to Root Process Group

From file ...

```ruby
puts nifi_client.upload_template(:path => 'IN.hmStaff.taskStatus.xml')
```

From url ...

```ruby
puts nifi_client.upload_template(:path => 'https://your.domain.net/IN.hmStaff.taskStatus.xml')
```

### Check if Process Group exists

```ruby
puts nifi_client.template_by_name? test
```


### Get all attrs of a template by Name (Root's childs)

```ruby
t = nifi_client.get_template_group_by_name 'test'
puts t
```

### Delete template
```ruby
puts nifi_client.delete_template t['id']
```

### Create template instance
By id 
```ruby
puts nifi_client.create_template_instance(:id => '43fwe1s-asd2-sdf3-sfq3ev')
```
Or by name
```ruby
puts nifi_client.create_template_instance(:name => 'TemplateName')
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/icalvete/nifi_sdk_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Authors:

Israel Calvete Talavera <icalvete@gmail.com>
