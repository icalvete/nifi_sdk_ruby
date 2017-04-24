# How relase a version to rubygems

## adding credentials (only first time)

curl -u icalvete https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials

## release version

edit lib/nifi_sdk_ruby/version.rb and change the version.
git add, commit, push
gem build nifi_sdk_ruby.gemspec
mv nifi_sdk_ruby-$VERSION.gem pkg
gem push pkg/fluzo_sdk_ruby-$VERSION.gem

## delete wrong version from rubygems

gem yank nifi_sdk_ruby -v $VERSION
