# Implement Kernel#instance_exec for Ruby 1.8.6 and below
unless Object.respond_to? :instance_exec
  module Kernel
    # Taken from http://eigenclass.org/hiki/instance_exec
    def instance_exec(*args, &block)
      mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
      Object.class_eval{ define_method(mname, &block) }
      begin
        ret = send(mname, *args)
      ensure
        Object.class_eval{ undef_method(mname) } rescue nil
      end
      ret
    end
  end
end

module BinData
  class Base

    # Don't override initialize.  If you are defining a new kind of datatype
    # (list, array, choice etc) then put your initialization code in
    # #initialize_instance.  This is because BinData objects can be initialized
    # as prototypes and your initialization code may not be called.
    #
    # If you're subclassing BinData::Record, you are definitely doing the wrong
    # thing.  Read the documentation on how to use BinData.
    # http://bindata.rubyforge.org/manual.html#records
    alias_method :initialize_without_warning, :initialize
    def initialize_with_warning(*args)
      owner = method(:initialize).owner
      if owner != BinData::Base
        msg = "Don't override #initialize on #{owner}."
        if %w(BinData::Base BinData::BasePrimitive).include? self.class.superclass.name
          msg += "\nrename #initialize to #initialize_instance."
        end
        fail msg
      end
      initialize_without_warning(*args)
    end
    alias_method :initialize, :initialize_with_warning

    def initialize_instance(*args)
      unless args.empty?
        fail "#{caller[0]} remove the call to super in #initialize_instance"
      end
    end

  end
end
