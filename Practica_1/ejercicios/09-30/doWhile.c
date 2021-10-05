#include <stdlib.h>
#include <string.h>
#include "doWhile.h"

/*
int getiqueta = -1;
int cima_etiquetas = -1;
int etiquetas[MAX_ETIQUETAS];
*/

void escribir_cabecera_bss(FILE* fpasm){
  if (fpasm == NULL) return;
  fprintf(fpasm, "segment .bss\n");
  fprintf(fpasm, "  __esp resd 1\n");

  return;
}

void escribir_subseccion_data(FILE* fpasm) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "segment .data\n");

  fprintf(fpasm, "_div_error db \"Error: division por cero\"\n");
  /* completar con futuros mensajes de error que surjan */
  return;
}

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
void declarar_variable(FILE* fpasm, char * nombre, int tipo, int tamano){
  char new_name[MAX_VARNAME_LENGTH] = "_";

  if (fpasm == NULL) return;
  
  strcat(new_name, nombre);
  
  fprintf(fpasm, "%s resd %d\n",new_name, tamano);
  return;
}

void escribir_segmento_codigo(FILE* fpasm) {
  if(fpasm == NULL) return;
  fprintf(fpasm, "segment .text\n");
  fprintf(fpasm, "global main\n");
  fprintf(fpasm, "extern scan_int, scan_boolean\n");
  fprintf(fpasm, "extern print_int, print_boolean, print_string, print_blank, print_endofline\n");
  return;
}

void escribir_inicio_main(FILE* fpasm) {
  if (fpasm == NULL) return;
  fprintf(fpasm, "main:\n");
  fprintf(fpasm, "; guarda el puntero de pila en su variable\n");
  fprintf(fpasm, "mov esp, [__esp]\n");
  return;
}

void escribir_fin(FILE* fpasm) {
  if(fpasm == NULL) return;
  // Etiquetas para salir en caso de error de ejecución

  /* FIN CORRECTO */
  fprintf(fpasm, "jmp near fin\n");
  /* DIVISION POR CERO : error_div_cero */
  fprintf(fpasm, "error_div_cero:\n");
  fprintf(fpasm, "  push dword _div_error\n");  // Guardamos direccion del mensaje a imprimir
  fprintf(fpasm, "  call print_string\n");
  fprintf(fpasm, "  add esp, 4\n");             // Restauramos valor de esp antes de añadir el mensaje
  fprintf(fpasm, "  call print_endofline\n");
  fprintf(fpasm, "  jmp near fin\n");

  // Recuperar puntero de pila a partir de __esp
  fprintf(fpasm, "fin:\n");
  fprintf(fpasm, "  mov esp, [__esp]\n");
  fprintf(fpasm, "  ret\n");                    // Escribir ret final
  return;
}

void escribir_operando(FILE* fpasm, char* nombre, int es_variable) {
  if(fpasm == NULL) return;
  // Si es variable, lo obtenemos a partir del nombre
  if(es_variable == 1) {
    fprintf(fpasm, "push dword [_%s]\n", nombre);
  }
  else {
    // Notese que por ahora  si no es variable lo guardamos en un registro temporal
    fprintf(fpasm, "mov edx, %s\n", nombre);
    fprintf(fpasm, "push dword edx\n");
  }
  fprintf(fpasm, "\n");
  fprintf(fpasm, "\n");
}


void escribir(FILE* fpasm, int es_variable, int tipo){
  if (fpasm == NULL) return;

  fprintf(fpasm, "pop dword edx\n");

  /* introduce la variable o el dato en la pila */
  if (es_variable) {
    fprintf(fpasm, "; introduce la variable en la pila\n");
    fprintf(fpasm, "push dword [edx]\n");
  } else {
    fprintf(fpasm, "; introduce el dato en la pila\n");
    fprintf(fpasm, "push dword edx\n");
  }

  /* llama a la funcion de imprimir correspondiente */
  if (tipo == ENTERO) {
    fprintf(fpasm, "call print_int\n");
  } else {
    fprintf(fpasm, "call print_boolean\n");
  }

  /* restaura el puntero de pila */
  fprintf(fpasm, "add esp, 4\n");

  return;
}


void sumar(FILE* fpasm, int es_variable_1, int es_variable_2){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "pop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm,"pop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "mov dword eax, [eax]\n");

  }

  fprintf(fpasm, "; realizar la suma y dejar el resultado en eax \n");
  fprintf(fpasm, "add eax, edx\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "push dword eax\n");

  return;
}

void dowhile_inicio(FILE * fpasm, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "do_while_%d:\n", etiqueta);

  return;
}

void dowhile_exp_pila (FILE * fpasm, int exp_es_variable, int etiqueta){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; obtenemos el valor de la expresion del bucle\n");
  fprintf(fpasm, "pop dword eax\n");

  if (exp_es_variable == 1){
    fprintf(fpasm, "mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "cmp eax, 0\n");
  fprintf(fpasm, "jne do_while_%d\n", etiqueta);

  fprintf(fpasm, "jmp fin_do_while_%d\n", etiqueta);

  return;
}


void dowhile_fin( FILE * fpasm, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "fin_do_while_%d:\n", etiqueta);

  return;
}


/*
- Genera el código para asignar valor a la variable de nombre nombre.
- Se toma el valor de la cima de la pila.
- El último argumento es el que indica si lo que hay en la cima de la pila es
una referencia (1) o ya un valor explícito (0).
*/
void asignar(FILE* fpasm, char* nombre, int es_variable){
  char new_name[MAX_VARNAME_LENGTH] = "_";

  if (fpasm == NULL) return;
  
  strcat(new_name, nombre);

  fprintf(fpasm, "; obtenemos cima de la pila\n");
  fprintf(fpasm, "pop dword edx\n");

  if (es_variable == 1){
    fprintf(fpasm, "mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "mov dword [%s], edx\n", new_name);

  return;
}

/*
Esta funcion tiene como argumento si los elementos a comparar son o
no variables. El resultado de las operaciones, que siempre será un booleano (“1”
si se cumple la comparación y “0” si no se cumple), se deja en la pila como en el
resto de operaciones.

 En este ejericio no se permiten do-while anidados.
*/
void menor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "pop dword edx\n");
  if (es_variable2 == 1){
    fprintf(fpasm, "mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm,"pop dword eax\n");
  if (es_variable1 == 1){
    fprintf(fpasm, "mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "cmp eax, edx\n");
  fprintf(fpasm, "jl menor_%d\n", etiqueta);
  
  fprintf(fpasm, "; si no se cumple la comparacion\n");
  fprintf(fpasm, "push dword 0\n");
  fprintf(fpasm, "jmp fin_menor_%d\n", etiqueta);

  fprintf(fpasm, "; si se cumple la comparacion\n");
  fprintf(fpasm, "menor_%d:\n", etiqueta);
  fprintf(fpasm, "push dword 1\n");
  
  fprintf(fpasm, "fin_menor_%d:", etiqueta);
}
