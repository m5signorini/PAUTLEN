#ifndef DOWHILE_H
#define DOWHILE_H
#include <stdio.h>

/* Declaraciones de tipos de datos del compilador */
#define ENTERO 0
#define BOOLEANO 1

/* Longitud máxima del nombre de una variable */
#define MAX_VARNAME_LENGTH 4095

/* OBSERVACIÓN GENERAL A TODAS LAS FUNCIONES:
Todas ellas escriben el código NASM a un FILE* proporcionado como primer
argumento.
*/

void escribir_cabecera_bss(FILE* fpasm);
/*
Código para el principio de la sección .bss.
Con seguridad sabes que deberás reservar una variable entera para guardar el
puntero de pila extendido (esp). Se te sugiere el nombre __esp para esta variable.
*/

void escribir_subseccion_data(FILE* fpasm);
/*
Declaración (con directiva db) de las variables que contienen el texto de los
mensajes para la identificación de errores en tiempo de ejecución.
En este punto, al menos, debes ser capaz de detectar la división por 0.
*/

void declarar_variable(FILE* fpasm, char * nombre, int tipo, int tamano);
/*
Para ser invocada en la sección .bss cada vez que se quiera declarar una
variable:
- El argumento nombre es el de la variable.
- tipo puede ser ENTERO o BOOLEANO (observa la declaración de las constantes
del principio del fichero).
- Esta misma función se invocará cuando en el compilador se declaren
vectores, por eso se adjunta un argumento final (tamano) que para esta
primera práctica siempre recibirá el valor 1.
*/

void escribir_segmento_codigo(FILE* fpasm);
/*
Para escribir el comienzo del segmento .text, básicamente se indica que se
exporta la etiqueta main y que se usarán las funciones declaradas en la librería
alfalib.o
*/

void escribir_inicio_main(FILE* fpasm);
/*
En este punto se debe escribir, al menos, la etiqueta main
*/

void escribir_fin(FILE* fpasm);
/*
Al final del programa se escribe:
- El código NASM para salir de manera controlada cuando en este ejercicio opcional no es necesario
 tener en cuenta el control de errores
*/

/*
Se necesita saber el tipo de datos que se va a procesar (ENTERO o BOOLEANO) ya
que hay diferentes funciones de librería para la lectura (idem. escritura) de cada
tipo.
Se deben insertar en la pila los argumentos necesarios, realizar la llamada
(call) a la función de librería correspondiente y limpiar la pila.
*/
void escribir(FILE* fpasm, int es_variable, int tipo);


void sumar(FILE* fpasm, int es_variable_1, int es_variable_2);
/*
- Se extrae de la pila los operandos
- Se realiza la operación
- Se guarda el resultado en la pila
        Los dos últimos argumentos indican respectivamente si lo que hay en la pila es
        una referencia a un valor o un valor explícito.
*/

void dowhile_inicio(FILE * fpasm, int etiqueta);

/*
Generación de código para el inicio de una estructura do-while
Como es el inicio de uno bloque de control de flujo de programa en este ejercicio opcional no es necesario
 tener encuenta control de etiquetas para do-while anidado.

*/

void dowhile_exp_pila (FILE * fpasm, int exp_es_variable, int etiqueta);
/*
Generación de código para el momento en el que se ha generado el código de la expresión
de control del bucle
Sólo necesita usar la etiqueta adecuada, por lo que sólo se necesita que se recupere el valor
de la etiqueta que corresponde al momento actual.
exp_es_variable
Es 1 si la expresión de la condición es algo asimilable a una variable (identificador,
o elemento de vector)
Es 0 en caso contrario (constante u otro tipo de expresión)
*/


void dowhile_fin( FILE * fpasm, int etiqueta);
/*
Generación de código para el final de una estructura dowhile
Como es el fin de uno bloque de control de flujo de programa que hace uso de la etiqueta
del mismo se requiere que antes de su invocación tome el valor de la etiqueta que le toca
según se ha explicado
Y tras ser invocada debe realizar el proceso para ajustar la información de las etiquetas
puesto que se ha liberado la última de ellas.
*/

void escribir_operando(FILE* fpasm, char* nombre, int es_variable);
/*
Función que debe ser invocada cuando se sabe un operando de una operación
aritmético-lógica y se necesita introducirlo en la pila.
- nombre es la cadena de caracteres del operando tal y como debería aparecer
en el fuente NASM
- es_variable indica si este operando es una variable (como por ejemplo b1)
con un 1 u otra cosa (como por ejemplo 34) con un 0. Recuerda que en el
primer caso internamente se representará como _b1 y, sin embargo, en el
segundo se representará tal y como esté en el argumento (34).
*/


void asignar(FILE* fpasm, char* nombre, int es_variable);
/*
- Genera el código para asignar valor a la variable de nombre nombre.
- Se toma el valor de la cima de la pila.
- El último argumento es el que indica si lo que hay en la cima de la pila es
una referencia (1) o ya un valor explícito (0).
*/


/* FUNCIONES COMPARATIVAS */
/*
Esta funcion tiene como argumento si los elementos a comparar son o
no variables. El resultado de las operaciones, que siempre será un booleano (“1”
si se cumple la comparación y “0” si no se cumple), se deja en la pila como en el
resto de operaciones.

 En este ejericio no se permiten do-while anidados.
*/
void menor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta);

#endif
