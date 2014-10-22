actions :add, :remove

attribute :param_key, :kind_of => String, :name_attribute => true
attribute :command, :kind_of => String, :required => true
attribute :keyname, :kind_of => String

def initialize(*args)
  super
  @action = :add
end
