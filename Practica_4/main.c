/*#############
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#############*/
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"

#define TABLESIZE 1024

#define OP_INSERT   1
#define OP_AMBIT    2
#define OP_GET      3
#define OP_END      4

Data create_hashable_int(int value);
void print_result(FILE* out, int result, char* key, int parsed_value, int op_type);
int int_hash_parse_line(char* line, char** ident, int* value);

int main(int argc, char ** argv) {
    FILE* out = NULL;
    FILE* in = NULL;

    char* line = NULL;
    size_t len = 0;

    int op_type = 0;
    char* parsed_key = NULL;
    int parsed_val = 0;
    int result = 0;
    Data value;
    Data* search_result;

    HashTable *global_table, *local_table = NULL;
    HashTable *ht_to_insert = NULL;
    
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
    while (getline(&line, &len, in) != -1) {
        parsed_key = 0;
        parsed_val = 0;
        op_type = int_hash_parse_line(line, &parsed_key, &parsed_val);
        if(op_type < 0) {
            // ERROR: Lectura erronea
            free(line);
            line = NULL;
            continue;
        }

        /*
        INTENTO DE INSERCION DEL VALOR
        ******************************
        */
        if(op_type == OP_INSERT) {
            /*
            Para las pruebas guardamos valores en un
            array ya inicializado para evitar reservar memoria
            constantemente
            */
            value = create_hashable_int(parsed_val);

            /*
            Detectamos si estamos en un ambito local o en el global.
            Para la insercion solo hace falta tener en cuenta el mas
            restrictivo (local > global).
            */
            ht_to_insert = global_table;
            if (local_table != NULL) {
                ht_to_insert = local_table;
            }
            result = hash_table_insert(ht_to_insert, parsed_key, value);
            print_result(out, result, parsed_key, parsed_val, OP_INSERT);
        }

        /*
        ABRIR NUEVO AMBITO
        ******************************
        */
        else if (op_type == OP_AMBIT) {
            if (local_table != NULL) {
                // ERROR: Ambito ya abierto
                free(line);
                line = NULL;
                continue;
            }

            value = create_hashable_int(parsed_val);

            /* INSERCION EN TABLA GLOBAL
            ******************************
            */
            result = hash_table_insert(global_table, parsed_key, value);
            print_result(out, result, parsed_key, parsed_val, OP_AMBIT);
            if(result != 0) {
                free(line);
                line = NULL;
                continue;
            }

            /* inicializamos la tabla local e insertamos en ella */
            /* INSERCION EN TABLA LOCAL
            ******************************
            */
            local_table = hash_table_create(TABLESIZE);
            result = hash_table_insert(local_table, parsed_key, value);
        }

        /*
        INTENTO DE RECUPERAR UN VALOR
        *******************************
        */
        else if (op_type == OP_GET) {
            if (local_table != NULL) {
                /* si está en el ámbito local, busca primero en este ámbito */
                search_result = hash_table_search(local_table, parsed_key);
                if (search_result != NULL) {    /* encontrado en ámbito local */
                    fprintf(out, "%s\t%d\n", parsed_key, search_result->elem_category);
                    free(line);
                    line = NULL;
                    continue;
                }
            }
            /* busca en el ámbito global */
            search_result = hash_table_search(global_table, line);
            if (search_result != NULL) {    /* encontrado en ámbito global */
                fprintf(out, "%s\t%d\n", parsed_key, search_result->elem_category);
            } else {                        /* no se ha encontrado */
                fprintf(out, "%s\t-1\n", parsed_key);
            }
        }

        /*
        CERRAR AMBITO LOCAL (ACTUAL)
        ******************************
        */
        else if (op_type == OP_END) {
            /* cierra el ámbito local */
            hash_table_destroy(local_table);
            local_table = NULL;
            fprintf(out, "cierre\n");
        }
        free(line);
        line = NULL;
    }

    hash_table_destroy(local_table);
    hash_table_destroy(global_table);
    fclose(out);
    fclose(in);
    free(line);
    return 0;
}


void print_result(FILE* out, int result, char* key, int parsed_value, int op_type) {
    if (op_type == OP_INSERT || op_type == OP_AMBIT) {
        if(result == 0){
            // Insercion correcta
            fprintf(out, "%s\n", key);
        }
        else if( result == 1) {
            // Colision de clave
            fprintf(out, "-1\t%s\n", key);
        }
        else if( result == 2) {
            // Carga maxima
            fprintf(out, "No se ha encontrado hueco para la clave: %s con valor: %d\n", key, parsed_value);
        }
    }
}


/*
*   Dada una linea la lee y devuelve en ident y value el identificador
*   y el valor leidos si los hay. Devuelve como retorno el tipo de operacion.
******************************************************************************
*/
int int_hash_parse_line(char* line, char** ident, int* value) {
    if(line == NULL || ident == NULL || value == NULL) return -1;
    char tok[3] = " \t";
    char* ptr = NULL;
    char* words[2] = {NULL, NULL};

    // Eliminamos \n y \r
    line[strcspn(line, "\r\n")] = 0;

    ptr = strtok(line, tok);
    if(ptr == NULL) {
        // No hay cadena
        return -1;
    }
    words[0] = ptr;
    ptr = strtok(NULL, tok);
    if(ptr == NULL) {
        // Solo una palabra
        *ident = words[0];
        return OP_GET;
    }
    words[1] = ptr;
    ptr = strtok(NULL, tok);
    if(ptr == NULL) {
        // Cierre o...
        if(strcmp(words[0], "cierre") == 0 && strcmp(words[1], "-999") == 0) {
            return OP_END;
        }
        // Dos palabras
        *ident = words[0];
        *value = atoi(words[1]);
        if (*value >= 0) {
            return OP_INSERT;
        }
        return OP_AMBIT;
    }
    // Mas de dos palabras es un turbo-error:
    return -1;
}


/* Solo util para los tests */
Data create_hashable_int(int value) {
    Data result = {value, 0, 0, 0, 0, 0 ,0 , 0};
    return result;
}