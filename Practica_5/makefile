
#########
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#########
CC = gcc
CFLAGS = -ansi -g -c
EXE = prueba_semantica
INPUT = io/input_1.alfa
OUTPUT = io/output_1.txt
#########

all: $(EXE)

prueba_semantica: hash.o y.tab.o alfa.o main.o
	$(CC) -o $@ $^

main.o: main.c hash.h
	$(CC) -Wall $(CFLAGS) -o $@ $<

# FLEX
alfa.o: lex.yy.c
	$(CC) $(CFLAGS) -o $@ $<

lex.yy.c: alfa.l y.tab.h alfa.h
	flex $<

# BISON
y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -o $@ $<

y.tab.c: alfa.y alfa.h hash.h
	bison -dyv $<

y.tab.h: alfa.y alfa.h hash.h
	bison -dyv $<

# HASH
hash.o: hash.c hash.h
	$(CC) -std=c99 -Wall $(CFLAGS) -o $@ $<

# CLEAN

clean:
	rm -rf *.o
	rm -rf $(EXE)
	rm -rf lex.yy.c
	rm -rf y.tab.h y.tab.c y.output

clear:
	rm -rf *.o
	rm -rf lex.yy.c
	rm -rf y.tab.h y.tab.c y.output

# Utilizar ./ejecutable <entrada.txt> <salida.txt>

# Usar --show-leak-kinds=all para comprobar que los errores son solo
# debidos a flex/bison reservando memoria para buffers
valgrind:
	valgrind --leak-check=full ./prueba_semantica $(INPUT) $(OUTPUT)

run:
	./prueba_semantica $(INPUT) $(OUTPUT)