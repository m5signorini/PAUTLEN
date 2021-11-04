/*#############
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#############*/
#include <stdio.h>
#include <string.h>
#include "tokens.h"

int yylex();

int main(int argc, char ** argv) {
    FILE * out = NULL;
    int ret;
    extern FILE * yyin;             // yyin fichero de entrada en codigo alfa
    extern char * yytext;           // yytext texto matcheado encontrado
    extern int yyleng;              // longitud del texto encontrado
    extern long yylin, yycol;       // fila y columna actual del texto
    if(argc < 3) {
        fprintf(stderr, "****Error en los parámetros, utilizar ./nombre <entrada.txt> <salida.txt>\n");
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        return 1;
    }
    out = fopen(argv[2], "w");
    if(out == NULL) {
        fclose(yyin);
        return 1;
    }
    while((ret = yylex()) != 0) {
        // Indexamos en funcion del retorno y continuamos leyendo
        switch(ret) {
            // ETIQUETAS DE TIPO
            case TOK_MAIN:
                fprintf(out, "%s\t%d\t%s\n", "TOK_MAIN", ret, yytext);
                break;
            case TOK_INT:
                fprintf(out, "%s\t%d\t%s\n", "TOK_INT", ret, yytext);
                break;
            case TOK_BOOLEAN:
                fprintf(out, "%s\t%d\t%s\n", "TOK_BOOLEAN", ret, yytext);
                break;
            case TOK_ARRAY:
                fprintf(out, "%s\t%d\t%s\n", "TOK_ARRAY", ret, yytext);
                break;
            case TOK_FUNCTION:
                fprintf(out, "%s\t%d\t%s\n", "TOK_FUNCTION", ret, yytext);
                break;

            // ETIQUETAS DE FLUJO
            case TOK_IF:
                fprintf(out, "%s\t%d\t%s\n", "TOK_IF", ret, yytext);
                break;
            case TOK_ELSE:
                fprintf(out, "%s\t%d\t%s\n", "TOK_ELSE", ret, yytext);
                break;
            case TOK_WHILE:
                fprintf(out, "%s\t%d\t%s\n", "TOK_WHILE", ret, yytext);
                break;
            case TOK_SCANF:
                fprintf(out, "%s\t%d\t%s\n", "TOK_SCANF", ret, yytext);
                break;
            case TOK_PRINTF:
                fprintf(out, "%s\t%d\t%s\n", "TOK_PRINTF", ret, yytext);
                break;
            case TOK_RETURN:
                fprintf(out, "%s\t%d\t%s\n", "TOK_RETURN", ret, yytext);
                break;

            // SIMBOLOS DE PUNTUACION
            case TOK_PUNTOYCOMA:
                fprintf(out, "%s\t%d\t%s\n", "TOK_PUNTOYCOMA", ret, yytext);
                break;
            case TOK_COMA:
                fprintf(out, "%s\t%d\t%s\n", "TOK_COMA", ret, yytext);
                break;
            case TOK_PARENTESISIZQUIERDO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_PARENTESISIZQUIERDO", ret, yytext);
                break;
            case TOK_PARENTESISDERECHO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_PARENTESISDERECHO", ret, yytext);
                break;
            case TOK_CORCHETEIZQUIERDO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_CORCHETEIZQUIERDO", ret, yytext);
                break;
            case TOK_CORCHETEDERECHO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_CORCHETEDERECHO", ret, yytext);
                break;
            case TOK_LLAVEIZQUIERDA:
                fprintf(out, "%s\t%d\t%s\n", "TOK_LLAVEIZQUIERDA", ret, yytext);
                break;
            case TOK_LLAVEDERECHA:
                fprintf(out, "%s\t%d\t%s\n", "TOK_LLAVEDERECHA", ret, yytext);
                break;

            // OPERACIONES
            case TOK_ASIGNACION:
                fprintf(out, "%s\t%d\t%s\n", "TOK_ASIGNACION", ret, yytext);
                break;
            case TOK_MAS:
                fprintf(out, "%s\t%d\t%s\n", "TOK_MAS", ret, yytext);
                break;
            case TOK_MENOS:
                fprintf(out, "%s\t%d\t%s\n", "TOK_MENOS", ret, yytext);
                break;
            case TOK_DIVISION:
                fprintf(out, "%s\t%d\t%s\n", "TOK_DIVISION", ret, yytext);
                break;
            case TOK_ASTERISCO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_ASTERISCO", ret, yytext);
                break;
            case TOK_AND:
                fprintf(out, "%s\t%d\t%s\n", "TOK_AND", ret, yytext);
                break;
            case TOK_OR:
                fprintf(out, "%s\t%d\t%s\n", "TOK_OR", ret, yytext);
                break;
            case TOK_NOT:
                fprintf(out, "%s\t%d\t%s\n", "TOK_NOT", ret, yytext);
                break;
            case TOK_IGUAL:
                fprintf(out, "%s\t%d\t%s\n", "TOK_IGUAL", ret, yytext);
                break;
            case TOK_DISTINTO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_DISTINTO", ret, yytext);
                break;
            case TOK_MENORIGUAL:
                fprintf(out, "%s\t%d\t%s\n", "TOK_MENORIGUAL", ret, yytext);
                break;
            case TOK_MAYORIGUAL:
                fprintf(out, "%s\t%d\t%s\n", "TOK_MAYORIGUAL", ret, yytext);
                break;
            case TOK_MENOR:
                fprintf(out, "%s\t%d\t%s\n", "TOK_MENOR", ret, yytext);
                break;
            case TOK_MAYOR:
                fprintf(out, "%s\t%d\t%s\n", "TOK_MAYOR", ret, yytext);
                break;

            // IDENTIFICADORES
            case TOK_IDENTIFICADOR:
                fprintf(out, "%s\t%d\t%s\n", "TOK_IDENTIFICADOR", ret, yytext);
                break;
            case TOK_CONSTANTE_ENTERA:
                fprintf(out, "%s\t%d\t%s\n", "TOK_CONSTANTE_ENTERA", ret, yytext);
                break;

            // BOOLEANS
            case TOK_TRUE:
                fprintf(out, "%s\t%d\t%s\n", "TOK_TRUE", ret, yytext);
                break;
            case TOK_FALSE:
                fprintf(out, "%s\t%d\t%s\n", "TOK_FALSE", ret, yytext);
                break;

            // ERROR
            case TOK_ERROR:
                if(yyleng == 1) {
                    fprintf(stderr, "****Error en [lin %ld, col %ld]: simbolo no permitido (%s)\n", yylin, yycol,
                            yytext);
                } else {        /* identificador demasiado largo */
                    fprintf(stderr, "****Error en [lin %ld, col %ld]: identificador demasiado largo (%s)\n", yylin,
                            yycol, yytext);
                }
                fclose(yyin);
                fclose(out);
                return 1;
        }
    }
    fclose(yyin);
    fclose(out);
    return 0;
}
