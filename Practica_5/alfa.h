
#ifndef _ALFA_H

/* Tenemos ya encuenta el EOS en la longitud */
#define NOMBRE_LEN 100

/*
Observacion:
Los atributos siguientes utilizan las
defeniciones de macros situadas en hash.h
para los tipos INT y BOOLEAN
*/

struct _info_atributos {
	char nombre[NOMBRE_LEN];
    int tipo;
    int es_direccion;
	int valor_entero;
    int etiqueta;
};
typedef struct _info_atributos info_atributos;

#endif