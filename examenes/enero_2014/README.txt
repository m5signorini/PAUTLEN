#######################################
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#######################################

Para ejecutar el makefile:

make all                -   Compila el fichero alfa y lo necesario
make turbo_test_all     -   Realiza todos los tests que hemos implementado
make turbo_test_anal    -   Realiza solo los tests de analisis
make turbo_test_comp    -   Realiza solo los tests de compilacion
make clean_all          -   Borra todos los ficheros intermedios
make run                -   Ejecuta el fichero alfa con las entradas especificadas en
                            el makefile por INPUT y OUTPREFIX

Anotaciones:
Los tests realizados se dividen en tres carpetas:

test_compile            -   Tests para comprobar la salida esperada de una compilacion
                            completa desde alfa hasta binario. El fichero expected.txt
                            incluye la salida esperada, input.txt incluye la entrada en
                            caso de que fuera necesaria (presencia de scanfs en .alfa).
test_ok                 -   Tests para comprobar que ficheros alfa se compilan correctamente.
test_error              -   Tests para comprobar que ficheros alfa no compilan, pues
                            se ha incluido algun error sintactico/semantico a proposito.