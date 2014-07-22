require_relative 'ploder'

module Explodacode
  class Exploder < Ploder

    NEGGING_REGEX = /^~/

    def blow_up(*codes)
      @codes = codes.flatten.map(&:to_s).flatten
      results
    end

    private

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
      Sequel.ilike(:source_code, *translate_search_string(code))
    end

    def results
      q = db[:source_to_concept_map]
            .where(source_vocabulary_id: source_vocabulary_id)
            .where(inclusion_terms)
            .exclude(Sequel.like(:source_code, '%.'))
            .order(:source_code)
            .select_group(:source_code)
      q = q.exclude(exclusion_terms) unless exclude_codes.empty?
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
            (a..b).to_a
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
      [str]
    end
  end
end
