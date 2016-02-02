%w[sinatra haml csv logger].each{ |gem| require gem }
require_relative "lib/explodacode/exploder"

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

get('/') do
  options = {}
  @vocabularies = %w(ICD-9 CPT ICD-9Proc ICD-10)
  @vocabulary = options[:vocabulary] = params[:vocabulary] || 'ICD-9'
  @code_str = [(params[:code_str] || "")]
  puts "blah"
  if @code_str.first.empty?
    @codes = []
  else
    @codes = Explodacode::Exploder.new(options).blow_up(translate_codes(@code_str, options))
  end
  haml :index
end
