%{
#include <stdio.h>
#include "tok.h"

long yylin = 1;
long yycol = 1;

%}
%option noyywrap
ESPACIO 		[ \t]+
SALTOLINEA	\n|\n\r|\r
INICIO		"INICIO"
FIN		"FIN"
VECTOR		"VECTOR"
ENTERO		"ENTERO"
ID		[a-zA-Z]*
ERROR		.
%%
{ESPACIO}	{ yycol += yyleng; }
{SALTOLINEA}	{ yycol=0; yylin++; }
{INICIO}		{ yycol += yyleng; return TOK_INICIO;}
{FIN}		{ yycol += yyleng; return TOK_FIN;}
{VECTOR}		{ yycol += yyleng; return TOK_VECTOR; }
{ENTERO}		{ yycol += yyleng; return TOK_ENTERO; }
{ID}		{ yycol += yyleng; return TOK_ID; }
{ERROR}		{ yycol += yyleng; return TOK_ERROR; }
%%
 
/*
int main() {
         return yylex();
}*/
