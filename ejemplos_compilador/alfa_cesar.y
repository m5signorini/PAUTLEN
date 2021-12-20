/*******************************************************************************
* alfa.y fichero de especificacion para BISON para analisis semantico y sintactico
* de la gramatica alfa.
*
* Practica 5 - Compilador, Análisis Semántico
*
* @author Marina Alonso-Cortes
* @author Jorge Santisteban
* @author Maria Sarnago
*******************************************************************************/
%{
  #include <stdlib.h>
  #include <stdio.h>

  #include <string.h>

  #include "alfa.h"
  #include "tablaSimbolos.h"
  #include "hashTabla.h"
  #include "generacion.h"

  int yylex();
  void yyerror(const char *s);
  extern FILE * yyout;

  TablaSimbolos * t = NULL;
  Nodo * n = NULL;

  int categoria_actual;
  int tipo_actual;
  int clase_actual;
  int tamanio_vector_actual;
  int num_var_local_actual;
  int pos_var_local_actual;
  int num_parametros_actual;
  int pos_parametro_actual;

  /* Funciones */
  int ambito_local = 0;
  int retorna = 0;
  int retorno_tipo;
  int num_parametros_llamada_actual;

  char aux[MAX_LONG_ID];

  /* Contadores para etiquetas */
  int num_no = 0;
  int num_condicionales = 0;
  int num_bucles = 0;
  int num_cmp = 0;
  int en_explist;

  extern int error_morfologico;
  extern int yyleng;
  extern long fila, columna;
%}

%union
{
  tipo_atributos atributos;
}

/*************************** DECLARACION DE TOKENS ****************************/

%token TOK_MAIN
%token TOK_INT
%token TOK_BOOLEAN
%token TOK_ARRAY
%token TOK_FUNCTION
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_SCANF
%token TOK_PRINTF
%token TOK_RETURN
%token TOK_PUNTOYCOMA
%token TOK_COMA
%token TOK_PARENTESISIZQUIERDO
%token TOK_PARENTESISDERECHO
%token TOK_CORCHETEIZQUIERDO
%token TOK_CORCHETEDERECHO
%token TOK_LLAVEIZQUIERDA
%token TOK_LLAVEDERECHA
%token TOK_ASIGNACION
%token TOK_MAS
%token TOK_MENOS
%token TOK_DIVISION
%token TOK_ASTERISCO
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_IGUAL
%token TOK_DISTINTO
%token TOK_MENORIGUAL
%token TOK_MAYORIGUAL
%token TOK_MENOR
%token TOK_MAYOR
%token TOK_TRUE
%token TOK_FALSE
%token TOK_ERROR
%token <atributos> TOK_CONSTANTE_ENTERA
%token <atributos> TOK_IDENTIFICADOR

%type <atributos> exp
%type <atributos> fn_name
%type <atributos> fn_declaracion
%type <atributos> elemento_vector
%type <atributos> if_sentencias
%type <atributos> if_exp
%type <atributos> bucle
%type <atributos> bucle_exp
%type <atributos> bucle_inicio
%type <atributos> idf_llamada_funcion
%type <atributos> comparacion
%type <atributos> constante
%type <atributos> constante_logica
%type <atributos> constante_entera

/*************************** PRECEDENCIAS DE TOKENS ***************************/

%left TOK_ASIGNACION
%left TOK_OR /* OR tiene menor preferencia que AND */
%left TOK_AND
%left TOK_IGUAL TOK_DISTINTO
%left TOK_MENOR TOK_MAYOR TOK_MENORIGUAL TOK_MAYORIGUAL
%left TOK_MENOS TOK_MAS /* En las reglas hay que ver el caso de - x sin nada a la izquierda, porque no es lo mismo que x-y */
%left TOK_ASTERISCO TOK_DIVISION
%right TOK_NOT


