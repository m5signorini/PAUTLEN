/*#############
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#############*/
#include <stdio.h>
#include <string.h>

int yylex();
int yyparse();
FILE * out = NULL;



int main(int argc, char ** argv) {
    extern FILE * yyin;
    /* Error: Numero de parametros */
    if(argc < 3) {
        printf("Error: no hay suficientes parámetros\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        /* Error: Fichero entrada */
        printf("Error al abrir el fichero de entrada\n");
        return 1;
    }
    out = fopen(argv[2], "w");
    if(out == NULL) {
        /* Error: Fichero salida */
        fclose(yyin);
        printf("Error al abrir el fichero de salida\n");
        return 1;
    }
    
    yyparse();

    fclose(yyin);
    fclose(out);
    return 0;
}

