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

  rule(:assign) { spaces? >> str('=') >> spaces?}
  rule(:left_brace) { spaces? >> str('{') >> spaces? }
  rule(:right_brace) { spaces? >> str('}') >> spaces? }

  def self.symbols(symbols)
    symbols.each do |name,symbol|
      rule(name) { spaces? >> str(symbol) >> spaces? }
    end
  end

  symbols :ellipsis => '...',
  :semicolon => ';',
  :comma => ',',
  :colon => ':',
  :left_paren => '(',
  :right_paren => ')',
  :member_access => '.',
  :question_mark => '?'

  rule(:identifier) {
    (alpha >> (alpha | digit).repeat).as(:identifier) >> spaces?
  }

  rule(:comment) {
    (str('/**') >> (str('*/').absent? >> any).repeat >> str('*/')).as(:doc_comment) >> spaces? |
    (str('/*') >> (str('*/').absent? >> any).repeat >> str('*/')).as(:comment) >> spaces? |
    (str('//') >> (new_line.absent? >> any).repeat).as(:comment) >> spaces?
  }

  rule(:typedef_declaration) {
    str('typedef') >> spaces? >> type_declaration.as(:inner) >> spaces? >> identifier
  }

  rule (:enum_declaration) {
    (str('enum') >> spaces? >> identifier.maybe >> spaces? >> left_brace >> enum_list.as(:values) >> right_brace).as(:enum) |
    (str('enum') >> spaces? >> identifier).as(:enum)
  }

  rule(:enum_entry) {
    identifier >> (assign >> ((match('[,}]').absent? >> any).repeat).as(:value)).maybe
  }

  rule (:enum_list) {
    (enum_entry >> comma.maybe >> spaces?).repeat
  }

  rule (:struct_declaration) {
    (str('struct') >> spaces? >> identifier.maybe >> spaces? >> left_brace >> struct_list.as(:values) >> right_brace).as(:struct) |
    (str('struct') >> spaces? >> identifier).as(:struct)
  }

  rule(:struct_entry) {
    variable_declaration >> semicolon
  }

  rule (:struct_list) {
    (struct_entry >> comment.maybe).repeat
  }

  rule(:variable_declaration) {
    identifier.as(:type) >> str('*').maybe.as(:pointer) >> identifier >> (assign >> (semicolon.absent? >> any).repeat.as(:value)).maybe
  }

  rule(:type_declaration) {
    typedef_declaration |
    enum_declaration |
    struct_declaration |
    identifier
  }

  rule(:statements) {
    (
     comment |
     variable_declaration >> semicolon |
     type_declaration.as(:type) >> semicolon
    ).repeat
  }

  root :statements

end
