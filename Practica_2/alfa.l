%{
#include <stdio.h>
#include "tokens.h"

long yylin = 1;
long yycol = 1;

%}
%option noyywrap
ESPACIO 		[ \t]+
SALTOLINEA	\n|\n\r|\r
TABULADOR   \t
COMENTARIO  "\\"

MAIN        "main"
INT         "int"
BOOLEAN     "boolean"
ARRAY       "array"
FUNCTION    "function"
IF          "if"
ELSE        "else"
WHILE       "while"
SCANF       "scanf"
PRINTF      "printf"
RETURN      "return"

PUNTOYCOMA  ";"
COMA        ","
PARENTESISIZQUIERDO "("
PARENTESISDERECHO ")"
CORCHETEIZQUIERDO "["
CORCHETEDERECHO   "]"
LLAVEIZQUIERDA    "{"
LLAVEDERECHA      "}"
ASIGNACION        "="
MAS               "+"
MENOS             "-"
DIVISION          "/"
ASTERISCO         "*"
AND               "&&"
OR                "||"
NOT               "!"
IGUAL             "=="
DISTINTO          "!="
MENORIGUAL        "<="
MAYORIGUAL        ">="
MENOR             "<"
MAYOR             ">"

IDENTIFICADOR     [a-zA-Z]([0-9]|[a-zA-Z]){0, 99}

CONSTANTE_ENTERA  [0-9]+
TRUE              "true"
FALSE             "false"

ERROR		.
%%
{ESPACIO}	{ return; }
{SALTOLINEA}	{ return; }
{TABULADOR} { return;}

{MAIN}  { return TOK_MAIN; }
{INT} { return TOK_INT; }
{BOOLEAN} { return TOK_BOOLEAN; }
{ARRAY} { return TOK_ARRAY; }
{FUNCTION} { return TOK_FUNCTION; }
{IF} { return TOK_IF; }
{ELSE} { return TOK_ELSE; }
{WHILE} { return TOK_WHILE; }
{SCANF} { return TOK_SCANF; }
{PRINTF} { return TOK_PRINTF; }
{RETURN} { return TOK_RETURN; }

{PUNTOYCOMA} { return TOK_PUNTOYCOMA; }
{COMA} { return TOK_COMA; }
{PARENTESISIZQUIERDO} { return TOK_PARENTESISIZQUIERDO; }
{PARENTESISDERECHO} { return TOK_PARENTESISDERECHO; }
{CORCHETEIZQUIERDO} { return TOK_CORCHETEIZQUIERDO; }
{CORCHETEDERECHO} { return TOK_CORCHETEDERECHO; }
{LLAVEIZQUIERDA} { return TOK_LLAVEIZQUIERDA; }
{LLAVEDERECHA} { return TOK_LLAVEDERECHA; }
{ASIGNACION} { return TOK_ASIGNACION; }
{MAS} { return TOK_MAS; }
{MENOS} { return TOK_MENOS; }
{DIVISION} { return TOK_DIVISION; }
{ASTERISCO} { return TOK_ASTERISCO; }
{AND} { return TOK_AND; }
{OR} { return TOK_OR; }
{NOT} { return TOK_NOT; }
{IGUAL} { return TOK_IGUAL; }
{DISTINTO} { return TOK_DISTINTO; }
{MENORIGUAL} { return TOK_MENORIGUAL; }
{MAYORIGUAL} { return TOK_MAYORIGUAL; }
{MENOR} { return TOK_MENOR; }
{MAYOR} { return TOK_MAYOR; }

{IDENTIFICADOR} { return TOK_IDENTIFICADOR; }

{CONSTANTE_ENTERA} { return TOK_CONSTANTE_ENTERA; }
{TRUE} { return TOK_TRUE; }
{FALSE} { return TOK_FALSE; }

{ERROR}		{ return TOK_ERROR; }
%%

/*
int main() {
         return yylex();
}*/