/*********************************** REGLAS ***********************************/
%%
programa            : inicio_tabla TOK_MAIN TOK_LLAVEIZQUIERDA inicio_asm declaraciones inicio_codigo funciones inicio_main sentencias TOK_LLAVEDERECHA
                    { fprintf(yyout, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
                      escribir_fin(yyout);
                      tabla_cerrar(t);
                      YYACCEPT;
                    }
                    ;

inicio_tabla        : %empty{t = tabla_crear();};

inicio_asm          : %empty
                    { fprintf(yyout, "; Subseccion data\n");
                      escribir_subseccion_data(yyout);
                      fprintf(yyout, "; Subseccion .bss\n");
                      escribir_cabecera_bss(yyout);
                    }
                    ;

inicio_codigo       : %empty
                    { fprintf(yyout, "; Segmento de codigo\n");
                      escribir_segmento_codigo(yyout);
                    }
                    ;

inicio_main         : %empty
                    { fprintf(yyout, "; ------------------------------------------\n");
                      fprintf(yyout, "; PROCEDIMIENTO PRINCIPAL\n");
                      fprintf(yyout, "; ------------------------------------------\n");
                      escribir_inicio_main(yyout);
                    }
                    ;

declaraciones       : declaracion
                      {fprintf(yyout, ";R2:\t<declaraciones> ::= <declaracion>\n");}
                    | declaracion declaraciones
                      {fprintf(yyout, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");}
                    ;

declaracion         : {categoria_actual = VARIABLE;} clase identificadores TOK_PUNTOYCOMA
                      {fprintf(yyout, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");}
                    ;

clase               : clase_escalar
                    { fprintf(yyout, ";R5:\t<clase> ::= <clase_escalar>\n");
                      clase_actual = ESCALAR;
                      tamanio_vector_actual = 1;
                    }
                    | clase_vector
                    { fprintf(yyout, ";R7:\t<clase> ::= <clase_vector>\n");
                      clase_actual = VECTOR;
                    }
                    ;

clase_escalar       : tipo {fprintf(yyout, ";R9:\t<clase_escalar> ::= <tipo>\n");};

tipo                : TOK_INT
                    { fprintf(yyout, ";R10:\t<tipo> ::= int\n");
                      tipo_actual = INT;
                    }
                    | TOK_BOOLEAN
                    { fprintf(yyout, ";R11:\t<tipo> ::= boolean\n");
                      tipo_actual = BOOLEAN;
                    }
                    ;

clase_vector        : TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO TOK_CONSTANTE_ENTERA TOK_CORCHETEDERECHO
                    { fprintf(yyout, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
                      tamanio_vector_actual = $4.valor_entero;
                      if(tamanio_vector_actual < 1 || tamanio_vector_actual > MAX_TAMANIO_VECTOR){
                        printf("****Error semantico en lin %ld: El tamanyo del vector excede los limites permitidos (1,64).\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                    }
                    ;

identificadores     : identificador {fprintf(yyout, ";R18:\t<identificadores> ::= <identificador>\n");}
                    | identificador TOK_COMA identificadores {fprintf(yyout, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");}
                    ;

funciones           : funcion funciones {fprintf(yyout, ";R20:\t<funciones> ::= <funcion> <funciones>\n");}
                    | %empty {fprintf(yyout, ";R21:\t<funciones> ::=\n");}
                    ;

fn_name             : TOK_FUNCTION tipo TOK_IDENTIFICADOR
                    { fprintf(yyout, ";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");
                      if(tabla_buscar(t, $3.lexema) == NULL){
                        ambito_local = 1;
                        retorno_tipo = tipo_actual;
                        retorna = 0;
                        num_var_local_actual = 0;
                        pos_var_local_actual = 1;
                        num_parametros_actual = 0;
                        pos_parametro_actual = 0;
                        strcpy($$.lexema, $3.lexema);
                        tabla_abrir_ambito(t, $3.lexema, tipo_actual);
                      }else{
                        printf("****Error semantico en lin %ld: Declaracion duplicada.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                    }
                    ;

fn_declaracion      : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion
                    {
                      strcpy($$.lexema, $1.lexema);
                      n = tabla_buscar(t, $1.lexema);
                      n->num_parametros = num_parametros_actual;
                      declararFuncion(yyout, $1.lexema, num_var_local_actual);
                    }
                    ;

funcion             : {categoria_actual = FUNCION;} fn_declaracion sentencias TOK_LLAVEDERECHA
                    {
                      tabla_cerrar_ambito(t);
                      ambito_local = 0;
                      n = tabla_buscar(t, $2.lexema);
                      n->num_parametros = num_parametros_actual;
                      if(retorna == 0){
                        printf("****Error semantico en lin %ld: Funcion %s sin sentencia de retorno.\n", fila, $2.lexema);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        retorna = 0;
                      }
                    }
                    ;

parametros_funcion  : parametro_funcion resto_parametros
                      {fprintf(yyout, ";R23:\t<parametro_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");}
                    | %empty {fprintf(yyout, ";R24:\t<parametros_funcion> ::=\n");}
                    ;

resto_parametros    : TOK_PUNTOYCOMA parametro_funcion resto_parametros
                      {fprintf(yyout, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");}
                    | %empty {fprintf(yyout, ";R26:\t<parametros_funcion> ::=\n");}
                    ;

parametro_funcion   : {categoria_actual = PARAMETRO;} tipo TOK_IDENTIFICADOR
                    { fprintf(yyout, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
                      if(tabla_buscar_local(t, $3.lexema) == NULL){
                        n = (Nodo *) malloc(sizeof(Nodo));
                        strcpy(n->lexema, $3.lexema);
                        n->categoria = categoria_actual;
                        n->clase = ESCALAR;
                        n->tipo = tipo_actual;
                        n->tamanio = tamanio_vector_actual;
                        n->pos_parametro = pos_parametro_actual;
                        n->num_parametros = -1;
                        n->pos_var_local = -1;
                        n->num_var_local = -1;
                        tabla_insertar(t, n);
                        free(n);
                        n = NULL;
                        num_parametros_actual++;
                        pos_parametro_actual++;
                      }else{
                        printf("****Error semantico en lin %ld: Declaracion duplicada.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                    }
                    ;

declaraciones_funcion : declaraciones {fprintf(yyout, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");}
                    | %empty {fprintf(yyout, ";R29:\t<parametros_funcion> ::=\n");}
                    ;

sentencias          : sentencia {fprintf(yyout, ";R30:\t<sentencias> ::= <sentencia>\n");}
                    | sentencia sentencias {fprintf(yyout, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");}
                    ;

sentencia           : sentencia_simple TOK_PUNTOYCOMA {fprintf(yyout, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");}
                    | bloque {fprintf(yyout, ";R33:\t<sentencia> ::= <bloque>\n");}
                    ;

sentencia_simple    : asignacion {fprintf(yyout, ";R34:\t<sentencia_simple> ::= <asignacion>\n");}
                    | lectura {fprintf(yyout, ";R35:\t<sentencia_simple> ::= <lectura>\n");}
                    | escritura {fprintf(yyout, ";R36:\t<sentencia_simple> ::= <escritura>\n");}
                    | retorno_funcion {fprintf(yyout, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");}
                    ;

bloque              : condicional {fprintf(yyout, ";R40:\t<bloque> ::= <condicional>\n");};
                    | bucle {fprintf(yyout, ";R41:\t<bloque> ::= <bucle>\n");};
                    ;

asignacion          : TOK_IDENTIFICADOR TOK_ASIGNACION exp
                    { fprintf(yyout, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
                      if((n = tabla_buscar_local(t, $1.lexema)) != NULL){
                        if(n->categoria == FUNCION || n->clase == VECTOR || n->tipo != $3.tipo){
                          printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }
                        if(n->categoria == PARAMETRO){
                          escribirParametro(yyout, n->pos_parametro, num_parametros_actual);
                          asignarDestinoEnPila(yyout, $3.es_direccion);
                        }else{
                          escribirVariableLocal(yyout, n->pos_var_local);
                          asignarDestinoEnPila(yyout, $3.es_direccion);
                        }
                      }else if((n = tabla_buscar(t, $1.lexema)) != NULL){
                        if(n->categoria == FUNCION || n->clase == VECTOR || n->tipo != $3.tipo){
                          printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }
                        asignar(yyout, $1.lexema, $3.es_direccion);
                      }else{
                        printf("****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                    }
                    | elemento_vector TOK_ASIGNACION exp
                    { fprintf(yyout, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
                      if($1.tipo != $3.tipo){
                        printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      sprintf(aux,"%d", $1.valor_entero);
                      escribir_operando(yyout, aux,0);
                      escribir_elemento_vector(yyout, $1.lexema, n->tamanio, 0);
                      asignarDestinoEnPila(yyout, $3.es_direccion);
                    }
                    ;

elemento_vector     : TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO
                    { fprintf(yyout, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
                      if((n = tabla_buscar(t, $1.lexema)) == NULL){
                        printf("****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      if(n->clase != VECTOR){
                        printf("****Error semantico en lin %ld: Intento de indexacion de una variable que no es de tipo vector.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      if($3.tipo != INT){
                        printf("****Error semantico en lin %ld: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      strcpy($$.lexema, $1.lexema);
                      $$.tipo = n->tipo;
                      $$.es_direccion = 1;
                      $$.valor_entero = $3.valor_entero;
                      escribir_elemento_vector(yyout, $1.lexema, n->tamanio, $3.es_direccion);
                    }
                    ;

condicional         : if_sentencias TOK_LLAVEDERECHA
                    { fprintf(yyout, ";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");
                      ifthenelse_fin(yyout, $1.etiqueta);
                    }
                    | if_sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
                    { fprintf(yyout, ";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> }else{ <sentencias> }\n");
                      ifthenelse_fin(yyout, $1.etiqueta);
                    }
                    ;

if_sentencias       : if_exp sentencias
                    { $$.etiqueta = $1.etiqueta;
                      ifthenelse_fin_then(yyout, $$.etiqueta);
                    }
                    ;

if_exp              : TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA
                    { if($3.tipo != BOOLEAN){
                        printf("****Error semantico en lin %ld: Condicional con condicion de tipo int.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      num_condicionales ++;
                      $$.etiqueta = num_condicionales;
                      ifthen_inicio(yyout, $3.es_direccion, $$.etiqueta);
                    }
                    ;

bucle               : bucle_exp TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
                    { while_fin(yyout, $$.etiqueta);
                    }
                    ;

bucle_exp           : bucle_inicio TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
                    { if($3.tipo != BOOLEAN){
                        printf("****Error semantico en lin %ld: Bucle con condicion de tipo int.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      $$.etiqueta = $1.etiqueta;
                      while_exp_pila(yyout, $3.es_direccion, $$.etiqueta);
                    }
                    ;

bucle_inicio        : TOK_WHILE
                    { fprintf(yyout, ";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");
                      num_bucles++;
                      $$.etiqueta = num_bucles;
                      while_inicio(yyout, $$.etiqueta);
                    }
                    ;

lectura             : TOK_SCANF TOK_IDENTIFICADOR
                    { fprintf(yyout, ";R54:\t<lectura> ::= scanf <identificador>\n");
                      if((n = tabla_buscar_local(t, $2.lexema)) != NULL){
                        if(n->categoria == FUNCION || n->clase == VECTOR){
                          printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }else{
                          if(n->categoria == PARAMETRO){
                            escribirParametro(yyout,n->pos_parametro,num_parametros_actual);
                            leer_ambito(yyout, n->tipo);
                          }else{
                            escribirVariableLocal(yyout, n->pos_var_local);
                            leer_ambito(yyout, n->tipo);
                          }
                        }

                      }else if((n = tabla_buscar(t, $2.lexema)) != NULL){
                        if(n->categoria == FUNCION || n->clase == VECTOR){
                          printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }else{
                          leer(yyout, $2.lexema, n->tipo);
                        }
                      }else{
                        printf("****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", fila, $2.lexema);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                    }
                    ;

escritura           : TOK_PRINTF exp
                    { fprintf(yyout, ";R56:\t<escritura> ::= printf <exp>\n");
                      escribir(yyout, $2.es_direccion, $2.tipo);
                    }
                    ;

retorno_funcion     : TOK_RETURN exp
                    { fprintf(yyout, ";R61:\t<retorno_funcion> ::= return <exp>\n");
                      if(ambito_local == 0){
                        printf("****Error semantico en lin %ld: Sentencia de retorno fuera del cuerpo de una función.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      if(retorno_tipo != $2.tipo){
                        printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      retornarFuncion(yyout, $2.es_direccion);
                      retorna = 1;
                    }
                    ;

exp                 : exp TOK_MAS exp
                    { fprintf(yyout, ";R72:\t<exp> ::= <exp> + <exp>\n");
                      if($1.tipo != INT || $3.tipo != INT){
                        printf("****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        sumar(yyout, $1.es_direccion, $3.es_direccion);
                        $$.tipo = INT;
                        $$.es_direccion = 0;
                        $$.valor_entero = $1.valor_entero + $3.valor_entero;
                      }
                    }
                    | exp TOK_MENOS exp
                    { fprintf(yyout, ";R73:\t<exp> ::= <exp> - <exp>\n");
                      if($1.tipo != INT || $3.tipo != INT){
                        printf("****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        restar(yyout, $1.es_direccion, $3.es_direccion);
                        $$.tipo = INT;
                        $$.es_direccion = 0;
                        $$.valor_entero = $1.valor_entero - $3.valor_entero;
                      }
                    }
                    | exp TOK_DIVISION exp
                    { fprintf(yyout, ";R74:\t<exp> ::= <exp> / <exp>\n");
                      if($1.tipo != INT || $3.tipo != INT){
                        printf("****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        dividir(yyout, $1.es_direccion, $3.es_direccion);
                        $$.tipo = INT;
                        $$.es_direccion = 0;
                        if($3.valor_entero == 0){ /* Division por cero es error de ejecucion */
                          $$.valor_entero = -1;
                        }else{
                          $$.valor_entero = $1.valor_entero / $3.valor_entero;
                        }
                      }
                    }
                    | exp TOK_ASTERISCO exp
                    { fprintf(yyout, ";R75:\t<exp> ::= <exp> * <exp>\n");
                      if($1.tipo != INT || $3.tipo != INT){
                        printf("****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        multiplicar(yyout, $1.es_direccion, $3.es_direccion);
                        $$.tipo = INT;
                        $$.es_direccion = 0;
                        $$.valor_entero = $1.valor_entero * $3.valor_entero;
                      }
                    }
                    | TOK_MENOS exp
                    { fprintf(yyout, ";R76:\t<exp> ::= - <exp>\n");
                      if($2.tipo != INT){
                        printf("****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        cambiar_signo(yyout, $2.es_direccion);
                        $$.tipo = INT;
                        $$.es_direccion = 0;
                        $$.valor_entero = (-1)*$2.valor_entero;
                      }
                    } /* En las logicas no hace falta guardar el valor de la operacion */
                    | exp TOK_AND exp
                    { fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");
                      if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
                        printf("****Error semantico en lin %ld: Operacion logica con operandos int.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        y(yyout, $1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | exp TOK_OR exp
                    { fprintf(yyout, ";R78:\t<exp> ::= <exp> || <exp>\n");
                      if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
                        printf("****Error semantico en lin %ld: Operacion logica con operandos int.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        o(yyout, $1.es_direccion, $3.es_direccion);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | TOK_NOT exp
                    { fprintf(yyout, ";R79:\t<exp> ::= ! <exp>\n");
                      if($2.tipo != BOOLEAN){
                        printf("****Error semantico en lin %ld: Operacion logica con operandos int.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        no(yyout, $2.es_direccion, num_no++);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | TOK_IDENTIFICADOR
                    { fprintf(yyout, ";R80:\t<exp> ::= <identificador>\n");
                      if((n = tabla_buscar_local(t,$1.lexema)) != NULL){
                        if(n->categoria == FUNCION || n->clase == VECTOR){
                          printf("n->categoria = %d, n->clase=%d\n",n->categoria, n->clase);
                          printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }
                        if(n->categoria == PARAMETRO){
                          escribirParametro(yyout, n->pos_parametro, num_parametros_actual);
                        }else{
                          escribirVariableLocal(yyout, n->pos_var_local);
                        }
                      }else if((n = tabla_buscar(t,$1.lexema)) != NULL){
                        if(n->categoria == FUNCION || n->clase == VECTOR){
                          printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }
                        escribir_operando(yyout, $1.lexema, 1);
                      }else{
                        printf("****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      $$.tipo = n->tipo;
                      $$.es_direccion = 1;
                    }
                    | constante
                    { fprintf(yyout, ";R81:\t<exp> ::= <constante>\n");
                      $$.tipo = $1.tipo;
                      $$.es_direccion = $1.es_direccion;
                    }
                    | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
                    { fprintf(yyout, ";R82:\t<exp> ::= ( <exp> )\n");
                      $$.tipo = $2.tipo;
                      $$.es_direccion = $2.es_direccion;
                    }
                    | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO
                    { fprintf(yyout, ";R83:\t<exp> ::= ( <comparacion> )\n");
                      $$.tipo = $2.tipo;
                      $$.es_direccion = $2.es_direccion;
                    }
                    | elemento_vector
                    { fprintf(yyout, ";R85:\t<exp> ::= <elemento_vector>\n");
                      $$.tipo = $1.tipo;
                      $$.es_direccion = $1.es_direccion;
                    }
                    | idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO
                    { fprintf(yyout, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
                      n = tabla_buscar(t,$1.lexema);

                      if(n == NULL){
                        printf("****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", fila, $1.lexema);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      if(n->categoria == FUNCION){
                        printf("****Error semantico en lin %ld: Asignacion incompatible.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      if(num_parametros_llamada_actual != n->num_parametros){
                        printf("****Error semantico en lin %ld: Numero incorrecto de parametros en llamada a funcion.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      en_explist = 0;
                      $$.tipo = n->tipo;
                      $$.es_direccion = 0;
                      llamarFuncion(yyout, $1.lexema, n->num_parametros);
                    }
                    ;

idf_llamada_funcion : TOK_IDENTIFICADOR
                    { if(en_explist == 1){
                        printf("****Error semantico en lin %ld: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }
                      num_parametros_llamada_actual = 0;
                      en_explist = 1;
                      strcpy($$.lexema, $1.lexema);
                    }
                    ;

lista_expresiones   : lista_expresiones_0 resto_expresiones
                    { fprintf(yyout, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");}
                    | %empty {fprintf(yyout, ";R90:\t<lista_expresiones> ::=\n");}
                    ;

lista_expresiones_0 : exp
                    { operandoEnPilaAArgumento(yyout, $1.es_direccion);
                      num_parametros_llamada_actual++;
                    }
                    ;

resto_expresiones   : resto_expresiones_0 resto_expresiones
                    { fprintf(yyout, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
                    }
                    | %empty {fprintf(yyout, ";R92:\t<resto_lista_expresiones> ::=\n");}
                    ;

resto_expresiones_0 : TOK_COMA exp
                    { operandoEnPilaAArgumento(yyout, $2.es_direccion);
                      num_parametros_llamada_actual++;
                    }
                    ;

comparacion         : exp TOK_IGUAL exp
                    { fprintf(yyout, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
                      if ($1.tipo != INT || $3.tipo != INT) {
                        printf("****Error semantico en lin %ld: Comparacion con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        igual(yyout, $1.es_direccion, $3.es_direccion, num_cmp++);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | exp TOK_DISTINTO exp
                    { fprintf(yyout, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
                      if ($1.tipo != INT || $3.tipo != INT) {
                        printf("****Error semantico en lin %ld: Comparacion con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        distinto(yyout, $1.es_direccion, $3.es_direccion, num_cmp++);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | exp TOK_MENORIGUAL exp
                    { fprintf(yyout, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");
                      if ($1.tipo != INT || $3.tipo != INT) {
                        printf("****Error semantico en lin %ld: Comparacion con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        menor_igual(yyout, $1.es_direccion, $3.es_direccion, num_cmp++);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | exp TOK_MAYORIGUAL exp
                    { fprintf(yyout, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
                      if ($1.tipo != INT || $3.tipo != INT) {
                        printf("****Error semantico en lin %ld: Comparacion con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        mayor_igual(yyout, $1.es_direccion, $3.es_direccion, num_cmp++);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | exp TOK_MENOR exp
                    { fprintf(yyout, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
                      if ($1.tipo != INT || $3.tipo != INT) {
                        printf("****Error semantico en lin %ld: Comparacion con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        menor(yyout, $1.es_direccion, $3.es_direccion, num_cmp++);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    | exp TOK_MAYOR exp
                    { fprintf(yyout, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
                      if ($1.tipo != INT || $3.tipo != INT) {
                        printf("****Error semantico en lin %ld: Comparacion con operandos boolean.\n", fila);
                        tabla_cerrar(t);
                        return ERROR;
                      }else{
                        mayor(yyout, $1.es_direccion, $3.es_direccion, num_cmp++);
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                      }
                    }
                    ;

constante           : constante_logica
                    { fprintf(yyout, ";R99:\t<constante> ::= <constante_logica>\n");
                      $$.tipo = $1.tipo;
                      $$.es_direccion = $1.es_direccion;
                    }
                    | constante_entera
                    { fprintf(yyout, ";R100:\t<constante> ::= <constante_entera>\n");
                      $$.tipo = $1.tipo;
                      $$.es_direccion = $1.es_direccion;
                    }
                    ;

constante_logica    : TOK_TRUE
                    { fprintf(yyout, ";R102:\t<constante_logica> ::= true\n");
                      $$.tipo = BOOLEAN;
                      $$.es_direccion = 0;
                      $$.valor_entero = 1;
                      escribir_operando(yyout, "1", 0);
                    }
                    | TOK_FALSE {
                      fprintf(yyout, ";R103:\t<constante_logica> ::= false\n");
                      $$.tipo = BOOLEAN;
                      $$.es_direccion = 0;
                      $$.valor_entero = 0;
                      escribir_operando(yyout, "0", 0);
                    }
                    ;

constante_entera    : TOK_CONSTANTE_ENTERA
                    { fprintf(yyout, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
                      $$.tipo = INT;
                      $$.es_direccion = 0;
                      $$.valor_entero = $1.valor_entero;
                      sprintf(aux, "%d", $1.valor_entero);
                      escribir_operando(yyout, aux, 0);
                    }
                    ;

identificador       : TOK_IDENTIFICADOR
                    { fprintf(yyout, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
                      if(ambito_local) {
                        if(tabla_buscar_local(t,$1.lexema) == NULL){
                          if(clase_actual == ESCALAR){
                            n = (Nodo *) malloc(sizeof(Nodo));
                            strcpy(n->lexema, $1.lexema);
                            n->categoria = categoria_actual;
                            n->clase = clase_actual;
                            n->tipo = tipo_actual;
                            n->tamanio = 1;
                            n->pos_var_local =  pos_var_local_actual;
                            n->num_var_local = -1;
                            n->pos_parametro = -1;
                            n->num_parametros = -1;
                            tabla_insertar(t, n);
                            free(n);
                            n = NULL;
                            num_var_local_actual++;
                            pos_var_local_actual++;
                          }else{
                            printf("****Error semantico en lin %ld: Variable local de tipo no escalar..\n", fila);
                            tabla_cerrar(t);
                            return ERROR;
                          }
                        }else{
                          printf("****Error semantico en lin %ld: Declaracion duplicada.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }
                      }else{
                        if(tabla_buscar(t,$1.lexema) == NULL){
                          /* tamanio_vector_actual = 1 si es un escalar */
                          n = (Nodo *) malloc(sizeof(Nodo));
                          strcpy(n->lexema, $1.lexema);
                          n->categoria = categoria_actual;
                          n->clase = clase_actual;
                          n->tipo = tipo_actual;
                          n->tamanio = tamanio_vector_actual;
                          n->num_var_local = -1;
                          n->pos_var_local = -1;
                          n->num_parametros = -1;
                          n->pos_parametro = -1;
                          tabla_insertar(t, n);
                          free(n);
                          n = NULL;
                          declarar_variable(yyout, $1.lexema, tipo_actual, tamanio_vector_actual);
                        }else{
                          printf("****Error semantico en lin %ld: Declaracion duplicada.\n", fila);
                          tabla_cerrar(t);
                          return ERROR;
                        }
                      }
                    }
                    ;

%%

/* Manejo de errores. Solo se imprime mensaje de error sintactico en el caso de
que no se haya dado un error morfologico antes */
void yyerror(const char * s){
  if(!error_morfologico){
    fprintf(stderr, "****Error sintactico en [lin %ld, col %ld]\n", fila, columna-yyleng);
  }else{
    error_morfologico = 0;
  }
  tabla_cerrar(t);
}
