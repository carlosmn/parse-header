#!/usr/bin/env ruby

require './parser'
require 'pp'

file = open('test.h')
contents = file.read()
parser = Parser.new
# Get rid of preprocessor directives
contents.gsub! /(^#.*)/, ''
# And transform GIT_EXTERN(type) -> type
contents.gsub! /GIT_EXTERN\((.*)\)/, '\1'
contents.gsub! /GIT_BEGIN_DECL/, ''
contents.gsub! /GIT_END_DECL/, ''
#contents.strip!
#p contents
begin
  parsed = parser.parse contents
rescue Parslet::ParseFailed => error
  puts error, parser.root.error_tree
end
pp parsed
line, col = parsed[3][:doc_comment].line_and_column
puts "line and stuff #{line},#{col}"
