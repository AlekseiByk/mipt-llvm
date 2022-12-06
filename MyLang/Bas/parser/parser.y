%language "c++"
%skeleton "lalr1.cc"

%define api.value.type variant
%param {Driver* driver}

%code requires {
    #include <string>
    #include <memory>
    namespace yy { class Driver; }
    namespace win { class INode; class ScopeN; class FuncDeclN; }
}

%code {
    #include "driver.hh"
    #include "node.hh"
    namespace yy {parser::token_type yylex(parser::semantic_type* yylval, Driver* driver);}
}

%token <std::string> IDENTIFIER 
%token <int> INTEGER
%token WHILE             "while"   
       RETURN            "return"
       BREAK             "break"
       INPUT             "?"
       IF                "if"
       FN                "fn"
       SCOLON            ";"
       LCB               "{"
       RCB               "}"
       LRB               "("
       RRB               ")"
       LAB               "["
       RAB               "]"
       COMMA             ","
       OUTPUT            "print"
       ASSIGN            "="
       OR                "||" 
       AND               "&&"
       NOT               "!"
       EQUAL             "=="
       NOT_EQUAL         "!="
       GREATER           ">"
       LESS              "<"
       LESS_OR_EQUAL     "<="
       GREATER_OR_EQUAL  ">="
       PLUS              "+"  
       MINUS             "-"
       MUL               "*"
       DIV               "/"
       MOD               "%"

%nterm<std::shared_ptr<win::ScopeN>>     globalScope
%nterm<std::shared_ptr<win::ScopeN>>     scope
%nterm<std::shared_ptr<win::ScopeN>>     closeSc
%nterm<std::shared_ptr<win::ScopeN>>     openSc
%nterm<std::shared_ptr<win::INode>>      func
%nterm<std::shared_ptr<win::FuncDeclN>>  funcSign
%nterm<std::shared_ptr<win::INode>>      argList
%nterm<std::shared_ptr<win::INode>>      stm
%nterm<std::shared_ptr<win::INode>>      declVar
%nterm<std::shared_ptr<win::INode>>      lval
%nterm<std::shared_ptr<win::INode>>      if 
%nterm<std::shared_ptr<win::INode>>      while
%nterm<std::shared_ptr<win::INode>>      expr2
%nterm<std::shared_ptr<win::INode>>      expr3
%nterm<std::shared_ptr<win::INode>>      expr4
%nterm<std::shared_ptr<win::INode>>      expr6
%nterm<std::shared_ptr<win::INode>>      expr7
%nterm<std::shared_ptr<win::INode>>      expr11
%nterm<std::shared_ptr<win::INode>>      expr12
%nterm<std::shared_ptr<win::INode>>      expr0
%nterm<std::shared_ptr<win::INode>>      startExpr
%nterm<std::shared_ptr<win::INode>>      output 
%nterm<std::shared_ptr<win::INode>>      stms
%nterm<std::shared_ptr<win::INode>>      return
%nterm<std::shared_ptr<win::INode>>      funcCall
%nterm<std::shared_ptr<win::INode>>      globalArrDecl
%nterm<std::shared_ptr<win::INode>>      arrAccess

%%

program:        globalScope                         { driver->codegen(); };

globalScope:    globalScope globalArrDecl           {
                                                        auto&& scope = driver->m_currentScope;
                                                        scope->insertChild($2);
                                                    };
              | globalScope func                    { 
                                                        auto&& scope = driver->m_currentScope;
                                                        scope->insertChild($2);
                                                    };
              | /* empty */                         {};

globalArrDecl:  IDENTIFIER LAB INTEGER RAB SCOLON   {
                                                        auto&& scope = driver->m_currentScope;
                                                        auto&& node = std::make_shared<win::DeclGlobalArrN>($3);
                                                        node->setName($1);
                                                        $$ = node;
                                                        scope->insertDecl($1, node);
                                                    };

func:           FN funcSign stms closeSc            {
                                                        auto&& scope = driver->m_currentScope;
                                                        $$ = std::make_shared<win::FuncN>($4, $2);
                                                        auto&& fnName = $2->getName();
                                                        assert(scope->getDeclIfVisible(fnName) == nullptr && "decl with same name exists"); // TODO: fix
                                                        scope->insertDecl(fnName, $2);
                                                    };
funcSign:       IDENTIFIER LRB argList RRB LCB      {
                                                        auto&& scope = driver->m_currentScope;
                                                        scope = std::make_shared<win::ScopeN>(scope);
                                                        auto&& currentFunctionArgs = driver->m_currentFunctionArgs;

                                                        for(const std::string& name : currentFunctionArgs) {
                                                            auto&& node = std::make_shared<win::DeclVarN>();
                                                            scope->insertDecl(name, node);
                                                        }

                                                        $$ = std::make_shared<win::FuncDeclN>($1, currentFunctionArgs);
                                                        scope->setParentFunc($$);
                                                        currentFunctionArgs.clear();
                                                    };

argList:        argList COMMA IDENTIFIER            {
                                                        auto&& currentFunctionArgs = driver->m_currentFunctionArgs;
                                                        currentFunctionArgs.push_back($3); 
                                                    };
              | IDENTIFIER                          {
                                                        auto&& currentFunctionArgs = driver->m_currentFunctionArgs;
                                                        currentFunctionArgs.push_back($1); 
                                                    };
              | /* empty */                         {};

