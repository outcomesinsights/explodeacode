require 'facets/string/index_all'
require_relative 'ploder'

module Explodeacode
  class Exploder < Ploder

    NEGGING_REGEX = /^~/

    def blow_up(*codes)
      @codes = codes.flatten.map(&:to_s).flatten
      results
    end

    def translate_and_blow_up(*codes)
      blow_up(translate(codes))
    end

    private

    def translate(codes)
      puts codes
      codes.flat_map { |c| c.split(/\s*,\s*/) }.flatten.map { |c| c.gsub('x', '?').gsub('y', '%').gsub('-', '..') }
    end

    def include_codes
      codes.reject { |c| c =~ NEGGING_REGEX }
    end

    def exclude_codes
      codes.select { |c| c =~ NEGGING_REGEX }.map { |c| c[1..-1] }
    end

    def inclusion_terms
      include_codes.map { |code| code_to_exprs(code) }.inject { |expr1, expr2| expr1.|(expr2) }
    end

    def exclusion_terms
      exclude_codes.map { |code| code_to_exprs(code) }.inject { |expr1, expr2| expr1.|(expr2) }
    end

    def code_to_exprs(code)
      results = *translate_search_string(code)
      puts "'#{code}' => '#{results}'"
      results.map do |result|
        case result
        when Range
          Sequel.expr do
            source_code >= result.first
          end.&(Sequel.expr do
            source_code <= result.last
          end)
        when Array, String
          Sequel.ilike(:source_code, result)
        else
          raise "No one expects #{result.inspect}!"
        end
      end.inject { |expr1, expr2| expr1.|(expr2) }
    end

    def results
      q = db[:source_to_concept_map]
            .where(source_vocabulary_id: source_vocabulary_id)
            .where(inclusion_terms)
            .exclude(Sequel.like(:source_code, '%.'))
            .order(:source_code)
            .select_group(:source_code)
      q = q.exclude(exclusion_terms) unless exclude_codes.empty?
      puts q.sql
      q.from_self.select_map(:source_code)
    end

    def translate_search_string(str)
      str = str.strip

      # Handle 123-125
      if str =~ /\.\./
        parts = str.split('..')
        return translate_search_string(parts[0]).zip(translate_search_string(parts[1])).map do |a, b|
          if a =~ /_/ && a =~ /\d$/
            # If a user was crazy and entered 123.?/1-123.?/1
            # then the range function will inappropriately increment the trailing digit unless
            # we strip it, range over the first set of digits, then put the trailing digit back
            range_a, a_digit = a.split('_')
            range_b, _ = b.split('_')
            (range_a..range_b).to_a.map{ |item| [item, a_digit].join('_') }.flatten
          else
            a, b = normalize(a, b)
            if a =~ /[%_]/
              (a..b).to_a
            else
              (a..b)
            end
          end
        end.flatten
      end

      return [str] unless str =~ /\?/

      # Handle 123.?/1 or even 123.??/1
      return translate_search_string(str.gsub(/\?+\/\d+/, '_')) + translate_search_string(str.gsub(/\?+\//, '_')) if str =~ /\//

      # Handle 123.? or 123.??
      #str.gsub!(/\?+$/, '%')
      # Handle 123.?1
      str.gsub!(/\?/, '_')
      [wildcard_it(str)]
    end

    def normalize(a, b)
      diff = a.length - b.length
      return wildcard_for_vocab(a, b) if diff.zero?
      if diff < 0
        a += '0' * diff.abs
        copy_wildcards(b, a)
      elsif diff > 0
        b += '9' * diff.abs
        copy_wildcards(a, b)
      end
      return wildcard_for_vocab(a, b)
    end

    def copy_wildcards(from, to)
      ['.', '_', '%'].each do |char|
        from.index_all(char).each do |index|
          to[index] = char
        end
      end
    end

    def wildcard_for_vocab(a, b)
      [wildcard_it(a), wildcard_it(b)]
    end

    def wildcard_it(a)
      a += '%' if a.length < code_length - 1 && a.chars.last != '%'
      return a
    end
  end
end
