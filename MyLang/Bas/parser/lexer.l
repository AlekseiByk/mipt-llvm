%option c++
%option noyywrap debug
%{
#include "parser.hh"
%}

WS [ \t\n\v]+
INTEGER [0]|[1-9][0-9]*
NAME [_]*[a-zA-Z][a-zA-Z0-9_]*

%%
"ret"    return yy::parser::token_type::RETURN;
"unless"     return yy::parser::token_type::WHILE;
"if"        return yy::parser::token_type::IF;
"func"        return yy::parser::token_type::FN;
"stop"     return yy::parser::token_type::BREAK;

";"         return yy::parser::token_type::SCOLON;
"<@"         return yy::parser::token_type::LCB;
"@>"         return yy::parser::token_type::RCB;
"("         return yy::parser::token_type::LRB;
")"         return yy::parser::token_type::RRB;
"["         return yy::parser::token_type::LAB;
"]"         return yy::parser::token_type::RAB;
","         return yy::parser::token_type::COMMA;

"out"     return yy::parser::token_type::OUTPUT;

">="        return yy::parser::token_type::GREATER_OR_EQUAL;
"<="        return yy::parser::token_type::LESS_OR_EQUAL;
">"         return yy::parser::token_type::GREATER;
"<"         return yy::parser::token_type::LESS;
"=="        return yy::parser::token_type::EQUAL;
"!="        return yy::parser::token_type::NOT_EQUAL;

"="         return yy::parser::token_type::ASSIGN;

"in"         return yy::parser::token_type::INPUT;

"||"        return yy::parser::token_type::OR;
"&&"        return yy::parser::token_type::AND;
"!"         return yy::parser::token_type::NOT;

"+"         return yy::parser::token_type::PLUS;
"-"         return yy::parser::token_type::MINUS;

"*"         return yy::parser::token_type::MUL;
"/"         return yy::parser::token_type::DIV;
"%"         return yy::parser::token_type::MOD;

{WS}        
{INTEGER}   return yy::parser::token_type::INTEGER;
{NAME}      return yy::parser::token_type::IDENTIFIER;
                
%%
