/*#############
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#############*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"

#define TABLESIZE 1024

int yylex();

int main(int argc, char ** argv) {
    FILE * out = NULL;
    FILE * in = NULL;

    char * line = NULL;
    char * splitted_line = NULL;

    size_t len = 0;
    ssize_t read;

    char * key = NULL;
    int values[TABLESIZE];
    int index = 0;
    void* value;
    int i, words = 0, fail = -1;

    void *search_result = NULL;

    HashTable *global_table, *local_table = NULL;
    
    /*
    Comprobacion de argumentos de entrada
    *************************************
    */
    if(argc < 3) {
        fprintf(stderr, "****Error en los parámetros, utilizar ./nombre <entrada.txt> <salida.txt>\n");
        return 1;
    }
    in = fopen(argv[1], "r");
    if(in == NULL) {
        return 1;
    }
    out = fopen(argv[2], "w");
    if(out == NULL) {
        fclose(in);
        return 1;
    }

    /* 
    Crea la tabla global 
    ***************************************************
    */
    global_table = hash_table_create(TABLESIZE);
    if(global_table == NULL) {
        printf("*****Error creando la tabla hash\n");
        return 1;
    }

    /*
    Leemos el fichero de entrada linea por linea
    ****************************************************
    */
    while ((read = getline(&line, &len, in)) != -1) {
        for (i = 0; line[i] != '\0'; i++)
        {
            if (line[i] == ' ' && line[i+1] != ' ')
                words++;    
        }
        
        if (words == 2){
            splitted_line = strtok(line, " ");
            /* clave */
            key = splitted_line;
            
            /* valor */
            splitted_line = strtok(NULL, " ");
            values[index] = atoi(splitted_line);
            value = (void*)&values[index++];

            if (value >= 0){
                if (local_table != NULL) {
                    /* encontrado ámbito local */
                    search_result = hash_table_search(local_table, key);
                    if (search_result != NULL) {
                        /* fallo, ha encontrado algo */
                        fprintf(out, "%d %s\n", fail, key);
                    }
                    else {
                        if(hash_table_insert(local_table, key, value) == 0){
                            fprintf(out, "%s\n", key);
                        }
                        else {
                            fprintf(out, "No se ha encontrado hueco para la clave: %s con valor: %s\n", key, value);
                        }
                    }
                }
                else {
                    /* no encontrado ámbito local, luego ámbito global */
                    search_result = hash_table_search(global_table, key);
                    if (search_result != NULL) {
                        /* fallo, ha encontrado algo */
                        fprintf(out, "%d %s\n", fail, key);
                    }
                    else {
                        if(hash_table_insert(global_table, key, value) == 0){
                            fprintf(out, "%s\n", key);
                        }
                        else {
                            fprintf(out, "No se ha encontrado hueco para la clave: %s con valor: %d\n", key, *((int*)value));
                        }
                    }
                }
            }
            else {
                /* apertura ámbito local (luego aún no existe)*/
                search_result = hash_table_search(global_table, key);
                if (search_result != NULL) {
                    /* fallo, ha encontrado algo */
                    fprintf(out, "%d %s\n", fail, key);
                }
                else {
                    if(hash_table_insert(global_table, key, value) == 0){
                        fprintf(out, "%s\n", key);
                    }
                    else {
                        fprintf(out, "No se ha encontrado hueco para la clave: %s con valor: %d\n", key, *((int*)value));
                    }
                    /* inicializamos la tabla local e insertamos en ella */
                    local_table = hash_table_create(TABLESIZE);
                    if(hash_table_insert(local_table, key, value) == 0){
                        fprintf(out, "%s\n", key);
                    }
                    else {
                        fprintf(out, "No se ha encontrado hueco para la clave: %s con valor: %d\n", key, *((int*)value));
                    }

                }
            }

        } else if (words == 1) {
            if (strcmp(line, "cierre -999") == 0) {
                /* cierra el ámbito local */
                hash_table_destroy(local_table);
                local_table = NULL;
                fprintf(out, "cierre\n");
            }
        } else {    /* busca en la tabla un identificador */
            if (local_table != NULL) {
                /* si está en el ámbito local, busca primero en este ámbito */
                search_result = hash_table_search(local_table, line);
                if (search_result != NULL) {    /* encontrado en ámbito local */
                    fprintf(out, "%s %d\n", line, *((int*)search_result));
                }
            }
            /* busca en el ámbito global */
            search_result = hash_table_search(global_table, line);
            if (search_result != NULL) {    /* encontrado en ámbito global */
                fprintf(out, "%s %d\n", line, *((int*)search_result));
            } else {                        /* no se ha encontrado */
                fprintf(out, "%s -1\n", line);
            }
        }
        
        printf("%s", line);
    }

    return 0;
}
