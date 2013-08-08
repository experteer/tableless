require 'spec_helper'

#require 'logger'

describe 'association caching' do
  before :all do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
#    ActiveRecord::Base.logger=Logger.new(STDOUT)
#    ActiveRecord::Base.logger.level=Logger::DEBUG

    ActiveRecord::Migration.create_table :genders do |t|
      t.integer :id
      t.string :name
    end

    class Gender < ActiveRecord::Base
    end

    Gender.create!(:name => 'male')
    Gender.create!(:name => 'female')


  end

  before do
    @klass=Class.new(Tableless::Model) do
      column :name, :string, '', false #name,type,default, nullable
      belongs_to :gender

      column :string_field, :string
      column :integer_field, :integer
      column :boolean_field, :boolean
      column :decimal_field, :decimal
      column :date_field, :date
    end

    def @klass.name
      'Testing'
    end

    def @klass.base_class
      @klass
    end
  end

  after do
    Object.send(:remove_const, :TM1) if defined?(TM1)
    Object.send(:remove_const, :TM2) if defined?(TM2)
  end

  let(:male) { Gender.find_by_name("male") }
  let(:female) { Gender.find_by_name("female") }

  context "with class" do
    it "should have columns" do
      col=@klass.columns[0]
      col.name.should == "name"
      col.type.should == :string
      col.default.should == ''
      col.null.should be_false
    end

    it 'should provide typed attributes' do
      instance = @klass.new(:string_field => 'string',
                            :integer_field => '123',
                            :boolean_field => '0',
                            :decimal_field => '123.45',
                            :date_field => '01-02-2013'
      )
      instance.string_field.should == 'string'
      instance.integer_field.should == 123
      instance.boolean_field.should == false
      instance.decimal_field.should == 123.45
      instance.date_field.should == Date.new(2013,2,1)
    end


    it 'should be serializable' do
      class TM1 < Tableless::Model
        column :name, :string, '', false #name,type,default, nullable
        belongs_to :gender
      end
      instance = TM1.new(:gender => male)
      marshalled = Marshal.dump(instance)
      marshalled.should be_a_kind_of(String)
      instance2 = Marshal.load(marshalled)
      instance2.gender.should == instance.gender
      instance2.attributes.should == instance.attributes
    end

  end
  context "inheritance" do
    before do
      class TM1 < Tableless::Model
        column :text1, :string
      end

      class TM2 < TM1
        column :text2, :string
      end

    end

    it "should inherit the columns" do
      TM2.columns.map(&:name).should include('text1')
    end
    it "should not exherit the columns" do
      TM1.columns.map(&:name).should_not include('text2')
    end

  end

  context "with the belongs_to assoc" do

    it 'should define the gender_id column' do
      p=@klass.new(:gender_id => male.id)
      p.gender_id.should_not be_nil
      p.gender_id.should == male.id
    end

    it 'should set gender_id if gender is set' do
      p=@klass.new(:gender => male)
      p.gender_id.should == male.id
    end

    it "should set gender id gender_id is set" do
      p=@klass.new(:gender_id => male.id)
      p.gender.should == male
    end

    it 'should update the association object' do
      p=@klass.new(:gender_id => male.id)
      p.gender.should == male
      p.gender_id = female.id
      p.gender.should == female
    end

  end
end