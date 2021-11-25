#ifndef HASH_H
#define HASH_H

#define VARIABLE 1
#define PARAMETRO 2
#define FUNCION 3

#define BOOLEAN 1
#define INT 2

#define ESCALAR 1
#define VECTOR 2

#define KEY_LEN 100

typedef struct _Data {
    int elem_category;  /* variable, parámetro o función */
    int datatype;       /* entero o booleano */
    int category;       /* escalar o vector */
    int size;           /* tamaño (si es un vector) */
    int num_params;     /* número de parámetros (si es una función) */
    int pos;            /* posición del parámetro (si es un parámetro) */
    int num_loc_vars;   /* número de variables locales (si es una función) */
    int pos_loc_var;    /* posición de la variable local (si es una var local) */
} Data;

typedef struct _Item {
   Data data;          /* información a guardar en la tabla */
   char key[KEY_LEN];   /* identificador del elemento (nombre) */
} Item;

typedef struct _HashTable {
    Item** items;
    unsigned int length;
} HashTable;


HashTable* hash_table_create(unsigned int length);
void    hash_table_destroy(HashTable* ht);
Data*   hash_table_search(HashTable* ht, char* key);
int     hash_table_insert(HashTable* ht, char* key, Data data);
int     hash_table_remove(HashTable* ht, char* key);

#endif