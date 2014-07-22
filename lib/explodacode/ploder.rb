require 'sequelizer'

module Explodacode
  class Ploder
    include Sequelizer

    attr :codes, :options
    def initialize(options)
      @options = options
    end

    private

    def source_vocabulary_id
      case options[:vocabulary].downcase.gsub(/\W/, '')
      when 'icd9'
        2
      when 'icd10'
        34
      else
        raise "Unknown vocabulary requested: #{options[:vocabulary]}"
      end
    end
  end
end

