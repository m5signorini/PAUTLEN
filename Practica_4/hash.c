#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "hash.h"



/* Obtiene el código hash a partir del identificador utilizando
    el algoritmo djb2 para hashear cadenas de caracteres*/
int hash(char* key) {
    int hash = 5381;
    int c;

    while (c = *key++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash;
}


HashTable* hash_table_create(uint length) {
    if (length == 0) return NULL;

    HashTable* ht = NULL;
    Item** items = NULL;
    int i = 0;

    ht = (HashTable*)malloc(sizeof(HashTable));
    if (ht == NULL) {
        /* Caso de error: quiza usar perror */
        return NULL;
    }
    items = (Item**)malloc(sizeof(Item*)*length);
    if (items == NULL) {
        free(ht);
        return NULL;
    }
    for (i=0; i<length; i++) {
        items[i] = NULL;
    }

    ht->items = items;
    ht->length = length;
    return ht;
}


void hash_table_destroy(HashTable* ht) {
    if (ht == NULL) return;
    /* Limpiar datos internos */
    int i = 0;
    for (i=0; i<ht->length; i++) {
        if(ht->items[i] != NULL) {
            free(ht->items[i]);
        }
    }
    free(ht->items);
    free(ht);
    return;
}


/* Busca un elemento de identificador key en la tabla.
    Devuelve el elemento si está presente, NULL en caso contrario */
void* hash_table_search(HashTable* ht, char* key) {
    if(ht == NULL || key == NULL) return NULL;
    
    int hashIndex = hash(key) % ht->length;   /* obtiene el hash del identificador */
    int originalIndex = hashIndex;
    Item** items = ht->items;

    /* recorre la tabla empezando por el índice dado por el hash */
    while(items[hashIndex] != NULL) {
        if(strcmp(items[hashIndex]->key, key) == 0)
            return items[hashIndex]->data;   /* si encuentra el elemento, lo retorna */

        /* avanza en la tabla */
        hashIndex++;
        hashIndex = hashIndex % ht->length;

        if(hashIndex == originalIndex) /* si ha dado la vuelta sin encontrarlo */
            break;  /* deja de buscar para devolver NULL */
    }

    return NULL;
}

/* Inserta el elemento con identificador key y datos data en la tabla
    Devuelve 1 si no se ha podido insertar, 0 en caso contrario */
int hash_table_insert(HashTable* ht, char* key, void* data) {
    if(ht == NULL || key == NULL || data == NULL) return 1;

    /* obtiene el hash del nuevo elemento */
    int hashIndex = hash(key) % ht->length;
    int originalIndex = hashIndex;

    /* recorre el array hasta que encuentra una casilla vacía */
    while(ht->items[hashIndex] != NULL) {
        /* avanza en la tabla */
        hashIndex++;
        hashIndex = hashIndex % ht->length;

        if(hashIndex == originalIndex) /* si ha dado la vuelta sin encontrar hueco */
            return 1;
    }

    /* crea el nuevo elemento */
    /* asigna el nuevo elemento en el sitio encontrado */
    /* el contenido data se espera ya reservado */
    Item* new_item = NULL;
    new_item = (Item*)malloc(sizeof(Item));
    if (new_item == NULL) {
        return 1;
    }
    /* settear datos */
    new_item->data = data;
    memset(new_item->key, 0, KEY_LEN);
    strncpy(new_item->key, key, KEY_LEN-1);
    /* insertar en la lista */
    ht->items[hashIndex] = new_item;
    return 0;
}

/* Elimina el elemento item de la tabla.
    Devuelve ese elemento, o NULL si no se ha encontrado */
void* hash_table_delete(HashTable* ht, char* key) {
    if( ht == NULL || key == NULL) return NULL;

    /* obtiene el hash del elemento a eliminar */
    int hashIndex = hash(key) % ht->length;
    int originalIndex = hashIndex;
    void* result = NULL;
    Item** items = ht->items;

    /* recorre el array hasta que encuentra una casilla vacía */
    while(items[hashIndex] != NULL) {
        if(strcmp(items[hashIndex]->key, key) == 0) {
            result = items[hashIndex]->data;

            /* pone a null el espacio correspondiente de la tabla */
            free(items[hashIndex]);
            items[hashIndex] = NULL;

            /* devuelve el elemento eliminado */
            return result;
        }
        /* avanza en la tabla */
        hashIndex++;
        hashIndex = hashIndex % ht->length;

        if(hashIndex == originalIndex) /* si ha dado la vuelta sin encontrarlo */
            break;
    }

    return NULL;
}
