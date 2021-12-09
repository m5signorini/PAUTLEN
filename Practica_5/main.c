/*#############
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#############*/
#include <stdio.h>
#include <string.h>
#include "hash.h"

#define TABLESIZE 1024

int yylex();
int yyparse();
FILE * out = NULL;

HashTable* global_ht = NULL;
HashTable* local_ht = NULL;
HashTable* actual_ht = NULL;

int main(int argc, char ** argv) {
    extern FILE * yyin;
    global_ht = hash_table_create(TABLESIZE);
    if (global_ht == NULL) {
        printf("Error: crear tabla de simbolos\n");
        return 1;
    }
    actual_ht = global_ht;

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

