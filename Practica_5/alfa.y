%{
/* Codigo C directamente incluido */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"
#include "alfa.h"

int yylex();
void yyerror();
extern FILE * out;
extern long yylin;
extern long yycol;
extern int error_long_id;   /* a 1 si el identificador es demasiado largo */
extern int error_simbolo;   /* a 1 si se ha leído un símbolo no permitido */
extern char * yytext;

extern HashTable* global_ht;
extern HashTable* local_ht;
extern HashTable* actual_ht;

/* Tipos actuales para INSERT de variables */
int tipo_actual;
int clase_actual;
int tamanio_vector_actual;
int pos_variable_local_actual;

/* Tipos para parametros */
int pos_parametro_actual;
int num_parametros_actual;

/* Tipos para funciones */
int num_variables_locales_actuales;

/* Para comprobar llamadas a funciones */
/* en_explist comprueba que no hay llamadas a funcion, se inicializa a 1*/
int num_parametros_llamada_actual = 0;
int en_explist = 0;

/* Para comprobar retornos de funciones */
int en_cuerpo_funcion = 0;
int num_retornos_actuales = 0;
int tipo_retorno_esperado;

void print_error_semantico(int tipo_error_semantico, char* nombre);
Data* simbolos_comprobar(char* nombre);

%}

%union {
    info_atributos atributos;
}

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

%token <atributos> TOK_IDENTIFICADOR

%token <atributos> TOK_CONSTANTE_ENTERA
%token TOK_TRUE
%token TOK_FALSE

%token TOK_ERROR

%left TOK_IGUAL TOK_MENORIGUAL TOK_MENOR TOK_MAYORIGUAL TOK_MAYOR TOK_DISTINTO
%left TOK_MAS TOK_MENOS
%left TOK_ASTERISCO TOK_DIVISION
%left TOK_AND TOK_OR
%left TOK_NOT
%left PREC_MINUS

%type <atributos> exp
%type <atributos> comparacion
%type <atributos> constante
%type <atributos> constante_logica
%type <atributos> constante_entera
%type <atributos> identificador
%type <atributos> idf_llamada_funcion
%type <atributos> fn_name
%type <atributos> fn_declaration;

%type <atributos> elemento_vector;

