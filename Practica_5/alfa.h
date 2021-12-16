
#ifndef _ALFA_H

#define NOMBRE_LEN 100

struct _info_atributos {
	char nombre[NOMBRE_LEN];
    int tipo;
    int es_direccion;
	int valor_entero;
    int etiqueta;
};
typedef struct _info_atributos info_atributos;

#endif