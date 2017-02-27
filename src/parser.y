%{
#include <vslc.h>
#include <stdlib.h>

extern char yytext[];
extern int yylineno;

// Macro for allocating memory to strings.
#define clone(s) strncpy((char*) malloc(strlen(s) + 1), s, strlen(s) + 1)

// Macros for allocating memory to nodes.
// The integer specifies the number of children to pass as argument.
#define N0C(type, data) \
    node_init(malloc(sizeof(node_t)), type, data, 0)
#define N1C(type, data, a) \
    node_init(malloc(sizeof(node_t)), type, data, 1, a)
#define N2C(type, data, a, b) \
    node_init(malloc(sizeof(node_t)), type, data, 2, a, b)
#define N3C(type, data, a, b, c) \
    node_init(malloc(sizeof(node_t)), type, data, 3, a, b, c)
%}

%error-verbose
%expect 1

%token FUNC PRINT RETURN CONTINUE IF THEN ELSE WHILE DO OPENBLOCK CLOSEBLOCK
%token VAR NUMBER IDENTIFIER STRING

%left '='
%left '<' '>'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%
program:
    global_list {
        root = node_init(malloc(sizeof(node_t)), PROGRAM, NULL, 1, $1);
    }
    ;

global_list:
    global {
        $$ = N1C(GLOBAL_LIST, NULL, $1);
    }
    | global_list global {
        $$ = N2C(GLOBAL_LIST, NULL, $1, $2);
    }
    ;

global:
    function {
        $$ = N1C(GLOBAL, NULL, $1);
    }
    | declaration {
        $$ = N1C(GLOBAL, NULL, $1);
    }
    ;

statement_list:
    statement {
        $$ = N1C(STATEMENT_LIST, NULL, $1);
    }
    | statement_list statement {
        $$ = N2C(STATEMENT_LIST, NULL, $1, $2);
    }
    ;

print_list:
    print_item {
        $$ = N1C(PRINT_LIST, NULL, $1);
    }
    | print_list ',' print_item {
        $$ = N2C(PRINT_LIST, NULL, $1, $3);
    }
    ;

expression_list:
    expression {
        $$ = N1C(EXPRESSION_LIST, NULL, $1);
    }
    | expression_list ',' expression {
        $$ = N2C(EXPRESSION_LIST, NULL, $1, $3);
    }
    ;

variable_list:
    identifier {
        $$ = N1C(VARIABLE_LIST, NULL, $1);
    }
    | variable_list ',' identifier {
        $$ = N2C(VARIABLE_LIST, NULL, $1, $3);
    }
    ;

argument_list:
    expression_list {
        $$ = N1C(ARGUMENT_LIST, NULL, $1);
    }
    | { $$ = NULL; }
    ;

parameter_list:
    variable_list {
        $$ = N1C(PARAMETER_LIST, NULL, $1);
    }
    | { $$ = NULL; }
    ;

declaration_list:
    declaration {
        $$ = N1C(DECLARATION_LIST, NULL, $1);
    }
    | declaration_list declaration {
        $$ = N2C(DECLARATION_LIST, NULL, $1, $2);
    }
    ;

function:
    FUNC identifier '(' parameter_list ')' statement {
        $$ = N3C(FUNCTION, NULL, $2, $4, $6);
    }
    ;

statement:
    assignment_statement {
        $$ = N1C(STATEMENT, NULL, $1);
    }
    | return_statement {
        $$ = N1C(STATEMENT, NULL, $1);
    }
    | print_statement {
        $$ = N1C(STATEMENT, NULL, $1);
    }
    | if_statement {
        $$ = N1C(STATEMENT, NULL, $1);
    }
    | while_statement {
        $$ = N1C(STATEMENT, NULL, $1);
    }
    | null_statement {
        $$ = N1C(STATEMENT, NULL, $1);
    }
    | block {
        $$ = N1C(STATEMENT, NULL, $1);
    }
    ;

block:
    OPENBLOCK declaration_list statement_list CLOSEBLOCK {
        $$ = N2C(BLOCK, NULL, $2, $3);
    }
    | OPENBLOCK statement_list CLOSEBLOCK {
        $$ = N1C(BLOCK, NULL, $2);
    }
    ;

assignment_statement:
    identifier ':' '=' expression {
        $$ = N2C(ASSIGNMENT_STATEMENT, NULL, $1, $4);
    }
    ;

return_statement:
    RETURN expression {
        $$ = N1C(RETURN_STATEMENT, NULL, $2);
    }
    ;

print_statement:
    PRINT print_list {
        $$ = N1C(PRINT_STATEMENT, NULL, $2);
    }
    ;

null_statement:
    CONTINUE {
        $$ = N0C(NULL_STATEMENT, NULL);
    }
    ;

if_statement:
    IF relation THEN statement {
        $$ = N2C(IF_STATEMENT, NULL, $2, $4);
    }
    | IF relation THEN statement ELSE statement {
        $$ = N3C(IF_STATEMENT, NULL, $2, $4, $6);
    }
    ;

while_statement:
    WHILE relation DO statement {
        $$ = N2C(WHILE_STATEMENT, NULL, $2, $4);
    }
    ;

relation:
    expression '<' expression {
        $$ = N2C(RELATION, clone("<"), $1, $3);
    }
    | expression '>' expression {
        $$ = N2C(RELATION, clone(">"), $1, $3);
    }
    | expression '=' expression {
        $$ = N2C(RELATION, clone("="), $1, $3);
    }

expression:
    expression '+' expression {
        $$ = N2C(EXPRESSION, clone("+"), $1, $3);
    }
    | expression '-' expression {
        $$ = N2C(EXPRESSION, clone("-"), $1, $3);
    }
    | expression '*' expression {
        $$ = N2C(EXPRESSION, clone("*"), $1, $3);
    }
    | expression '/' expression {
        $$ = N2C(EXPRESSION, clone("/"), $1, $3);
    }
    | '-' expression %prec UMINUS {
        $$ = N1C(EXPRESSION, clone("-"), $2);
    }
    | '(' expression ')' {
        $$ = $2;
    }
    | number {
        $$ = N1C(EXPRESSION, NULL, $1);
    }
    | identifier {
        $$ = N1C(EXPRESSION, NULL, $1);
    }
    | identifier '(' argument_list ')' {
        $$ = N2C(EXPRESSION, NULL, $1, $3);
    }
    ;

declaration:
    VAR variable_list {
        $$ = N1C(DECLARATION, NULL, $2);
    }
    ;

print_item:
    expression {
        $$ = N1C(PRINT_ITEM, NULL, $1);
    }
    | string {
        $$ = N1C(PRINT_ITEM, NULL, $1);
    }
    ;

identifier:
    IDENTIFIER {
        $$ = N0C(IDENTIFIER_DATA, clone(yytext));
    }
    ;

number:
    NUMBER {
        $$ = N0C(NUMBER_DATA, calloc(1, sizeof(int64_t)));
        *((int64_t *) $$->data) = strtol(yytext, NULL, 10);
    }
    ;

string:
    STRING {
        $$ = N0C(STRING_DATA, clone(yytext));
    }
    ;
%%

int yyerror(const char *error)
{
    fprintf(stderr, "%s on line %d\n", error, yylineno);
    exit(EXIT_FAILURE);
}
