/*##########################*/
/* Autores:
  Cesar Ramirez Martinez
  Martin Sanchez Signorini
  Pablo Ruiz Revilla
*/
/*##########################*/
#include <stdlib.h>
#include <string.h>
#include "generacion.h"

/****************************************************
  ESCRITURA DE SEGMENTOS Y DECLARACIONES INICIALES
*****************************************************/

void escribir_cabecera_bss(FILE* fpasm){
  if (fpasm == NULL) return;
  fprintf(fpasm, "\n");
  fprintf(fpasm, "segment .bss\n");
  fprintf(fpasm, "  __esp resd 1\n");
  return;
}

void escribir_subseccion_data(FILE* fpasm) {
  if (fpasm == NULL) return;
  fprintf(fpasm, "\n");
  fprintf(fpasm, "segment .data\n");
  fprintf(fpasm, "  msg_div_error db \"Error: division por cero\"\n");
  fprintf(fpasm, "  msg_index_range_error db \"Error: Indice fuera de rango\"\n");
  /* completar con futuros mensajes de error que surjan */
  return;
}

void declarar_variable(FILE* fpasm, char * nombre, int tipo, int tamano){
  if (fpasm == NULL) return;
  fprintf(fpasm, "  _%s resd %d\n",nombre, tamano);
  return;
}

void escribir_segmento_codigo(FILE* fpasm) {
  if(fpasm == NULL) return;
  fprintf(fpasm, "\n");
  fprintf(fpasm, "segment .text\n");
  fprintf(fpasm, "  global main\n");
  fprintf(fpasm, "  extern scan_int, scan_boolean\n");
  fprintf(fpasm, "  extern print_int, print_boolean, print_string, print_blank, print_endofline\n");
  return;
}

void escribir_inicio_main(FILE* fpasm) {
  if (fpasm == NULL) return;
  fprintf(fpasm, "\n");
  fprintf(fpasm, "main:\n");
  fprintf(fpasm, "; guarda el puntero de pila en su variable\n");
  fprintf(fpasm, "  mov [__esp], esp\n");
  return;
}

void escribir_fin(FILE* fpasm) {
  if(fpasm == NULL) return;
  // Etiquetas para salir en caso de error de ejecución

  /* FIN CORRECTO */
  fprintf(fpasm, "  jmp near fin\n");
  fprintf(fpasm, "\n");
  /* DIVISION POR CERO : error_div_cero */
  fprintf(fpasm, "error_div_cero:\n");
  fprintf(fpasm, "  push dword msg_div_error\n");  // Guardamos direccion del mensaje a imprimir
  fprintf(fpasm, "  call print_string\n");
  fprintf(fpasm, "  add esp, 4\n");             // Restauramos valor de esp antes de añadir el mensaje
  fprintf(fpasm, "  call print_endofline\n");
  fprintf(fpasm, "  jmp near fin\n");

  /* Índice fuera de rango: fin_indice_fuera_rango */
  fprintf(fpasm, "fin_indice_fuera_rango\n");
  fprintf(fpasm, " push dword msg_index_range_error\n"); //Guardamos direccion del mensaje a imprimir
  fprintf(fpasm, "  call print_string\n");
  fprintf(fpasm, "  add esp, 4\n");             // Restauramos valor de esp antes de añadir el mensaje
  fprintf(fpasm, "  call print_endofline\n");
  fprintf(fpasm, "  jmp near fin\n");

  // Recuperar puntero de pila a partir de __esp
  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin:\n");
  fprintf(fpasm, "  mov esp, [__esp]\n");
  fprintf(fpasm, "  ret\n");                    // Escribir ret final
  return;
}

/****************************************************
  ASIGNACIONES Y ESCRITURA EN PILA PARA OPERANDOS
*****************************************************/

void escribir_operando(FILE* fpasm, char* nombre, int es_variable) {
  if(fpasm == NULL) return;

  // Si es variable, lo obtenemos a partir del nombre
  if(es_variable == 1) {
    fprintf(fpasm, "  push dword _%s\n", nombre);
  }
  else {
    // Notese que por ahora  si no es variable lo guardamos en un registro temporal
    fprintf(fpasm, "  mov edx, %s\n", nombre);
    fprintf(fpasm, "  push dword edx\n");
  }
  return;
}


