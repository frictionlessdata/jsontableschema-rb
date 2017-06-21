module TableSchema
  module Types
    class Array < Base

      def name
        'array'
      end

      def self.supported_constraints
        [
          'required',
          'pattern',
          'enum',
          'minLength',
          'maxLength',
        ]
      end

      def type
        ::Array
      end

      def cast_default(value)
        return value if value.is_a?(type)
        parsed = JSON.parse(value)
        if parsed.is_a?(type)
          return parsed
        else
          raise TableSchema::InvalidArrayType.new("#{value} is not a valid array")
        end
      rescue
        raise TableSchema::InvalidArrayType.new("#{value} is not a valid array")
      end

    end
  end
end
