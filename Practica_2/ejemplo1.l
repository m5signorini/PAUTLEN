%{
#include <stdio.h>
%}
%option noyywrap

/* para utilizar printf en la
   sección de reglas */
/* para procesar sólo 1
   fichero */

%%
INICIO		{ printf("reconocido INICIO\n"); }
FIN		{ printf("reconocido FIN\n"); }
VECTOR		{ printf("reconocido VECTOR\n"); }
ENTERO		{ printf("reconocido ENTERO\n"); }
LOGICO 		{ printf("reconocido LOGICO\n"); }
%%

/*
int main() {
         return yylex();
}*/
