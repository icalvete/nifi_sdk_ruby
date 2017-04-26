require 'pp'

require '../lib/nifi_sdk_ruby'

nifi_client = Nifi.new()
nifi_client.set_debug true

# Get the ID of Root Process Group
pg_root = nifi_client.get_process_group
puts "\n"
puts "PG Root's ID"
puts "\n"
puts pg_root['id']
puts "\n"

# Create new Process Group
puts "Create new PG"
puts "\n"
new_pg = nifi_client.create_process_group(:name => 'test')
puts "\n"
puts new_pg
puts "\n"

# Get all attrs of the Process Group by ID (PG Root's child)
puts 'PG ' + new_pg['id'] + ' attrs.'
puts "\n"
puts nifi_client.get_process_group(:id => new_pg['id'])
puts "\n"

# Get a Process Group ID
puts "PG ID"
puts "\n"
pg = nifi_client.get_process_group(:id => new_pg['id'])
puts pg['id']
puts "\n"

# Delete some Process Group
puts 'Delete PG with id ' + new_pg['id']
puts "\n"
puts nifi_client.delete_process_group new_pg['id']
puts "\n"

# Upload a template to Root Process Group 
puts 'Upload template to Root PG'
puts nifi_client.upload_template(:path => 'IN.hmStaff.taskStatus.xml')
