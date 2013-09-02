require 'active_record'
require 'active_support/core_ext'

require "tableless/version"

module Tableless
  module TablelessAssociationCollection
    #we don't mess around with the db we just fix the target
    def replace(other_array)
      other_array.each { |val| raise_on_type_mismatch(val) }

      load_target
      #optimize for speed
      other = other_array.size < 100 ? other_array : other_array.to_set
      current = @target.size < 100 ? @target : @target.to_set

      @target.delete_if { |v| !other.include?(v) }
      @target.concat other_array.select { |v| !current.include?(v) }
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
          assoc = self.send(assoc_name)
          class << assoc
            include TablelessAssociationCollection
          end
        end
      end
    end

    class << self

      %w(has_many).each do |m|
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
        self.columns += [SchemaColumn.new("#{sth}_id", nil, 'integer', false)]
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