scope:          openSc stms closeSc                 {$$ = $3;};

openSc:         LCB                                 {
                                                        auto&& scope = driver->m_currentScope;
                                                        scope = std::make_shared<win::ScopeN>(scope);
                                                    };

closeSc:        RCB                                 {
                                                        auto&& scope = driver->m_currentScope;
                                                        $$ = scope;
                                                        scope = scope->getParent();
                                                    };

stms:           stm                                 {
                                                        auto&& scope = driver->m_currentScope;
                                                        scope->insertChild($1);
                                                    };

              | stms stm                            {
                                                        auto&& scope = driver->m_currentScope;
                                                        scope->insertChild($2);
                                                    };

stm:            declVar                             { $$ = $1; };
              | if                                  { $$ = $1; };
              | while                               { $$ = $1; };
              | output                              { $$ = $1; };
              | return                              { $$ = $1; };
              | funcCall SCOLON                     { $$ = $1; };
              | BREAK SCOLON                        { $$ = std::make_shared<win::BreakN>(); }

declVar:        lval ASSIGN startExpr SCOLON        { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Assign, $3); };

lval:           IDENTIFIER                          {
                                                        auto&& scope = driver->m_currentScope;
                                                        auto&& node = scope->getDeclIfVisible($1);
                                                        if(!node) {
                                                            node = std::make_shared<win::DeclVarN>();
                                                            scope->insertDecl($1, node);
                                                        }
                                                        $$ = node;
                                                    };
              | arrAccess                           { $$ = $1; };

arrAccess:      IDENTIFIER LAB startExpr RAB        {
                                                        auto&& scope = driver->m_currentScope;
                                                        auto&& node = scope->getDeclIfVisible($1);
                                                        assert(node != nullptr && "undeclared");
                                                        $$ = std::make_shared<win::ArrAccessN>($3, node);
                                                    };

startExpr:      expr12                              { $$ = $1; };

expr12:         expr11 OR expr11                    { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Or, $3); };  
              | expr11                              { $$ = $1; };

expr11:         expr7 AND expr7                     { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::And, $3); };
              | expr7                               { $$ = $1; };

expr7:          expr6 EQUAL expr6                   { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Equal, $3); };  
              | expr6 NOT_EQUAL expr6               { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::NotEqual, $3); };  
              | expr6                               { $$ = $1; };

expr6:          expr4 GREATER expr4                 { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Greater, $3); };  
              | expr4 LESS expr4                    { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Less, $3); };  
              | expr4 GREATER_OR_EQUAL expr4        { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::GreaterOrEqual, $3); };  
              | expr4 LESS_OR_EQUAL expr4           { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::LessOrEqual, $3); };
              | expr4                               { $$ = $1; };

expr4:          expr3 PLUS expr3                    { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Plus, $3); };
              | expr3 MINUS expr3                   { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Minus, $3); };
              | expr3                               { $$ = $1; };

expr3:          expr2 MUL expr2                     { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Mult, $3); };
              | expr2 DIV expr2                     { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Div, $3); };
              | expr2 MOD expr2                     { $$ = std::make_shared<win::BinOpN>($1, win::BinOp::Mod, $3); };
              | expr2                               { $$ = $1; };

expr2:          NOT expr0                           { $$ = std::make_shared<win::UnOpN>(win::UnOp::Not, $2); };
              | expr0                               { $$ = $1; };

expr0:          LRB expr12 RRB                      { $$ = $2; }; 
              | IDENTIFIER                          
                                                    {
                                                        auto&& scope = driver->m_currentScope;
                                                        auto&& node = scope->getDeclIfVisible($1);
                                                        assert(node != nullptr);
                                                        $$ = node;
                                                    };
              | INTEGER                             { $$ = std::make_shared<win::I32N>($1); };
              | INPUT                               { $$ = std::make_shared<win::UnOpN>(win::UnOp::Input, nullptr); };
              | funcCall                            { $$ = $1; };
              | arrAccess                           { $$ = $1; }

funcCall:       IDENTIFIER LRB argList RRB          {
                                                        auto&& scope = driver->m_currentScope;
                                                        auto&& currentFunctionArgs = driver->m_currentFunctionArgs;
                                                        auto&& node = scope->getDeclIfVisible($1);
                                                        assert(node != nullptr);
                                                        $$ = std::make_shared<win::FuncCallN>(node, scope, currentFunctionArgs);
                                                        currentFunctionArgs.clear();
                                                    };

if:          IF LRB startExpr RRB scope             {
                                                        auto&& scope = driver->m_currentScope;
                                                        $$ = std::make_shared<win::IfN>($5, $3, scope);
                                                    };

while:       WHILE LRB startExpr RRB scope          {
                                                        auto&& scope = driver->m_currentScope;
                                                        $$ = std::make_shared<win::WhileN>($5, $3, scope);
                                                    };

output:      OUTPUT startExpr SCOLON                { $$ = std::make_shared<win::UnOpN>(win::UnOp::Output, $2); };

return:      RETURN startExpr SCOLON                { $$ = std::make_shared<win::RetN>($2); };

%%

namespace yy {

    parser::token_type yylex (parser::semantic_type* yylval, Driver* driver) {
		return driver->yylex(yylval);
	}

    void parser::error (const std::string& msg) {
        std::cout << msg << " in line: " << std::endl;
	}
}