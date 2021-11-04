


%{
/* Codigo C directamente incluido */
#include <stdio.h>
int yylex();
void yyerror();
extern FILE * out;
extern long yylin;
extern long yycol;
%}
/* tokens */
%token TOK_MAIN
%token TOK_INT
%token TOK_BOOLEAN
%token TOK_ARRAY
%token TOK_FUNCTION
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_SCANF
%token TOK_PRINTF
%token TOK_RETURN

%token TOK_PUNTOYCOMA
%token TOK_COMA
%token TOK_PARENTESISIZQUIERDO
%token TOK_PARENTESISDERECHO
%token TOK_CORCHETEIZQUIERDO
%token TOK_CORCHETEDERECHO
%token TOK_LLAVEIZQUIERDA
%token TOK_LLAVEDERECHA
%token TOK_ASIGNACION
%token TOK_MAS
%token TOK_MENOS

%token TOK_DIVISION
%token TOK_ASTERISCO
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_IGUAL
%token TOK_DISTINTO
%token TOK_MENORIGUAL
%token TOK_MAYORIGUAL
%token TOK_MENOR
%token TOK_MAYOR

%token TOK_IDENTIFICADOR

%token TOK_CONSTANTE_ENTERA
%token TOK_TRUE
%token TOK_FALSE

%token TOK_ERROR

%left TOK_MAS TOK_MENOS
%left TOK_ASTERISCO TOK_DIVISION
%left TOK_AND TOK_OR
%left TOK_NOT

%%
/* Sección de reglas */
programa: TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones funciones sentencias TOK_LLAVEDERECHA {}
        ;

declaraciones: declaracion {}
             | declaracion declaraciones {}
             ;

declaracion: clase identificadores TOK_PUNTOYCOMA {}
           ;

clase: clase_escalar {}
     | clase_vector {}
     ;

clase_escalar: tipo {}
             ;

tipo: TOK_INT {}
    | TOK_BOOLEAN {}
    ;

clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO constante_entera TOK_CORCHETEDERECHO {}
            ;

identificadores: identificador {}
               | identificador TOK_COMA identificadores {}
               ;

funciones: funcion funciones {}
         | /* vacio */ {}
         ;

funcion: TOK_FUNCTION tipo identificador TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion sentencias TOK_LLAVEDERECHA {}
       ;

parametros_funcion: parametro_funcion resto_parametros_funcion {}
                  | /* vacio */ {}
                  ;

resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion {}
                        | /* vacio */ {}
                        ;

parametro_funcion: tipo identificador {}
                 ;

declaraciones_funcion: declaraciones {}
                     | /* vacío */ {}
                     ;

sentencias: sentencia {}
         | sentencia sentencias {}
         ;

sentencia: sentencia_simple TOK_PUNTOYCOMA {}
         | bloque {}
         ;

sentencia_simple: asignacion {}
                | lectura {}
                | escritura {}
                | retorno_funcion {}
                ;

bloque: condicional {}
      | bucle {}
      ;

asignacion: identificador TOK_IGUAL exp {}
          | elemento_vector TOK_IGUAL exp {}

elemento_vector: identificador TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO {}
               ;

condicional: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {}
           | TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {}
           ;

bucle: TOK_WHILE TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {}
     ;

lectura: TOK_SCANF identificador {}
       ;

escritura: TOK_PRINTF exp {}
         ;

retorno_funcion: TOK_RETURN exp {}
               ;

exp: exp TOK_MAS exp {}
   | exp TOK_MENOS exp {}
   | exp TOK_DIVISION exp {}
   | exp TOK_ASTERISCO exp {}
   | TOK_MENOS exp {}
   | exp TOK_AND exp {}
   | exp TOK_OR exp {}
   | TOK_NOT exp {}
   | identificador {}
   | constante {}
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO {}
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO {}
   | elemento_vector {}
   | identificador TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO {}
   ;

lista_expresiones: exp resto_lista_expresiones {}
                 | /*vacio*/ {}
                 ;

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones {}
                       | /*vacio*/ {}
                       ;

comparacion: exp TOK_IGUAL  exp {}
           | exp TOK_DISTINTO exp {}
           | exp TOK_MENORIGUAL exp {}
           | exp TOK_MAYORIGUAL exp {}
           | exp TOK_MENOR exp {}
           | exp TOK_MAYOR exp {}
           ;

constante: constante_entera {}
         | constante_logica {}
         ;

constante_logica: TOK_TRUE {}
                | TOK_FALSE {}
                ;

constante_entera: TOK_CONSTANTE_ENTERA {}
                ;

identificador: TOK_IDENTIFICADOR {}
             ;

%%

/* Codigo C al final */
void yyerror(const char * s) {
    printf("****Error sintactico en linea: %ld\n", yylin);
}
