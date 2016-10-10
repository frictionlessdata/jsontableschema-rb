require 'spec_helper'

describe JsonTableSchema::Field do

  before(:each) do
    @descriptor_min = {'name' => 'id'}
    @descriptor_max = {
      'name' => 'id',
      'type' => 'integer',
      'format' => 'object',
      'constraints' => {'required' => true}
    }
  end

  it 'returns the descriptor' do
    expect(described_class.new(@descriptor_min)).to eq(@descriptor_min)
  end

  it 'returns a name' do
    expect(described_class.new(@descriptor_min).name).to eq('id')
  end

  it 'returns a type' do
    expect(described_class.new(@descriptor_min).type).to eq('string')
    expect(described_class.new(@descriptor_max).type).to eq('integer')
  end

  it 'returns a format' do
    expect(described_class.new(@descriptor_min).format).to eq('default')
    expect(described_class.new(@descriptor_max).format).to eq('object')
  end

  it 'returns constraints' do
    expect(described_class.new(@descriptor_min).constraints).to eq({})
    expect(described_class.new(@descriptor_max).constraints).to eq({'required' => true})
  end

  it 'returns the correct type class' do
    expect(described_class.new(@descriptor_min).type_class).to eq(JsonTableSchema::Types::String)
    expect(described_class.new(@descriptor_max).type_class).to eq(JsonTableSchema::Types::Integer)
  end

  it 'casts a value' do
    expect(described_class.new(@descriptor_min).cast_value('string')).to eq('string')
  end

end