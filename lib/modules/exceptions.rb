module Exceptions

  module File
    class CSVImportError < StandardError; end
    class FileNotProvided < CSVImportError; end
    class InvalidCSVFormat < CSVImportError; end
    class InvalidFileType < CSVImportError; end
    class DuplicateEntityInCsv < CSVImportError
      attr_accessor :ids
      def initialize(ids)
        @ids = ids
      end
    end
    class ErrorsInCsv < CSVImportError
      attr_accessor :data
      def initialize(data)
        @data = data
      end
    end
  end
end

