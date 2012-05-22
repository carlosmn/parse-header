require 'parslet'

class Parser < Parslet::Parser
  rule(:new_line) { match('[\\n\\r]').repeat(1) }
  rule(:space) { match('\s') }
  rule(:spaces) { space.repeat(1) }
  rule(:space?) { space.maybe }
  rule(:spaces?) { space.repeat }

  rule(:digit) { match('[0-9]') }
  rule(:digits) { digit.repeat(1) }
  rule(:digits?) { digit.repeat }

  rule(:alpha) { match('[a-zA-Z_]') }
  rule(:xdigit) { digit | match('[a-fA-F]') }

  rule(:semicolon) { match('[\s*;\s*]') }
  rule(:equals) {str('=')}
  rule(:comma) { spaces? >> str(',') >> spaces? }
  rule(:left_brace) { spaces? >> str('{') >> spaces? }
  rule(:right_brace) { spaces? >> str('}') >> spaces? }

  rule(:identifier) {
    (alpha >> (alpha | digit).repeat).as(:identifier) >> spaces?
  }


  rule(:comment) {
    (str('/**') >> (str('*/').absent? >> any).repeat >> str('*/')).as(:doc_comment) >> spaces? |
    (str('/*') >> (str('*/').absent? >> any).repeat >> str('*/')).as(:comment) >> spaces? |
    (str('//') >> (new_line.absent? >> any).repeat).as(:comment) >> spaces?
  }

  rule(:typedef_declaration) {
    str('typedef') >> spaces? >> type_declaration.as(:inner) >> spaces? >> identifier >> semicolon
  }

  rule (:enum_declaration) {
    (str('enum') >> spaces? >> identifier.maybe >> spaces? >> left_brace >> enum_list.as(:values) >> right_brace).as(:enum)
  }

  rule (:enum_list) {
    (
     identifier >> comma.maybe
    ).repeat
  }

  rule(:type_declaration) {
    typedef_declaration |
    enum_declaration |
    identifier
  }

  rule(:statements) {
    (
     comment |
     (
      type_declaration.as(:type)
    ) >> semicolon >> spaces?).repeat
  }

  root :statements

end
