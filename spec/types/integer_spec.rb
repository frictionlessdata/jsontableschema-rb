describe TableSchema::Types::Integer do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'integer',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Integer.new(field) }

  it 'casts a simple integer' do
    value = '1'
    expect(type.cast(value)).to eq(1)
  end

  it 'raises when the value is not an integer' do
    value = 'string'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
  end

  it 'casts when value is already cast' do
    value = 1
    expect(type.cast(value)).to eq(1)
  end

end
