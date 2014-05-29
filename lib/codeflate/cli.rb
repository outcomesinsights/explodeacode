require 'thor'
require_relative 'exploder'
module Codeflate
  class CLI < Thor
    class_option :vocabulary, desc: 'The vocabulary for the codes e.g. ICD-9, CPT, SNOMED, etc', default: 'ICD-9'

    desc 'explode code1 [code2]', 'takes a compacted code, e.g. 410.x1 and returns all codes that match'
    def explode(*codes)
      puts Exploder.new(options, codes).results.join(' ')
    end

    desc 'explode4code code1 [code2]', 'takes a compacted code, e.g. 410.x1 and returns all codes that match, along with comma and ruby array syntax'
    def explode4code(*codes)
      puts "# codeflate explode #{options.inspect} #{codes.join(' ')}"
      puts "%w(#{Exploder.new(options, codes).results.join(' ')})"
    end
  end
end
