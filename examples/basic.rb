require 'pp'

require '../lib/nifi_sdk_ruby'

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
