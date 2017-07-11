module TableSchema
  module Types
    class Object < Base

      def name
        'object'
      end

      def self.supported_constraints
        [
          'required',
          'unique',
          'pattern',
          'enum',
          'minLength',
          'maxLength',
        ]
      end

      def type
        ::Hash
      end

      def cast_default(value)
        return value if value.is_a?(type)
        parsed = JSON.parse(value, symbolize_names: true)
        if parsed.is_a?(Hash)
          return parsed
        else
          raise TableSchema::InvalidObjectType.new("#{value} is not a valid object")
        end
      rescue
        raise TableSchema::InvalidObjectType.new("#{value} is not a valid object")
      end

    end
  end
end
