require 'active_record'
require 'active_support/core_ext'

require "tableless/version"

module Tableless
  module TablelessAssociationCollection
    #we don't mess around with the db we just fix the target
    def replace(other_array)
      other_array.each { |val| raise_on_type_mismatch(val) }
      @target = other_array.uniq
      nil
    end
  end

  class SchemaColumn < ActiveRecord::ConnectionAdapters::Column

  end

  class Model < ActiveRecord::Base
    class_attribute :columns
    self.columns =[]

    def initialize(params = {})
      super(params)
      self.class.reflections.collect do |assoc_name, reflection|
        if reflection.collection?
          assoc = self.association(assoc_name)
          class << assoc
            include TablelessAssociationCollection
          end
        end
      end
    end

    class << self

      %w(has_many has_and_belongs_to_many).each do |m|
        eval %{
    def #{m}(*args)
      raise "Can't #{m} a Tableless class"
    false
    end
        }
      end

      def column(name, sql_type, default=nil, null=false)
        string_sql_type = sql_type.to_s
        # In Postgres, there is no string data type ...
        string_sql_type = "varchar" if string_sql_type == "string"
        cast_type = ActiveRecord::Base.connection.lookup_cast_type(string_sql_type)
        self.columns += [SchemaColumn.new(name.to_s, default, cast_type, string_sql_type, null)]
      end

      def primary_key
        'id'
      end

      def belongs_to sth, options={}
        integer_cast_type = ActiveRecord::Base.connection.lookup_cast_type("integer")
        #don't use << here!
        self.columns += [SchemaColumn.new("#{sth}_id", nil, integer_cast_type, "integer", false)]
        if options[:polymorphic]
          string_cast_type = ActiveRecord::Base.connection.lookup_cast_type("varchar")
          self.columns += [SchemaColumn.new("#{sth}_type", nil, string_cast_type, "varchar", false)]
        end
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
