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

__END__
@@layout
!!! 5
%html
  %head
    %meta(charset="utf-8")
    %title Explod-A-Code!!!!!!
  :css
    body {
      font-family: verdana,helvetica,arial,sans-serif;
    }

    .float {
      float: left;
      margin-right: 10px;
    }
    h1 { margin-bottom: 0px; }
    table, th, td {
      border-collapse: collapse;
      border: solid thin #98bf21;
      margin: 0px;
    }

    thead > tr {
      background-color: #A7C942;
      color: #ffffff;
      font-size: 1.1em;
    }

    th, td {
      padding: 0.25em;
    }

    tr.even {
    }

    tr.odd {
      background-color: #EAF2D3;
    }
  %body
    = yield

@@index
%form#reverse(action="/" method="GET")
  = "Enter Code String"
  %input#word{ type: "text", name: "code_str", value:@code_str.first }
  %br
  = "And select a vocabulary"
  %select#vocabulary{ type: "text", name: "vocabulary" }
    %option{ label: '', value: '' }
    - @vocabularies.each do |vocab|
      %option{ label: vocab, value: vocab }
  %input(type="submit" value="Search")
  - if @codes.empty?
    %p= "Nothing matched #{@search}"
  - else
    %p= @codes.sort.join(", ")
    %ul
    - @codes.each_with_index do |code|
      %li= code

