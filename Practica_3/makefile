
#########
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#########
CC = gcc
CFLAGS = -c -ansi -pedantic -std=c99
EXE = pruebaMorfo
#########

all: $(EXE)

pruebaMorfo: main.o alfa.o y.tab.o
	$(CC) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -Wall $< -o $@

# FLEX
alfa.o: lex.yy.c
	$(CC) $(CFLAGS) $< -o $@

lex.yy.c: alfa.l
	flex $<

# BISON
y.tab.o: y.tab.c
	$(CC) $(CFLAGS) $< -o $@

y.tab.c: alfa.y
	bison -dyv $<

y.tab.h: alfa.y
	bison -dyv $<

# CLEAN

clean:
	rm *.o
	rm $(EXE)
	rm lex.yy.c
	rm y.tab.h y.tab.c

# Utilizar ./ejecutable <entrada.txt> <salida.txt>