void asignar(FILE* fpasm, char* nombre, int es_variable){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; obtenemos cima de la pila y asignamos la variable\n");
  fprintf(fpasm, "  pop dword edx\n");

  if (es_variable == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "  mov dword [_%s], edx\n", nombre);
  return;
}

/****************************************************
  OPERACIONES ARITMETICO-LOGICAS BINARIAS
*****************************************************/

void sumar(FILE* fpasm, int es_variable_1, int es_variable_2){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "; realizar la suma y dejar el resultado en eax \n");
  fprintf(fpasm, "  add eax, edx\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");

  return;
}


void restar(FILE* fpasm, int es_variable_1, int es_variable_2){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "; realizar la resta y dejar el resultado en eax \n");
  fprintf(fpasm, "  sub eax, edx\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");

  return;
}


void multiplicar(FILE* fpasm, int es_variable_1, int es_variable_2) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "; realizar la multiplicación y dejar el resultado en eax \n");
  fprintf(fpasm, "  imul edx\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");

  return;
}


void dividir(FILE* fpasm, int es_variable_1, int es_variable_2){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando (divisor) en edx\n");
  fprintf(fpasm, "  pop dword ecx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "  mov dword ecx, [ecx]\n");
  }

  fprintf(fpasm, "; comprobar si division por cero\n");
  fprintf(fpasm, "  cmp ecx, 0\n");
  fprintf(fpasm, "  je error_div_cero\n");


  fprintf(fpasm, "; cargar el primer operando (dividendo) en eax y extenderlo a edx:eax (usando edx = 0)\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }
  fprintf(fpasm, "  mov edx, 0\n");

  fprintf(fpasm, "; realizar la division y dejar el resultado en eax \n");
  fprintf(fpasm, "  idiv ecx\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");

  return;
}


void o(FILE* fpasm, int es_variable_1, int es_variable_2) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "; realizar el 'or' y dejar el resultado en eax \n");
  fprintf(fpasm, "  or eax, edx\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");

  return;
}

void y(FILE* fpasm, int es_variable_1, int es_variable_2) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "; realizar el 'and' y dejar el resultado en eax \n");
  fprintf(fpasm, "  and eax, edx\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");

  return;
}

void cambiar_signo(FILE* fpasm, int es_variable) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "; realizar el cambio de signo y dejar el resultado en eax \n");
  fprintf(fpasm, "  neg eax\n");
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");
  return;
}

void no(FILE* fpasm, int es_variable, int cuantos_no){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }
  fprintf(fpasm, "; miramos si la cima de la pila es un 0 o un 1\n");
  fprintf(fpasm, "  cmp eax, 0\n");
  fprintf(fpasm, "  je no_%d\n", cuantos_no);
  fprintf(fpasm, "; si es un 1 ponemos un 0\n");
  fprintf(fpasm, "  mov eax, 0\n");
  fprintf(fpasm, "  je fin_no_%d\n", cuantos_no);
  fprintf(fpasm, "\n");
  fprintf(fpasm, "no_%d:\n", cuantos_no);
  fprintf(fpasm, "; si es un 0 ponemos un 1\n");
  fprintf(fpasm, "  mov eax, 1\n");
  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_no_%d:\n", cuantos_no);
  fprintf(fpasm, "; apilar el resultado\n");
  fprintf(fpasm, "  push dword eax\n");
  return;
}

/****************************************************
  OPERACIONES COMPARATIVAS
*****************************************************/

void menor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, edx\n");
  fprintf(fpasm, "  jl menor_%d\n", etiqueta);

  fprintf(fpasm, "; si no se cumple la comparacion\n");
  fprintf(fpasm, "  push dword 0\n");
  fprintf(fpasm, "  jmp fin_menor_%d\n", etiqueta);

  fprintf(fpasm, "; si se cumple la comparacion\n");
  fprintf(fpasm, "\n");
  fprintf(fpasm, "menor_%d:\n", etiqueta);
  fprintf(fpasm, "  push dword 1\n");

  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_menor_%d:", etiqueta);
  return;
}


void igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, edx\n");
  fprintf(fpasm, "  je igual_%d\n", etiqueta);

  fprintf(fpasm, "; si no se cumple la comparacion\n");
  fprintf(fpasm, "  push dword 0\n");
  fprintf(fpasm, "  jmp fin_igual_%d\n", etiqueta);

  fprintf(fpasm, "; si se cumple la comparacion\n");
  fprintf(fpasm, "\n");
  fprintf(fpasm, "igual_%d:\n", etiqueta);
  fprintf(fpasm, "  push dword 1\n");

  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_igual_%d:", etiqueta);
  return;
}


void distinto(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, edx\n");
  fprintf(fpasm, "  jne distinto_%d\n", etiqueta);

  fprintf(fpasm, "; si no se cumple la comparacion\n");
  fprintf(fpasm, "  push dword 0\n");
  fprintf(fpasm, "  jmp fin_distinto_%d\n", etiqueta);

  fprintf(fpasm, "; si se cumple la comparacion\n");
  fprintf(fpasm, "\n");
  fprintf(fpasm, "distinto_%d:\n", etiqueta);
  fprintf(fpasm, "  push dword 1\n");

  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_distinto_%d:", etiqueta);
  return;
}


void menor_igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, edx\n");
  fprintf(fpasm, "  jle menor_igual_%d\n", etiqueta);

  fprintf(fpasm, "; si no se cumple la comparacion\n");
  fprintf(fpasm, "  push dword 0\n");
  fprintf(fpasm, "  jmp fin_menor_igual_%d\n", etiqueta);

  fprintf(fpasm, "; si se cumple la comparacion\n");
  fprintf(fpasm, "\n");
  fprintf(fpasm, "menor_igual_%d:\n", etiqueta);
  fprintf(fpasm, "  push dword 1\n");

  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_menor_igual_%d:", etiqueta);
  return;
}


void mayor_igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, edx\n");
  fprintf(fpasm, "  jge mayor_igual_%d\n", etiqueta);

  fprintf(fpasm, "; si no se cumple la comparacion\n");
  fprintf(fpasm, "  push dword 0\n");
  fprintf(fpasm, "  jmp fin_mayor_igual_%d\n", etiqueta);

  fprintf(fpasm, "; si se cumple la comparacion\n");
  fprintf(fpasm, "\n");
  fprintf(fpasm, "mayor_igual_%d:\n", etiqueta);
  fprintf(fpasm, "  push dword 1\n");

  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_mayor_igual_%d:", etiqueta);
  return;
}


void mayor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "; cargar el segundo operando en edx\n");
  fprintf(fpasm, "  pop dword edx\n");
  if (es_variable2 == 1){
    fprintf(fpasm, "  mov dword edx, [edx]\n");
  }

  fprintf(fpasm, "; cargar el primer operando en eax\n");
  fprintf(fpasm, "  pop dword eax\n");
  if (es_variable1 == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, edx\n");
  fprintf(fpasm, "  jg mayor_%d\n", etiqueta);

  fprintf(fpasm, "; si no se cumple la comparacion\n");
  fprintf(fpasm, "  push dword 0\n");
  fprintf(fpasm, "  jmp fin_mayor_%d\n", etiqueta);

  fprintf(fpasm, "; si se cumple la comparacion\n");
  fprintf(fpasm, "\n");
  fprintf(fpasm, "mayor_%d:\n", etiqueta);
  fprintf(fpasm, "  push dword 1\n");

  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_mayor_%d:", etiqueta);
  return;
}

/****************************************************
  OPERACIONES DE ENTRADA Y SALIDA
*****************************************************/

void escribir(FILE* fpasm, int es_variable, int tipo){
  if (fpasm == NULL) return;

  // introduce la variable o el dato en la pila
  if (es_variable == 1) {
    fprintf(fpasm, "; introduce la variable en la pila\n");
    fprintf(fpasm, "  pop dword edx\n");
    fprintf(fpasm, "  push dword [edx]\n");
  }
  fprintf(fpasm, "; si no es variable, el dato ya viene introducido en la pila\n");

  // llama a la funcion de imprimir correspondiente
  if (tipo == ENTERO) {
    fprintf(fpasm, "  call print_int\n");
  } else {
    fprintf(fpasm, "  call print_boolean\n");
  }

  // restaura el puntero de pila (como hacer pop)
  fprintf(fpasm, "  add esp, 4\n");
  fprintf(fpasm, "  call print_endofline\n");
  return;
}


