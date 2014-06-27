require 'thor'
require_relative 'exploder'
module Explodacode
  class CLI < Thor
    class_option :vocabulary, desc: 'The vocabulary for the codes e.g. ICD-9, CPT, SNOMED, etc', default: 'ICD-9'

    desc 'explode code1 [code2]', 'takes a compacted code, e.g. 410.x1 and returns all codes that match'
    def explode(*codes)
      puts Exploder.new(options, translate_codes(codes)).results.join(' ')
    end

    desc 'explode4code code1 [code2]', 'takes a compacted code, e.g. 410.x1 and returns all codes that match, along with comma and ruby array syntax'
    def explode4code(*codes)
      puts "# explodacode explode #{options.inspect} #{codes.join(' ')}"
      puts "%w(#{Exploder.new(options,  translate_codes(codes)).results.join(' ')})"
    end

    private
      def translate_codes(codes)
        codes.map { |c| c.gsub('x', '?').gsub('y', '%') }
      end
  end
end
