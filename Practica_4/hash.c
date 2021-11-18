#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define VARIABLE 1
#define PARAMETRO 2
#define FUNCION 3

#define BOOLEAN 1
#define INT 2

#define ESCALAR 1
#define VECTOR 2

#define SIZE 64

struct Item {
   struct Data data;  /* información a guardar en la tabla */
   char key[100];     /* identificador del elemento */
};

struct Data {
    int elem_category; /* variable, parámetro o función */
    int datatype;      /* entero o booleano */
    int category;      /* escalar o vector */
    int size;          /* tamaño (si es un vector) */
    int num_params;    /* número de parámetros (si es una función) */
    int pos;           /* posición del parámetro (si es un parámetro) */
    int num_loc_vars;  /* número de variables locales (si es una función) */
    int pos_loc_var;   /* posición de la variable local (si es una var local) */
}

struct Item* hashTable[SIZE];
struct Item* item;


/* Obtiene el código hash a partir del identificador utilizando
    el algoritmo djb2 para hashear cadenas de caracteres*/
int hash(char* key) {
    hash = 5381;
    int c;

    while (c = *key++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % SIZE;
}

/* Busca un elemento de identificador key en la tabla.
    Devuelve el elemento si está presente, NULL en caso contrario */
struct Item *search(char* key) {
    int hashIndex = hash(key);   /* obtiene el hash del identificador */
    int originalIndex = hashIndex;

    /* recorre la tabla empezando por el índice dado por el hash */
    while(hashTable[hashIndex] != NULL) {
        if(strcmp(hashTable[hashIndex].key, key) == 0)
            return hashTable[hashIndex];   /* si encuentra el elemento, lo retorna */

        /* avanza en la tabla */
        hashIndex++;
        hashIndex = hashIndex%SIZE;

        if(hashIndex == originalIndex) /* si ha dado la vuelta sin encontrarlo */
            break;  /* deja de buscar para devolver NULL */
    }

    return NULL;
}

/* Inserta el elemento con identificador key y datos data en la tabla
    Devuelve 1 si no se ha podido insertar, 0 en caso contrario */
int insert(char* key,struct Data data) {
    /* crea el nuevo elemento */
    struct Item *item = (struct item*) malloc(sizeof(struct Item));
    item.data = data;
    strcpy(item.key, key);

    /* obtiene el hash del nuevo elemento */
    int hashIndex = hash(key);
    int originalIndex = hashIndex;

    /* recorre el array hasta que encuentra una casilla vacía */
    while(hashTable[hashIndex] != NULL) {
        /* avanza en la tabla */
        hashIndex++;
        hashIndex = hashIndex%SIZE;

        if(hashIndex == originalIndex) /* si ha dado la vuelta sin encontrar hueco */
            return 1;
    }

    /* asigna el nuevo elemento en el sitio encontrado */
    hashTable[hashIndex] = item;
    return 0;
}

/* Elimina el elemento item de la tabla.
    Devuelve ese elemento, o NULL si no se ha encontrado */
struct Item* delete(struct Item* item) {
    char* key = item.key;

    /* obtiene el hash del elemento a eliminar */
    int hashIndex = hash(key);
    int originalIndex = hashIndex;

    /* recorre el array hasta que encuentra una casilla vacía */
    while(hashTable[hashIndex] != NULL) {
      if(strcmp(hashTable[hashIndex].key, key) == 0) {
         struct Item* temp = hashArray[hashIndex];

         /* pone a null el espacio correspondiente de la tabla */
         hashArray[hashIndex] = NULL;

         /* devuelve el elemento eliminado */
         return temp;
      }
      /* avanza en la tabla */
      hashIndex++;
      hashIndex = hashIndex%SIZE;

      if(hashIndex == originalIndex) /* si ha dado la vuelta sin encontrarlo */
          break;
    }

    return NULL;
}
