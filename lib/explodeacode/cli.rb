require 'thor'
require_relative 'exploder'
module Explodeacode
  class CLI < Thor
    class_option :vocabulary, desc: 'The vocabulary for the codes e.g. ICD-9, CPT, SNOMED, etc', default: 'ICD-9'
    class_option :broad, type: :boolean, desc: 'Gather as many as possible', default: false

    desc 'explode code1 [code2]', 'takes a compacted code, e.g. 410.x1 and returns all codes that match'
    def explode(*codes)
      puts Exploder.new(options).blow_up(translate_codes(codes, options)).join(' ')
    end

    desc 'explode4code code1 [code2]', 'takes a compacted code, e.g. 410.x1 and returns all codes that match, along with comma and ruby array syntax'
    def explode4code(*codes)
      puts "# explodeacode explode #{options.inspect} #{codes.join(' ')}"
      puts "%w(#{Exploder.new(options).blow_up(translate_codes(codes, options)).join(' ')})"
    end

    private
      def translate_codes(codes, options = {})
        codes = codes.map { |c| c.split(/\s*,\s*/) }.flatten.map { |c| c.gsub('x', '?').gsub('y', '%').gsub('-', '..') }
        if options['broad']
          codes = codes.map do |c|
            broaden(c)
          end
        end
        codes
      end

      def broaden(c)
        case c.length
        when (0..5)
          c + '%'
        when (8..99)
          c.split('..').map { |a| broaden(a) }.join('..')
        else
          c
        end
      end
  end
end
