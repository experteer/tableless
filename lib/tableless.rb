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

      def load_schema!
        columns_hash.each do |name, column|
          self.define_attribute(
            name,
            column.sql_type_metadata,
            default: column.default,
            user_provided_default: false
          )
        end
      end

      def columns_hash
        @columns_hash ||= Hash[columns.map { |column| [column.name, column] }]
      end

      def column(name, sql_type, default=nil, null=false)
        type = "ActiveRecord::Type::#{sql_type.to_s.camelize}".constantize.new
        self.columns += [ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, type, null, '')]
      end

      def primary_key
        'id'
      end

      def belongs_to sth, options={}
        self.columns += [ActiveRecord::ConnectionAdapters::Column.new("#{sth}_id", nil, ActiveRecord::Type::Integer.new, false, '')]
        if options[:polymorphic]
          self.columns += [ActiveRecord::ConnectionAdapters::Column.new("#{sth}_type", nil, ActiveRecord::Type::String.new, false, '')]
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
  end
end
