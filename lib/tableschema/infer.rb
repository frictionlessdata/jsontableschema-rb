require 'tableschema/defaults'
require 'tableschema/field'

module TableSchema
  class Infer

    include TableSchema::Helpers

    attr_reader :schema

    def initialize(headers, rows, explicit: false, primary_key: nil, row_limit: nil)
      @headers = headers
      @rows = rows
      @explicit = explicit
      @primary_key = primary_key
      @row_limit = row_limit

      @schema = {
        fields: fields
      }
      @schema[:primaryKey] = @primary_key if @primary_key
      infer!
    end

    def fields
      @headers.map do |header|
        descriptor = {
          name: header,
          title: '',
          description: '',
        }

        constraints = {}
        constraints[:required] = @explicit === true
        constraints[:unique] = (header == @primary_key)
        constraints.delete_if { |_,v| v == false } unless @explicit === true
        descriptor[:constraints] = constraints if constraints.count > 0
        TableSchema::Field.new(descriptor)
      end
    end

    def infer!
      type_matches = []
      @rows.each_with_index do |row, index|
        break if @row_limit && index > @row_limit
        row = row.fields if row.class == CSV::Row

        row_length = row.count
        headers_length = @headers.count

        if row_length > headers_length
          row = row[0..headers_length]
        elsif row_length < headers_length
          diff = headers_length - row_length
          fill = [''] * diff
          row = row.push(fill).flatten
        end

        row.each_with_index do |col, idx|
          type_matches[idx] ||= []
          type_matches[idx] << guess_type(col, idx)
        end

      end
      resolve_types(type_matches)
      @schema = TableSchema::Schema.new(@schema)
    end

    def guess_type(col, index)
      guessed_type = TableSchema::DEFAULTS[:type]
      guessed_format = TableSchema::DEFAULTS[:format]

      available_types.reverse_each do |type|
        klass = get_class_for_type(type)
        converter = Kernel.const_get(klass).new(@schema[:fields][index])
        if converter.test(col) === true
          guessed_type = type
          guessed_format = guess_format(converter, col)
          break
        end
      end

      {
        type: guessed_type,
        format: guessed_format
      }
    end

    def guess_format(converter, col)
      guessed_format = TableSchema::DEFAULTS[:format]
      converter.class.instance_methods.grep(/cast_/).each do |method|
        begin
          format = method.to_s
          format.slice!('cast_')
          next if format == TableSchema::DEFAULTS[:format]
          converter.send(method, col)
          guessed_format = format
          break
        rescue TableSchema::Exception
          next
        end
      end
      guessed_format
    end

    def resolve_types(results)
      results.each_with_index do |result,v|
        result.uniq!

        if result.count == 1
          rv = result[0]
        else
          counts = {}
          result.each do |r|
            counts[r] ||= 0
            counts[r] += 1
          end

          sorted_counts = counts.sort_by {|_key, value| value}
          rv = sorted_counts[0][0]
        end

        @schema[:fields][v].merge!(rv)
      end

    end

    def available_types
      [
        'any',
        'string',
        'boolean',
        'number',
        'integer',
        'date',
        'time',
        'datetime',
        'array',
        'object',
        'geopoint',
        'geojson'
      ]
    end

  end
end
