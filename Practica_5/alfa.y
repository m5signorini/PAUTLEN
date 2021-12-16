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
%type <atributos> constante_entera
%type <atributos> identificador
%type <atributos> fn_name
%type <atributos> fn_declaration;

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
                        /* TODO: TIPO ERROR */
                        print_error_semantico(1, NULL);
                        /* TODO: ACABAR */
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
        }
        ;

fn_name: TOK_FUNCTION tipo TOK_IDENTIFICADOR
        {
            if (actual_ht != global_ht) {
                /*TODO: Error*/
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
                /* TODO: Error ambito repetido */
                return 1;
            }

            /* OPCION 1: Comprobar no cerrado */
            if (local_ht != NULL) {
                /* TODO: Error ambito no cerrado (?) */
                return 1;
            }
            local_ht = hash_table_create(TABLESIZE);
            if (local_ht == NULL) {
                /* TODO: Error memoria */
                return 1;
            }
            actual_ht = local_ht;
            hash_table_insert(actual_ht, $3.nombre, data);

            pos_parametro_actual = 0;
            pos_variable_local_actual = 1;
            num_parametros_actual = 0;
            num_variables_locales_actuales = 0;

            strcpy($$.nombre, $3.nombre);
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
                        /* TODO: Error semantico no encontrado */
                        return 1;
                    }
                    /* Comprobaciones semanticas */
                    if (search->elem_category == FUNCION) {
                        /* TODO: Error no se puede asignar funcion */
                        return 1;
                    }
                    if (search->category == VECTOR) {
                        /* TODO: Error no se puede asignar vector */
                        return 1;
                    }
                    /* TODO: Generar codigo */
                    fprintf(out, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
                }
          | elemento_vector TOK_ASIGNACION exp   {fprintf(out, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");}

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO 
                    {
                        Data* search = simbolos_comprobar($1.nombre);
                        if (search == NULL) {
                            /* TODO: Error semantico no encontrado */
                            return 1;
                        }
                        /* Comprobaciones semanticas */
                        if (search->elem_category == FUNCION) {
                            /* TODO: Error no es variable o parametro */
                            return 1;
                        }
                        if (search->category != VECTOR) {
                            /* TODO: Error no es un vector */
                            return 1;
                        }
                        /* TODO: Generar codigo */
                        fprintf(out, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
                    }
               ;

condicional: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA                                                            {fprintf(out, ";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");}
           | TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA    {fprintf(out, ";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");}
           ;

bucle: TOK_WHILE TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {fprintf(out, ";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");}
     ;

lectura: TOK_SCANF TOK_IDENTIFICADOR    
            {
                Data* search = simbolos_comprobar($2.nombre);
                if (search == NULL) {
                    /* TODO: Error semantico no encontrado */
                    return 1;
                }
                /* Comprobaciones semanticas */
                if (search->elem_category == FUNCION) {
                    /* TODO: Error no se puede leer funcion */
                    return 1;
                }
                if (search->category == VECTOR) {
                    /* TODO: Error no se puede leer vector */
                    return 1;
                }
                /* TODO: Generar codigo */
                fprintf(out, ";R54:\t<lectura> ::= scanf <identificador>\n");
            }
       ;

escritura: TOK_PRINTF exp           {fprintf(out, ";R56:\t<escritura> ::= printf <exp>\n");}
         ;

retorno_funcion: TOK_RETURN exp     {fprintf(out, ";R61:\t<retorno_funcion> ::= return <exp>\n");}
               ;

exp: exp TOK_MAS exp                                    
        {
            /* Comprobamos tipos */
            /* Generar codigo */
            fprintf(out, ";R72:\t<exp> ::= <exp> + <exp>\n");
        }
   | exp TOK_MENOS exp                                  {fprintf(out, ";R73:\t<exp> ::= <exp> - <exp>\n");}
   | exp TOK_DIVISION exp                               {fprintf(out, ";R74:\t<exp> ::= <exp> / <exp>\n");}
   | exp TOK_ASTERISCO exp                              {fprintf(out, ";R75:\t<exp> ::= <exp> * <exp>\n");}
   | TOK_MENOS exp                                      {fprintf(out, ";R76:\t<exp> ::= - <exp>\n");}
   | exp TOK_AND exp                                    {fprintf(out, ";R77:\t<exp> ::= <exp> && <exp>\n");}
   | exp TOK_OR exp                                     {fprintf(out, ";R78:\t<exp> ::= <exp> || <exp>\n");}
   | TOK_NOT exp %prec PREC_MINUS                       {fprintf(out, ";R79:\t<exp> ::= ! <exp>\n");}
   | TOK_IDENTIFICADOR                                  
        {
            Data* search = simbolos_comprobar($1.nombre);
            if (search == NULL) {
                /* TODO: Error semantico no encontrado */
                return 1;
            }
            /* Comprobaciones semanticas */
            if (search->elem_category == FUNCION) {
                /* TODO: Error es una funcion */
                return 1;
            }
            if (search->category != ESCALAR) {
                /* TODO: Error no es un escalar (?) */
                return 1;
            }
            fprintf(out, ";R80:\t<exp> ::= <identificador>\n");
        }
   | constante                                          {fprintf(out, ";R81:\t<exp> ::= <constante>\n");}
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO  {fprintf(out, ";R82:\t<exp> ::= ( <exp> )\n");}
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO  {fprintf(out, ";R83:\t<exp> ::= ( <comparacion> )\n");}
   | elemento_vector                                            {fprintf(out, ";R85:\t<exp> ::= <elemento_vector>\n");}
   | TOK_IDENTIFICADOR TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO 
        {
            Data* search = simbolos_comprobar($1.nombre);
            if (search == NULL) {
                /* TODO: Error semantico no encontrado */
                return 1;
            }
            /* Comprobaciones semanticas */
            if (search->elem_category != FUNCION) {
                /* TODO: Error no es una funcion (?) */
                return 1;
            }
            fprintf(out, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
        }
   ;

lista_expresiones: exp resto_lista_expresiones  {fprintf(out, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");}
                 | /*vacio*/                    {fprintf(out, ";R90:\t<lista_expresiones> ::=\n");}
                 ;

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones   {fprintf(out, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");}
                       | /*vacio*/                              {fprintf(out, ";R92:\t<resto_lista_expresiones> ::=\n");}
                       ;

comparacion: exp TOK_IGUAL exp      {fprintf(out, ";R93:\t<comparacion> ::= <exp> == <exp>\n");}
           | exp TOK_DISTINTO exp   {fprintf(out, ";R94:\t<comparacion> ::= <exp> != <exp>\n");}
           | exp TOK_MENORIGUAL exp {fprintf(out, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");}
           | exp TOK_MAYORIGUAL exp {fprintf(out, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");}
           | exp TOK_MENOR exp      {fprintf(out, ";R97:\t<comparacion> ::= <exp> < <exp>\n");}
           | exp TOK_MAYOR exp      {fprintf(out, ";R98:\t<comparacion> ::= <exp> > <exp>\n");}
           ;

constante: constante_logica {fprintf(out, ";R99:\t<constante> ::= <constante_logica>\n");}
         | constante_entera {fprintf(out, ";R100:\t<constante> ::= <constante_entera>\n");}
         ;

constante_logica: TOK_TRUE  {fprintf(out, ";R102:\t<constante_logica> ::= true\n");}
                | TOK_FALSE {fprintf(out, ";R103:\t<constante_logica> ::= false\n");}
                ;

constante_entera: TOK_CONSTANTE_ENTERA 
                {
                    $$.valor_entero = $1.valor_entero;
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
                                /* TODO: Error vector local */
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
                        /* TODO mensaje de error: nombre duplicado */
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
                /*TODO: Error ya existente */
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
    
    switch(tipo_error_semantico) {
        
        /*case ERROR_DEC_DUPLICADA:
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
            printf("****Error semantico en lin <%ld>: El tamanyo del vector %s excede los limites permitidos (1,%d).", yylin, nombre, MAX_TAMANIO_VECTOR);
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
            break;*/
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