%%
/* Sección de reglas */
programa: TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones funciones sentencias TOK_LLAVEDERECHA {fprintf(out, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }");}
        ;

declaraciones: declaracion                  {fprintf(out, ";R2:\t<declaraciones> ::= <declaracion>\n");}
             | declaracion declaraciones    {fprintf(out, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");}
             ;

declaracion: clase identificadores TOK_PUNTOYCOMA {fprintf(out, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");}
           ;

clase: clase_escalar    {clase_actual = ESCALAR;    fprintf(out, ";R5:\t<clase> ::= <clase_escalar>\n");}
     | clase_vector     {clase_actual = VECTOR;     fprintf(out, ";R7:\t<clase> ::= <clase_vector>\n");}
     ;

clase_escalar: tipo {fprintf(out, ";R9:\t<clase_escalar> ::= <tipo>\n");}
             ;

tipo: TOK_INT       {tipo_actual = INT;     fprintf(out, ";R10:\t<tipo> ::= int\n");}
    | TOK_BOOLEAN   {tipo_actual = BOOLEAN; fprintf(out, ";R11:\t<tipo> ::= boolean\n");}
    ;

clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO constante_entera TOK_CORCHETEDERECHO 
                {
                    tamanio_vector_actual = $4.valor_entero;
                    if (tamanio_vector_actual < 1 || tamanio_vector_actual > MAX_TAMANIO_VECTOR ) {
                        /* Error tamanio */
                        print_error_semantico(ERROR_TAM_VECTOR, NULL);
                        return 1;
                    }
                    fprintf(out, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
                }
            ;

identificadores: identificador                          {fprintf(out, ";R18:\t<identificadores> ::= <identificador>\n");}
               | identificador TOK_COMA identificadores {fprintf(out, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");}
               ;

funciones: funcion funciones    {fprintf(out, ";R20:\t<funciones> ::= <funcion> <funciones>\n");}
         | /* vacio */          {fprintf(out, ";R21:\t<funciones> ::=\n");}
         ;

funcion : fn_declaration sentencias TOK_LLAVEDERECHA 
        {
            /* TODO: Necesario realmente comprobar (?) */
            if (actual_ht == global_ht) {
                /* TODO: Error ambito erroneo */
                return 1;
            }
            /* Cerrar ambito */
            hash_table_destroy(local_ht);
            local_ht = NULL;
            actual_ht = global_ht;

            /* Actualizar en ambito actual */
            Data* prev = NULL;
            prev = hash_table_search(actual_ht, $1.nombre);
            if (prev == NULL) {
                /* TODO: Error ambito no encontrado */
                return 1;
            }
            /* TODO: Solo es necesario actualizar variables locales (?) */
            /* prev->num_params = num_parametros_actual; */
            prev->num_loc_vars = num_variables_locales_actuales;
            /* Para retornos */
            en_cuerpo_funcion = 0;
            if (num_retornos_actuales < 1) {
                /* Error funcion sin retorno */
                print_error_semantico(ERROR_FUNCION_SIN_RETORNO, $1.nombre);
                return 1;
            }
            num_retornos_actuales = 0;

            fprintf(out, ";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");
        }
        ;

fn_declaration : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion 
        {
            /* Actualizar identificador en el ambito actual con nueva informacion */
            Data* prev = NULL;
            prev = hash_table_search(actual_ht, $1.nombre);
            if (prev == NULL) {
                /* TODO: Error ambito no encontrado */
                return 1;
            }
            prev->num_params = num_parametros_actual;
            /* TODO: Solo es necesario actualizar parametros (?) */
            /* prev->num_loc_vars = num_variables_locales_actuales;*/
            strcpy($$.nombre, $1.nombre);
            /* Para retornos */
            en_cuerpo_funcion = 1;
        }
        ;

fn_name: TOK_FUNCTION tipo TOK_IDENTIFICADOR
        {
            if (actual_ht != global_ht) {
                /*TODO: Error funcion no global */
                return 1;
            }

            Data data;
            data.elem_category = FUNCION;
            data.datatype = tipo_actual;
            if (clase_actual == VECTOR) {
                data.size = tamanio_vector_actual;
            } else {
                data.size = 0;
            }
            
            /* Buscar en ambito actual */
            if (hash_table_insert(actual_ht, $3.nombre, data) != 0) {
                /* Error ambito repetido */
                print_error_semantico(ERROR_DEC_DUPLICADA, NULL);
                return 1;
            }

            /* OPCION 1: Comprobar no cerrado */
            if (local_ht != NULL) {
                /* TODO: Error ambito no cerrado (?) */
                return 1;
            }
            local_ht = hash_table_create(TABLESIZE);
            if (local_ht == NULL) {
                /* Error memoria */
                print_error_semantico(ERROR_RESERVA_MEMORIA, NULL);
                return 1;
            }
            actual_ht = local_ht;
            hash_table_insert(actual_ht, $3.nombre, data);

            pos_parametro_actual = 0;
            pos_variable_local_actual = 1;
            num_parametros_actual = 0;
            num_variables_locales_actuales = 0;
            strcpy($$.nombre, $3.nombre);

            /* Para retorno */
            tipo_retorno_esperado = data.datatype;
        }
        ;

parametros_funcion: parametro_funcion resto_parametros_funcion  {fprintf(out, ";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");}
                  | /* vacio */                                 {fprintf(out, ";R24:\t<parametros_funcion> ::=\n");}
                  ;

resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion {fprintf(out, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");}
                        | /* vacio */                                               {fprintf(out, ";R26:\t<resto_parametros_funcion> ::=\n");}
                        ;

parametro_funcion: tipo idpf   {fprintf(out, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");}
                 ;

declaraciones_funcion: declaraciones    {fprintf(out, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");}
                     | /* vacío */      {fprintf(out, ";R29:\t<declaraciones_funcion> ::=\n");}
                     ;

sentencias: sentencia           {fprintf(out, ";R30:\t<sentencias> ::= <sentencia>\n");}
         | sentencia sentencias {fprintf(out, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");}
         ;

sentencia: sentencia_simple TOK_PUNTOYCOMA  {fprintf(out, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");}
         | bloque                           {fprintf(out, ";R33:\t<sentencia> ::= <bloque>\n");}
         ;

sentencia_simple: asignacion        {fprintf(out, ";R34:\t<sentencia_simple> ::= <asignacion>\n");}
                | lectura           {fprintf(out, ";R35:\t<sentencia_simple> ::= <lectura>\n");}
                | escritura         {fprintf(out, ";R36:\t<sentencia_simple> ::= <escritura>\n");}
                | retorno_funcion   {fprintf(out, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");}
                ;

bloque: condicional     {fprintf(out, ";R40:\t<bloque> ::= <condicional>\n");}
      | bucle           {fprintf(out, ";R41:\t<bloque> ::= <bucle>\n");}
      ;

asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp     
                {
                    /* Comprobar existencia de identificador */
                    Data* search = simbolos_comprobar($1.nombre);
                    if (search == NULL) {
                        /* Error semantico no encontrado */
                        print_error_semantico(ERROR_ACCESO_VAR_NO_DEC, $1.nombre);
                        return 1;
                    }
                    /* Comprobaciones semanticas */
                    if (search->elem_category == FUNCION) {
                        /* Error no se puede asignar funcion */
                        print_error_semantico(ERROR_ASIGNACION, NULL);
                        return 1;
                    }
                    if (search->category == VECTOR) {
                        /* Error no se puede asignar vector */
                        print_error_semantico(ERROR_ASIGNACION, NULL);
                        return 1;
                    }
                    /* Comprocacion semantica */
                    if ($3.tipo != search->datatype) {
                        /* Error asignacion entre distintos tipos */
                        print_error_semantico(ERROR_ASIGNACION, NULL);
                        return 1;
                    }
                    /* TODO: Generar codigo */
                    fprintf(out, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
                }
          | elemento_vector TOK_ASIGNACION exp   
                {
                    /* Comprocacion semantica */
                    if ($3.tipo != $1.tipo) {
                        /* Error asignacion entre distintos tipos */
                        print_error_semantico(ERROR_ASIGNACION, NULL);
                        return 1;
                    }
                    fprintf(out, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
                }

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO 
                    {
                        /* Uso de la tabla de simbolos */
                        Data* search = simbolos_comprobar($1.nombre);
                        if (search == NULL) {
                            /* Error semantico no encontrado */
                            print_error_semantico(ERROR_ACCESO_VAR_NO_DEC, $1.nombre);
                            return 1;
                        }
                        /* Comprobaciones semanticas */
                        if (search->elem_category == FUNCION) {
                            /* Error no es variable o parametro */
                            print_error_semantico(ERROR_INDEXACION, NULL);
                            return 1;
                        }
                        if (search->category != VECTOR) {
                            /* Error no es un vector */
                            print_error_semantico(ERROR_INDEXACION, NULL);
                            return 1;
                        }
                        if ($3.tipo != INT) {
                            /* Error indice no es entero */
                            print_error_semantico(ERROR_INDICE_INDEXACION, NULL);
                            return 1;
                        }
                        /* Propagacion semantica */
                        $$.tipo = search->datatype;
                        $$.es_direccion = 1;

                        /* TODO: Generar codigo */
                        /* RECUERDA: Comprobacion en tiempo de ejecucion del indice dentro del rango [0, length-1] */
                        fprintf(out, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
                    }
               ;

condicional: if_exp TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA                                                            
                {
                    fprintf(out, ";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");
                }
           | if_exp TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA    
                {
                    fprintf(out, ";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
                }
           ;

bucle: bucle_exp TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {fprintf(out, ";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");}
     ;

if_exp: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
            {
                /* Comprobacion semantica */
                if ($3.tipo != BOOLEAN) {
                    /* Error no boolean dentro de un condicional */
                    print_error_semantico(ERROR_COND_CON_INT, NULL);
                    return 1;
                }
            }
      ;

bucle_exp: TOK_WHILE TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
            {
                /* Comprobacion semantica */
                if ($3.tipo != BOOLEAN) {
                    /* Error no boolean dentro de un condicional */
                    print_error_semantico(ERROR_BUCLE_CON_INT, NULL);
                    return 1;
                }
            }
         ;

lectura: TOK_SCANF TOK_IDENTIFICADOR    
            {
                /* Uso de la tabla de simbolos */
                Data* search = simbolos_comprobar($2.nombre);
                if (search == NULL) {
                    /* Error semantico no encontrado */
                    print_error_semantico(ERROR_ACCESO_VAR_NO_DEC, $2.nombre);
                    return 1;
                }
                /* Comprobaciones semanticas */
                if (search->elem_category == FUNCION) {
                    /* Error no se puede leer funcion */
                    print_error_semantico(ERROR_ASIGNACION, NULL);
                    return 1;
                }
                if (search->category == VECTOR) {
                    /* Error no se puede leer vector */
                    print_error_semantico(ERROR_ASIGNACION, NULL);
                    return 1;
                }
                /* TODO: Generar codigo */
                fprintf(out, ";R54:\t<lectura> ::= scanf <identificador>\n");
            }
       ;

escritura: TOK_PRINTF exp           
            {
                /* Comprobacion semantica */
                /* No hay comprobaciones semanticas */
                /* TODO: Generar codigo */
                fprintf(out, ";R56:\t<escritura> ::= printf <exp>\n");
            }
         ;

retorno_funcion: TOK_RETURN exp     
                    {
                        /* Comprobacion semantica */
                        /* Presente solo en cuerpos de funcion */
                        if (en_cuerpo_funcion != 1) {
                            /* Error retorno fuera de funcion */
                            print_error_semantico(ERROR_RETORNO_FUERA_FUNCION, NULL);
                            return 1;
                        }
                        /* Mismo tipo que el retorno de la funcion */
                        if (tipo_retorno_esperado != $2.tipo) {
                            /* Error retorno de tipo erroneo */
                            print_error_semantico(ERROR_RETORNO_FUERA_FUNCION, NULL);
                            return 1;
                        }
                        num_retornos_actuales += 1;
                        fprintf(out, ";R61:\t<retorno_funcion> ::= return <exp>\n");
                    }
               ;

exp: exp TOK_MAS exp                                    
        {
            /* Comprobamos tipos */
            if ($1.tipo != INT || $3.tipo != INT) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_ARIT_CON_BOOL, NULL);
                return 1;
            }
            $$.tipo = INT;
            /* NO es direccion pues es la suma de cosas es decir no es una variable (x+x no es direccion)*/
            $$.es_direccion = 0;

            /* TODO: Generar codigo */


            fprintf(out, ";R72:\t<exp> ::= <exp> + <exp>\n");
        }
   | exp TOK_MENOS exp                                  
        {
            /* Comprobamos tipos */
            if ($1.tipo != INT || $3.tipo != INT) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_ARIT_CON_BOOL, NULL);
                return 1;
            }
            $$.tipo = INT;
            $$.es_direccion = 0;

            /* TODO: Generar codigo */
            fprintf(out, ";R73:\t<exp> ::= <exp> - <exp>\n");
        }
   | exp TOK_DIVISION exp                               
        {
            /* Comprobamos tipos */
            if ($1.tipo != INT || $3.tipo != INT) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_ARIT_CON_BOOL, NULL);
                return 1;
            }
            $$.tipo = INT;
            $$.es_direccion = 0;

            /*TODO: Generar codigo */
            fprintf(out, ";R74:\t<exp> ::= <exp> / <exp>\n");
        }
   | exp TOK_ASTERISCO exp                              
        {
            /* Comprobamos tipos */
            if ($1.tipo != INT || $3.tipo != INT) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_ARIT_CON_BOOL, NULL);
                return 1;
            }
            $$.tipo = INT;
            $$.es_direccion = 0;

            /*TODO: Generar codigo */
            fprintf(out, ";R75:\t<exp> ::= <exp> * <exp>\n");
        }
   | TOK_MENOS exp                                      
        {
            /* Comprobamos tipos */
            if ($2.tipo != INT) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_ARIT_CON_BOOL, NULL);
                return 1;
            }
            $$.tipo = INT;
            $$.es_direccion = 0;

            /*TODO: Generar codigo */
            fprintf(out, ";R76:\t<exp> ::= - <exp>\n");
        }
   | exp TOK_AND exp                                    
        {
            /* Comprobamos tipos */
            if ($1.tipo != BOOLEAN || $3.tipo != BOOLEAN) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_LOG_CON_INT, NULL);
                return 1;
            }
            $$.tipo = BOOLEAN;
            $$.es_direccion = 0;

            /*TODO: Generar codigo */
            fprintf(out, ";R77:\t<exp> ::= <exp> && <exp>\n");
        }
   | exp TOK_OR exp                                     
        {
            /* Comprobamos tipos */
            if ($1.tipo != BOOLEAN || $3.tipo != BOOLEAN) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_LOG_CON_INT, NULL);
                return 1;
            }
            $$.tipo = BOOLEAN;
            $$.es_direccion = 0;

            /*TODO: Generar codigo */
            fprintf(out, ";R78:\t<exp> ::= <exp> || <exp>\n");
        }
   | TOK_NOT exp %prec PREC_MINUS                       
        {
            /* Comprobamos tipos */
            if ($2.tipo != BOOLEAN) {
                /* Error semantico de tipo */
                print_error_semantico(ERROR_OP_LOG_CON_INT, NULL);
                return 1;
            }
            $$.tipo = BOOLEAN;
            $$.es_direccion = 0;

            /*TODO: Generar codigo */
            fprintf(out, ";R79:\t<exp> ::= ! <exp>\n");
        }
   | TOK_IDENTIFICADOR                                  
        {
            /* Uso de tabla de simbolos */
            Data* search = simbolos_comprobar($1.nombre);
            if (search == NULL) {
                /* Error semantico no encontrado */
                print_error_semantico(ERROR_ACCESO_VAR_NO_DEC, $1.nombre);
                return 1;
            }
            /* Comprobaciones semanticas */
            if (search->elem_category == FUNCION) {
                /* Error es una funcion */
                print_error_semantico(ERROR_ES_FUNCION, $1.nombre);
                return 1;
            }
            if (search->category != ESCALAR) {
                /* Error no es un escalar (?) */
                print_error_semantico(ERROR_NO_ESCALAR, $1.nombre);
                return 1;
            }

            /* Propagacion semantica */
            $$.tipo = search->datatype;
            $$.es_direccion = 1;

            fprintf(out, ";R80:\t<exp> ::= <identificador>\n");
        }
   | constante                                          
        {
            /* Propagacion semantica */
            $$.tipo = $1.tipo;
            $$.es_direccion = $1.es_direccion;
            fprintf(out, ";R81:\t<exp> ::= <constante>\n");
        }
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO  
        {
            /* Propagacion semantica */
            $$.tipo = $2.tipo;
            $$.es_direccion = $2.es_direccion;
            fprintf(out, ";R82:\t<exp> ::= ( <exp> )\n");
        }
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO  
        {
            /* Propagacion semantica */
            $$.tipo = $2.tipo;
            $$.es_direccion = $2.es_direccion;
            fprintf(out, ";R83:\t<exp> ::= ( <comparacion> )\n");
        }
   | elemento_vector                                            
        {
            /* Propagacion semantica */
            $$.tipo = $1.tipo;
            $$.es_direccion = $1.es_direccion;
            fprintf(out, ";R85:\t<exp> ::= <elemento_vector>\n");
        }
   | idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO 
        {
            /* Comprobaciones de idf_llamada_funcion */
            /* Comprobaciones semanticas */
            Data* search = simbolos_comprobar($1.nombre);
            if (search->num_params != num_parametros_llamada_actual) {
                /* Error numero de parametros incorrecto */
                print_error_semantico(NUM_PARAM, NULL);
                return 1;
            }
            en_explist = 0;
            /* Propagacion semantica */
            $$.tipo = search->datatype;
            $$.es_direccion = 0;
            fprintf(out, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
        }
   ;

idf_llamada_funcion: TOK_IDENTIFICADOR 
                        {
                            /* Uso de tabla de simbolos */
                            Data* search = simbolos_comprobar($1.nombre);
                            if (search == NULL) {
                                /* Error semantico no encontrado */
                                print_error_semantico(ERROR_ACCESO_VAR_NO_DEC, $1.nombre);
                                return 1;
                            }
                            /* Comprobaciones semanticas */
                            if (search->elem_category != FUNCION) {
                                /* Error no es una funcion */
                                print_error_semantico(ERROR_NO_ES_FUNCION, $1.nombre);
                                return 1;
                            }
                            if (en_explist == 1) {
                                /* Error llamada como parametro en una llamada a funcion */
                                print_error_semantico(ERROR_FUNCION_EN_PARAM, NULL);
                                return 1;
                            }
                            num_parametros_llamada_actual = 0;
                            en_explist = 1;
                            strcpy($$.nombre, $1.nombre);
                        }
                   ;

lista_expresiones: exp resto_lista_expresiones  
                    {
                        num_parametros_llamada_actual += 1;
                        fprintf(out, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
                    }
                 | /*vacio*/                    {fprintf(out, ";R90:\t<lista_expresiones> ::=\n");}
                 ;

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones   
                            {
                                num_parametros_llamada_actual += 1;
                                fprintf(out, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
                            }
                       | /*vacio*/                              {fprintf(out, ";R92:\t<resto_lista_expresiones> ::=\n");}
                       ;

comparacion: exp TOK_IGUAL exp      
                {
                    /* Comprobamos tipos (solo numericos) */
                    if ($1.tipo != INT || $3.tipo != INT) {
                        /* Error semantico de tipo */
                        print_error_semantico(ERROR_COMP_CON_BOOL, NULL);
                        return 1;
                    }
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;

                    /*TODO: Generar codigo */
                    fprintf(out, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
                }
           | exp TOK_DISTINTO exp   
                {
                    /* Comprobamos tipos (solo numericos) */
                    if ($1.tipo != INT || $3.tipo != INT) {
                        /* Error semantico de tipo */
                        print_error_semantico(ERROR_COMP_CON_BOOL, NULL);
                        return 1;
                    }
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;

                    /*TODO: Generar codigo */
                    fprintf(out, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
                }
           | exp TOK_MENORIGUAL exp 
                {
                    /* Comprobamos tipos (solo numericos) */
                    if ($1.tipo != INT || $3.tipo != INT) {
                        /* Error semantico de tipo */
                        print_error_semantico(ERROR_COMP_CON_BOOL, NULL);
                        return 1;
                    }
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;

                    /*TODO: Generar codigo */
                    fprintf(out, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");
                }
           | exp TOK_MAYORIGUAL exp 
                {
                    /* Comprobamos tipos (solo numericos) */
                    if ($1.tipo != INT || $3.tipo != INT) {
                        /* Error semantico de tipo */
                        print_error_semantico(ERROR_COMP_CON_BOOL, NULL);
                        return 1;
                    }
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;

                    /*TODO: Generar codigo */
                    fprintf(out, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
                }
           | exp TOK_MENOR exp      
                {
                    /* Comprobamos tipos (solo numericos) */
                    if ($1.tipo != INT || $3.tipo != INT) {
                        /* Error semantico de tipo */
                        print_error_semantico(ERROR_COMP_CON_BOOL, NULL);
                        return 1;
                    }
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;

                    /*TODO: Generar codigo */
                    fprintf(out, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
                }
           | exp TOK_MAYOR exp      
                {
                    /* Comprobamos tipos (solo numericos) */
                    if ($1.tipo != INT || $3.tipo != INT) {
                        /* Error semantico de tipo */
                        print_error_semantico(ERROR_COMP_CON_BOOL, NULL);
                        return 1;
                    }
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;

                    /*TODO: Generar codigo */
                    fprintf(out, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
                }
           ;

constante: constante_logica 
                {
                    /* Comprobacion semantica */
                    $$.tipo = $1.tipo;
                    $$.es_direccion = $1.es_direccion;
                    
                    /* TODO: Generar codigo */
                    fprintf(out, ";R99:\t<constante> ::= <constante_logica>\n");
                }
         | constante_entera 
                {
                    /* Comprobacion semantica */
                    $$.tipo = $1.tipo;
                    $$.es_direccion = $1.es_direccion;
                    
                    /* TODO: Generar codigo */
                    fprintf(out, ";R100:\t<constante> ::= <constante_entera>\n");
                }
         ;

constante_logica: TOK_TRUE  
                    {
                        /* Comprobacion semantica */
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                        
                        /* TODO: Generar codigo */
                        fprintf(out, ";R102:\t<constante_logica> ::= true\n");
                    }
                | TOK_FALSE 
                    {
                        /* Comprobacion semantica */
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                        
                        /* TODO: Generar codigo */
                        fprintf(out, ";R103:\t<constante_logica> ::= false\n");
                    }
                ;

constante_entera: TOK_CONSTANTE_ENTERA 
                {
                    /* Comprobacion semantica */
                    $$.tipo = INT;
                    $$.es_direccion = 0;

                    /* Paso de valor */
                    $$.valor_entero = $1.valor_entero;

                    /*TODO: Generar codigo */

                    fprintf(out, ";R104:\t<constante> ::= <numero>\n");
                }
                ;

identificador: TOK_IDENTIFICADOR 
                {
                    /* busca $1 en la tabla de simbolos actual */
                    if (hash_table_search(actual_ht, $1.nombre) == NULL) {
                        /* inserta el identificador en la tabla de simbolos */
                        Data data;
                        data.elem_category = VARIABLE;
                        data.datatype = tipo_actual;
                        data.category = clase_actual;
                        if (clase_actual == VECTOR) {
                            data.size = tamanio_vector_actual;
                        } else {
                            data.size = 0;
                        }

                        /* comprobamos si ambito actual es global o local */
                        if (actual_ht == global_ht) {
                            data.pos_loc_var = 0;
                            hash_table_insert(actual_ht, $1.nombre, data);
                        }
                        else {
                            /* Comprobamos NO vector */
                            if (clase_actual == VECTOR) {
                                /* Error vector local */
                                print_error_semantico(ERROR_VAR_LOCAL, NULL);
                                return 1;
                            }
                            /* Insertamos*/
                            data.pos_loc_var = pos_variable_local_actual;
                            hash_table_insert(actual_ht, $1.nombre, data);

                            /* Aumentamos variables pos */
                            pos_variable_local_actual += 1;
                            num_variables_locales_actuales += 1;
                        }
                    } else {
                        /* mensaje de error: nombre duplicado */
                        print_error_semantico(ERROR_DEC_DUPLICADA, NULL);
                        return 1;
                    }
                    fprintf(out, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
                }
             ;

idpf: TOK_IDENTIFICADOR
        {
            /* Comprobamos que ambito sea local ? */
            if(actual_ht == global_ht) {
                /*TODO: Error*/
                return 1;
            }
            Data data;
            data.elem_category = PARAMETRO;
            data.datatype = tipo_actual;
            data.category = clase_actual;
            if (clase_actual == VECTOR) {
                data.size = tamanio_vector_actual;
            } else {
                data.size = 0;
            }
            data.pos = pos_parametro_actual;

            /* inserta el nuevo elemento en la tabla de símbolos actual */
            /* si ya existe uno con esa clave devuelve error semántico */
            if(hash_table_insert(actual_ht, $1.nombre, data) != 0) {
                print_error_semantico(ERROR_DEC_DUPLICADA, NULL);
                return 1;
            }
            pos_parametro_actual += 1;
            num_parametros_actual += 1;
            fprintf(out, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
        }
    ;

%%

/* Codigo C al final */
void yyerror(const char * s) {
    if(error_long_id == 1) {
        printf("****Error en [lin %ld, col %ld]: identificador demasiado largo (%s)\n", yylin, yycol, yytext);
    } else if (error_simbolo == 1) {
        printf("****Error en [lin %ld, col %ld]: simbolo no permitido (%s)\n", yylin, yycol, yytext);
    } else {
        printf("****Error sintactico en [lin %ld, col %ld]\n", yylin, yycol);
    }
}

void print_error_semantico(int tipo_error_semantico, char* nombre) {
    /* Para evitar posibles errores de printf(NULL) */
    char vacio[1] = {0};
    if (nombre == NULL) {
        nombre = vacio;
    }
    
    switch(tipo_error_semantico) {
        
        case ERROR_DEC_DUPLICADA:
            printf("****Error semantico en lin <%ld>: Declaración duplicada.", yylin);
            break;
        
        case ERROR_ACCESO_VAR_NO_DEC:
            printf("****Error semantico en lin <%ld>: Acceso a variable no declarada (%s).", yylin, nombre);
            break;

        case ERROR_OP_ARIT_CON_BOOL:
            printf("****Error semantico en lin <%ld>: Operacion aritmetica con operandos boolean.", yylin);
            break;
        
        case ERROR_OP_LOG_CON_INT:
            printf("****Error semantico en lin <%ld>: Operacion logica con operandos int.", yylin);
            break;
        
        case ERROR_COMP_CON_BOOL:
            printf("****Error semantico en lin <%ld>: Comparacion con operandos boolean.", yylin);
            break;

        case ERROR_COND_CON_INT:
            printf("****Error semantico en lin <%ld>: Condicional con condicion de tipo int.", yylin);
            break;
        
        case ERROR_BUCLE_CON_INT:
            printf("****Error semantico en lin <%ld>: Bucle con condicion de tipo int.", yylin);
            break;
    
        case ERROR_NUM_PARAM:
            printf("****Error semantico en lin <%ld>: Numero incorrecto de parametros en llamada a funcion.", yylin);
            break;
        
        case ERROR_ASIGNACION:
            printf("****Error semantico en lin <%ld>: Asignacion incompatible.", yylin);
            break;

        case ERROR_TAM_VECTOR:
            /* No podemos imprimir facilmente el nombre del vector en el punto de error */
            printf("****Error semantico en lin <%ld>: El tamanyo del vector excede los limites permitidos (1,%d).", yylin, MAX_TAMANIO_VECTOR);
            break;
        
        case ERROR_INDEXACION:
            printf("****Error semantico en lin <%ld>: Intento de indexacion de una variable que no es de tipo vector.", yylin);
            break;
        
        case ERROR_INDICE_INDEXACION:
            printf("****Error semantico en lin <%ld>: El indice en una operacion de indexacion tiene que ser de tipo entero.", yylin);
            break;
    
        case ERROR_FUNCION_SIN_RETORNO:
            printf("****Error semantico en lin <%ld>: Funcion %s sin sentencia de retorno.", yylin, nombre);
            break;
        
        case ERROR_RETORNO_FUERA_FUNCION:
            printf("****Error semantico en lin <%ld>: Sentencia de retorno fuera del cuerpo de una función", yylin);
            break;

        case ERROR_FUNCION_EN_PARAM:
            printf("****Error semantico en lin <%ld>: No esta permitido el uso de llamadas a funciones como parametros de otras funciones", yylin);
            break;
        
        case ERROR_VAR_LOCAL:
            printf("****Error semantico en lin <%ld>: Variable local de tipo no escalar.", yylin);
            break;
        
        /* Errores extra */
        case ERROR_RESERVA_MEMORIA:
            printf("****Error del compilador en lin <%ld>: No se pudo reservar la memoria necesaria.", yylin);
            break;
        case ERROR_ES_FUNCION:
            printf("****Error semantico en lin <%ld>: Nombre de funcion usada como variable: %s ", yylin, nombre);
            break;
        case ERROR_NO_ESCALAR:
            printf("****Error semantico en lin <%ld>: Uso de vector no permitido.", yylin);
            break;
        case ERROR_NO_ES_FUNCION:
            printf("****Error semantico en lin <%ld>: Llamada a algo que no es una función: %s ", yylin, nombre);
            break;
        case ERROR_INESPERADO:
            printf("****Error semantico en lin <%ld>: Error inesperado.", yylin);
            break;
    }
}

/* 
Comprueba nombre en ambitos abiertos 
Devuelve:   Data - existe
            NULL - no existe
*/
Data* simbolos_comprobar(char* nombre) {
    if (nombre == NULL) {
        return NULL;
    }
    Data* search = NULL;
    search = hash_table_search(actual_ht, nombre);
    if (search == NULL) {
        if (actual_ht == local_ht) {
            search = hash_table_search(global_ht, nombre);
            if (search == NULL) {
                /* No encontrado local-global */
                return NULL;
            }
            return search;
        }
        else {
            /* No encontrado global */
            return NULL;
        }
    }
    return search;
}