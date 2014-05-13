require 'chefspec'
require 'chefspec/berkshelf'

def put_ark(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:ark, :put, resource_name)
end

at_exit { ChefSpec::Coverage.report! }