void leer(FILE* fpasm, char* nombre, int tipo) {
  if (fpasm == NULL) return;

  // introduce la dirección donde se lee en la pila
  fprintf(fpasm, " push dword _%s\n", nombre);

  // llama a la funcion de leer correspondiente
  if (tipo == ENTERO) {
    fprintf(fpasm, "  call scan_int\n");
  } else {
    fprintf(fpasm, "  call scan_boolean\n");
  }

  // restaura el puntero de pila
  fprintf(fpasm, "  add esp, 4\n");
  return;
}

/****************************************************
  OPERACIONES DE CONTROL DE FLUJO Y BUCLES
*****************************************************/

void while_inicio(FILE * fpasm, int etiqueta) {
  if (fpasm == NULL) return;

  fprintf(fpasm, "\n");
  fprintf(fpasm, "while_%d:\n", etiqueta);
  return;
}


void while_exp_pila (FILE * fpasm, int exp_es_variable, int etiqueta){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; obtenemos el valor de la expresion del bucle\n");
  fprintf(fpasm, "  pop dword eax\n");

  if (exp_es_variable == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, 0\n");
  fprintf(fpasm, "  je fin_while_%d\n", etiqueta);
  return;
}


void while_fin( FILE * fpasm, int etiqueta) {
  if (fpasm == NULL) return;
  // Notese: A diferencia del do while, el while se comprueba la expresion
  // antes de ejecutar el codigo interno, y despues de este es cuando
  // se salta al comienzo del bucle
  fprintf(fpasm, "  jmp while_%d\n", etiqueta);
  fprintf(fpasm, "\n");
  fprintf(fpasm, "fin_while_%d:\n", etiqueta);
  return;
}


void ifthenelse_inicio(FILE * fpasm, int exp_es_variable, int etiqueta){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; obtenemos el valor de la expresion del if\n");
  fprintf(fpasm, "  pop dword eax\n");

  if (exp_es_variable == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, 0\n");
  fprintf(fpasm, "  je else_%d\n", etiqueta);
  return;
}

void ifthen_inicio(FILE * fpasm, int exp_es_variable, int etiqueta);
{
  if (fpasm == NULL) return;

  fprintf(fpasm, "; obtenemos el valor de la expresion del if\n");
  fprintf(fpasm, "  pop dword eax\n");

  if (exp_es_variable == 1){
    fprintf(fpasm, "  mov dword eax, [eax]\n");
  }

  fprintf(fpasm, "  cmp eax, 0\n");
  fprintf(fpasm, "  je fin_if_%d\n", etiqueta);
  return;
}

void ifthen_fin(FILE * fpasm, int etiqueta){
    if (fpasm == NULL) return;

    fprintf(fpasm, "fin_if_%d:\n", etiqueta);
    return;
}


void ifthenelse_fin_then( FILE * fpasm, int etiqueta){
  if (fpasm == NULL) return;

  fprintf(fpasm, "; para saltarnos el else\n");
  fprintf(fpasm, "  je fin_if_else_%d\n", etiqueta);
  fprintf(fpasm, "else_%d:\n", etiqueta);
  return;
}

void ifthenelse_fin( FILE * fpasm, int etiqueta){
  if (fpasm == NULL) return;

  fprintf(fpasm, "fin_if_else_%d:\n", etiqueta);
  return;
}



void escribir_elemento_vector(FILE * fpasm,char * nombre_vector,
  int tam_max, int exp_es_direccion) {

  if (fpasm == NULL) return;

  /* sacamos de la pila el valor del índice */
  fprintf(fpasm, "pop dword eax\n");

  /* si es una dirección, obtenemos el índice de memoria */
  if (exp_es_direccion == 1) {
    fprintf(fpasm, "mov dword eax, [eax]\n");
  }

  /* Control de errores */
  /* Si el índice es menor que 0, termina el programa */
  fprintf(fpasm, "cmp eax, 0\n");
  fprintf(fpasm, "jl near fin_indice_fuera_rango\n");
  /* Si el índice es mayor que el máximo permitido, termina el programa */
  fprintf(fpasm, "cmp eax, tam_max-1\n");
  fprintf(fpasm, "jg near fin_indice_fuera_rango\n");

  /* Calcula la dirección efectiva del elemento indexado */
  // UNA OPCIÓN ES CALCULAR CON lea LA DIRECCIÓN EFECTIVA DEL ELEMENTO INDEXADO TRAS CALCULARLA
  // DESPLAZANDO DESDE EL INICIO DEL VECTOR EL VALOR DEL INDICE
  fprintf(fpasm, "mov dword edx, _%s\n", nombre_vector);
  fprintf(fpasm, "lea eax, [edx + eax*4]\n"); /* dirección del elemento indexado en eax */
  fprintf(fpasm, "push dword eax\n"); /* dirección del elemento indexado en la cima de la pila */
}


/****************************************************
  CREACION DE FUNCIONES
*****************************************************/

void declararFuncion(FILE * fd_asm, char * nombre_funcion, int num_var_loc) {
  if (fd_asm == NULL) return;
  // Escribir etiqueta
  fprintf(fd_asm, "\n");
  fprintf(fd_asm, "_%s:\n", nombre_funcion);

  // Preservar registros ebp y esp
  fprintf(fd_asm, "  push ebp\n");
  fprintf(fd_asm, "  mov ebp, esp\n");

  // Reservar espacio para variables locales de la funcion en la pila
  fprintf(fd_asm, "  sub esp, %d", 4*num_var_loc);
  return;
}


void retornarFuncion(FILE * fd_asm, int es_variable) {
  if(fd_asm == NULL) return;

  /* Obtiene el retorno de la función */
  fprintf(fd_asm, "  pop eax\n");

  /* dejamos el retorno en eax en caso de que lo obtenido de la pila sea una direccion */
  if (es_variable == 1) {
    fprintf(fd_asm, "  mov dword eax, [eax]\n");
  }

  fprintf(fd_asm, "  mov esp,ebp\n"); /* restaurar el puntero de pila */
  fprintf(fd_asm, "  pop ebp\n"); /* sacar de la pila ebp */
  fprintf(fd_asm, "  ret\n"); /* vuelve al programa llamante y saca de la pila la dir de retorno */
  return;
}


void escribirParametro(FILE* fpasm, int pos_parametro, int num_total_parametros) {
  if(fpasm == NULL) return;
  // Para obtener los parametros se hace uso del registro ebp, el cual
  // apunta al ebp original, y ademas: ebp+4 = dir. ret. ; ebp+8 = primer argumento
  // Para colocar el n-esimo parametro en la pila, calculamos:
  int d_ebp;
  d_ebp = 4*( 1 + (num_total_parametros - pos_parametro));

  // Cargamos el parametro pos_parametro-esimo en la pila
  fprintf(fpasm, "  lea eax, [ebp + %d]\n", d_ebp);
  fprintf(fpasm, "  push dword eax");
  return;
}

void escribirVariableLocal(FILE* fpasm, int posicion_variable_local) {
  if(fpasm == NULL) return;

  int d_ebp;
  d_ebp = 4*posicion_variable_local;

  fprintf(fpasm, "  lea eax, [ebp - %d]\n", d_ebp);
  fprintf(fpasm, "  push dword eax")

  return;
}

void asignarDestinoEnPila(FILE* fpasm, int es_variable) {
  if (fpasm == NULL) return;
  /* Obtiene la dirección donde se tiene que asignar */
  fprintf(fpasm, "pop dword ebx\n");
  /* Obtiene el valor a asignar */
  fprintf(fpasm, "pop dword eax\n");
  if (es_variable == 1) {
    fprintf(fpasm, "mov dword eax, [eax]\n");
  }
  /* Realiza la asignación */
  fprintf(fpasm, "mov dword [ebx], eax\n");
}
