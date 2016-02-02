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
  %p Examples (click to view results):
  %dl
    %dt
      %a{href: "http://explodacode.jigsawanalytics.com/?code_str=412&vocabulary=ICD-9" } 412
    %dd Search by three digit code only
    %dt
      %a{href: "http://explodacode.jigsawanalytics.com/?code_str=410.x&vocabulary=ICD-9" } 410.x
    %dd Search for all four-digit codes starting with 410
    %dt
      %a{href: "http://explodacode.jigsawanalytics.com/?code_str=410.xx&vocabulary=ICD-9" } 410.xx
    %dd Search for all five-digit codes starting with 410
    %dt
      %a{href: "http://explodacode.jigsawanalytics.com/?code_str=410.y&vocabulary=ICD-9" } 410.y
    %dd Search for all four-digit or five-digit codes starting with 410
    %dt
      %a{href: "http://explodacode.jigsawanalytics.com/?code_str=412%2C+410.x1&vocabulary=ICD-9" } 412, 410.x1
    %dd Search more than one code at a time: three-digit code 412 and any five-digit code starting with 410 and ending in 1
    %dt
      %a{href: "http://explodacode.jigsawanalytics.com/?code_str=410-412&vocabulary=ICD-9" } 410-412
    %dd Search for all codes between 410 through 412
  %br
  = "Enter Code String"
  %input#word{ type: "text", name: "code_str", value:@code_str.first }
  %br
  = "Select a vocabulary"
  %select#vocabulary{ type: "text", name: "vocabulary" }
    %option{ label: '', value: '' }
    - @vocabularies.each do |vocab|
      %option{ label: vocab, value: vocab, selected: vocab == @vocabulary }
  %br
  = "And click "
  %input(type="submit" value="Search")
  %br
  - if @codes.empty?
    %p= "Nothing matched #{@search}"
  - else
    %p
      Codes in comma-delimited list (great for
      %a{ href: "https://github.com/outcomesinsights/conceptql" } ConceptQL
      codelists)
    %p= @codes.sort.join(", ")
    %br
    %p Codes in a list
    %ul
    - @codes.each_with_index do |code|
      %li= code

