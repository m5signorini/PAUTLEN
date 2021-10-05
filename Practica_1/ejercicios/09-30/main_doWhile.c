#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "doWhile.h"

int main(int argc, char **argv) {
  FILE *salida;

  if (argc != 2)
  {
    fprintf(stdout, "ERROR POCOS ARGUMENTOS\n");
    return -1;
  }

  salida = fopen(argv[1], "w");
  
  

  int etiqueta = 0;

  escribir_subseccion_data(salida);

  escribir_cabecera_bss(salida);
  
  declarar_variable(salida, "x", ENTERO, 1);
  
  declarar_variable(salida, "y", ENTERO, 1);
  
  escribir_segmento_codigo(salida);

  escribir_inicio_main(salida);
  
  /* x=0; */

  escribir_operando(salida, "0", 0);

  asignar(salida, "x", 0);

  /* y=2; */

  escribir_operando(salida, "0", 0);

  asignar(salida, "y", 0);

  etiqueta++;

  dowhile_inicio(salida, etiqueta);

  escribir_operando(salida, "x", 1);

  escribir_operando(salida, "y", 1);

  sumar(salida, 1, 1);

  asignar(salida, "x", 0);

  escribir_operando(salida, "x", 1);

  escribir(salida, 1, ENTERO);

  escribir_operando(salida, "x", 1);

  menor(salida, 1, 0, etiqueta);

  dowhile_exp_pila(salida, 0, etiqueta);

  dowhile_fin(salida, etiqueta);

  escribir_fin(salida);

  fclose(salida);

  return 0;
}
