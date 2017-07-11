module TableSchema
  class Schema < Hash
    include TableSchema::Validate
    include TableSchema::Model
    include TableSchema::Helpers

    attr_reader :errors

    def initialize(descriptor, case_insensitive_headers: false)
      self.merge! deep_symbolize_keys(parse_schema(descriptor))
      @errors = Set.new()
      @case_insensitive_headers = case_insensitive_headers
      load_fields!
      load_validator!
      expand!
    end

    def parse_schema(descriptor)
      if descriptor.class == Hash
        descriptor
      elsif descriptor.class == String
        begin
          JSON.parse(open(descriptor).read, symbolize_names: true)
        rescue Errno::ENOENT
          raise SchemaException.new("File not found at `#{descriptor}`")
        rescue OpenURI::HTTPError => e
          raise SchemaException.new("URL `#{descriptor}` returned #{e.message}")
        rescue JSON::ParserError
          raise SchemaException.new("File at `#{descriptor}` is not valid JSON")
        end
      else
        raise SchemaException.new("A schema must be a hash, path or URL")
      end
    end

  end
end
