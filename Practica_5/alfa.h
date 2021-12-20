
#ifndef _ALFA_H
#include "types.h"

#define ERROR_DEC_DUPLICADA             1
#define ERROR_ACCESO_VAR_NO_DEC         2
#define ERROR_OP_ARIT_CON_BOOL          3
#define ERROR_OP_LOG_CON_INT            4
#define ERROR_COMP_CON_BOOL             5
#define ERROR_COND_CON_INT              6
#define ERROR_BUCLE_CON_INT             7
#define ERROR_NUM_PARAM                 8
#define ERROR_ASIGNACION                9
#define ERROR_TAM_VECTOR                10
#define ERROR_INDEXACION                11
#define ERROR_INDICE_INDEXACION         12
#define ERROR_FUNCION_SIN_RETORNO       13
#define ERROR_RETORNO_FUERA_FUNCION     14
#define ERROR_FUNCION_EN_PARAM          15
#define ERROR_VAR_LOCAL                 16
#define ERROR_AMBITO_ERRONEO            17
#define ERROR_AMBITO_NO_ENCONTRADO      18
#define ERROR_FUNCION_NO_GLOBAL         19
#define ERROR_AMBITO_NO_CERRADO         20

#define ERROR_RESERVA_MEMORIA           100
#define ERROR_ES_FUNCION                101
#define ERROR_NO_ES_FUNCION             102
#define ERROR_NO_ESCALAR                103
#define ERROR_TIPO_RETORNO              104
#define ERROR_INESPERADO                404

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