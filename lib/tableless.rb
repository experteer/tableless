require 'active_record'
require 'active_support/core_ext'

require "tableless/version"

module Tableless
  class SchemaColumn < ActiveRecord::ConnectionAdapters::Column

  end

  class Model < ActiveRecord::Base
    class_attribute :columns
    self.columns =[]
    #include ActiveRecord::AttributeMethods
    #
    #include ActiveModel::Validations
    #include ActiveModel::Conversion
    #include ActiveModel::AttributeMethods
    #
    #extend ActiveModel::Naming
    #
    #
    #
    #cattr_accessor :columns
    #self.columns = []
    #
    #
    #def initialize(attributes = {})
    #  debugger
    #  attributes.each do |name, value|
    #    send("#{name}=", value)
    #  end
    #end
    #
    #def persisted?
    #  false
    #end
    #
    class << self

      %w(has_many has_and_belongs_to_many).each do |m|
        eval %{
    def #{m}(*args)
      raise "Can't #{m} a Tableless class"
    false
    end
        }
      end

      def column(name, type, default=nil, null=false)
        self.columns += [SchemaColumn.new(name.to_s, default, type.to_s, null)]
      end

      def primary_key
        'id'
      end

      def belongs_to sth, options={}
        #don't use << here!
        self.columns += [SchemaColumn.new("#{sth}_id", 'integer', nil, false)]
        super
      end
    end #of class methods

    def persisted?
      false
    end

    def new_record?
      true
    end

    %w(find create destroy).each do |m|
      eval %{
    def #{m}(*args)
      raise "Can't #{m} a Tableless object"
    false
    end
        }
    end


    #
    #def self.column_names
    #  columns.map(&:name)
    #end
    #
    #def self.base_class
    #  ActiveRecord::Base
    #end
    #def self.abstract_class
    #  true
    #end
  end
end
