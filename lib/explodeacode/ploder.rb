require 'sequelizer'

module Explodeacode
  class Ploder
    include Sequelizer

    attr :codes, :options, :db
    def initialize(options, *codes)
      @options = options
      @db = options[:db] || new_db
    end

    private

    def source_vocabulary_id
      case vocab
      when 'cpt', 'hcpcs'
        [4, 5]
      when 'icd9proc'
        3
      when 'icd9', 'icd9dx'
        2
      when 'icd10'
        34
      when 'ndc'
        9
      else
        raise "Unknown vocabulary requested: #{options[:vocabulary]}"
      end
    end

    def code_length
      case vocab
      when 'cpt', 'hcpcs'
        5
      when 'icd9proc'
        5
      when 'icd9', 'icd9dx'
        6
      when 'icd10'
        9
      when 'ndc'
        11
      else
        raise "Unknown vocabulary requested: #{options[:vocabulary]}"
      end
    end

    def vocab
      options[:vocabulary].downcase.gsub(/\W/, '')
    end
  end
end

