%{
#include <stdio.h>
#include "calc.h"

int yylex();
void yyerror();
extern FILE * out;
extern long yylin;
extern long yycol;
extern int yy_morph_error;



/*simulación de una tabla  de símbolos (muy básica) con solo 4 elementos */
char variables[4] = {'a','b','c','d'};
int  var_valor[4] = {0, 0, 0, 0}; 


%}

%union {
	info_atributos atributos;
}


%token TOK_PUNTOYCOMA
%token TOK_ASIGNACION
%token TOK_MAS
%token TOK_MENOS
%token TOK_ASTERISCO

%token <atributos> TOK_IDENTIFICADOR

%token <atributos> TOK_CONSTANTE_ENTERA

%token TOK_ERROR


%type <atributos> exp
%type <atributos> constante 
%type <atributos> identificador;

%left TOK_MAS, TOK_MENOS

%%


inicio: sentencias { int i; fprintf(out,"-----Estado Final -----\n"); for(i=0; i< 4; i++)  {  fprintf(out, "%c: %d\n",variables[i], var_valor[i]); }  }

sentencias: sentencia { }
          | sentencia sentencias {  }
          ;

sentencia: sentencia_simple TOK_PUNTOYCOMA { }
         ;

sentencia_simple: asignacion { }
                ;

asignacion: identificador TOK_ASIGNACION exp  {
		int index = -1;
		int i;
		for(i=0; i<4; i++) {
			if(variables[i] == $1.id) { index = i; }
		}
		if(index==-1) {
			printf("***Error semantico***\n");
		}
		var_valor[index] = $3.valor;
	}
          ;


exp: exp TOK_MAS exp { $$.valor = $1.valor + $3.valor; }
   | exp TOK_MENOS exp { $$.valor = $1.valor - $3.valor; }
   | constante { $$.valor = $1.valor;}
   ;

identificador: TOK_IDENTIFICADOR { $$.id = $1.id; }
             ;

constante: TOK_CONSTANTE_ENTERA { $$.valor = $1.valor; }
         ;

%%

void yyerror(const char * s) {
    if(!yy_morph_error) {
        printf("****Error sintactico en linea: %ld\n", yylin);
    }
}
