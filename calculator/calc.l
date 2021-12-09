%{
#include <stdio.h>
#include <stdlib.h>
#include "calc.h"
#include "y.tab.h"


#define _ERROR_HEAD "****Error en [lin %ld, col %ld]: "
#define _ERROR_SYM  "simbolo no permitido (%s)\n"
#define _ERROR_ID   "identificador demasiado largo (%s)\n"
void _print_token(FILE * out) {
    fprintf(out, ";D:\t%s\n", yytext);
}
extern FILE * out;
long yylin = 1;
long yycol = 1;
int yy_morph_error = 0;



%}
%option noyywrap
whitespace              [ \t]+
newline                 \n|\n\r|\r
comentario              "//".*
puntoycoma          	";"
asignacion          	"="
mas                 	"+"
menos               	"-"
asterisco           	"*"
constante_entera    	[0-9]+
identificador       	[a-zA-Z][a-zA-Z0-9]*
error               	.
%%
{comentario}          	{/* COMENTARIO */}
{whitespace}            {yycol += yyleng;}
{newline}               {yylin++; yycol = 0;}
{puntoycoma}          	{yycol += yyleng;  return  TOK_PUNTOYCOMA;}
{asignacion}          	{yycol += yyleng;  return  TOK_ASIGNACION;}
{mas}                 	{yycol += yyleng;  return  TOK_MAS;}
{asterisco}           	{yycol += yyleng;  return  TOK_ASTERISCO;}
{constante_entera}    	{yycol += yyleng;  yylval.atributos.valor = atoi( yytext ); return  TOK_CONSTANTE_ENTERA;}
{identificador}       	{yycol += yyleng;  yylval.atributos.id = yytext[0]; return  TOK_IDENTIFICADOR;}
{error}                 {fprintf(stderr, "****Error en linea (Flex) %ld: \n", yylin); yycol += yyleng; yy_morph_error = 1; return  TOK_ERROR;}
%%
