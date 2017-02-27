%{
#include <vslc.h>
#include "y.tab.h"
%}

%option noyywrap
%option array
%option yylineno

DIGIT [0-9]
LETTER [a-zA-Z_]
LITERAL \"(\\.|[^"])*\"
COMMENT "//".*
SPACE [ \t\n]

%%
FUNC                        { return FUNC; }
BEGIN                       { return OPENBLOCK; }
END                         { return CLOSEBLOCK; }
RETURN                      { return RETURN; }
PRINT                       { return PRINT; }
CONTINUE                    { return CONTINUE; }
IF                          { return IF; }
THEN                        { return THEN; }
ELSE                        { return ELSE; }
WHILE                       { return WHILE; }
DO                          { return DO; }
VAR                         { return VAR; }

{DIGIT}+                    { return NUMBER; }
{LITERAL}                   { return STRING; }
{LETTER}({LETTER}|{DIGIT})* { return IDENTIFIER; }

{SPACE}                     { }
{COMMENT}                   { }

.                           { return yytext[0]; }
%%
