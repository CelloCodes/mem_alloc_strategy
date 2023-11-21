#-#-# DECLARACAO DE VARIAVEIS #-#-#

CC = gcc

AS = as

CFLAGS = -g -no-pie

LFLAGS = -lm

OBJECTS = main.o memalloc.o

PROGRAM_NAME = main

#-#-# REGRAS DE COMPILACAO #-#-#

all: $(PROGRAM_NAME)

$(PROGRAM_NAME): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(PROGRAM_NAME)

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

memalloc.o: memalloc.s
	$(AS) $(CFLAGS) -c memalloc.s -o memalloc.o

clean:
	rm -rf $(OBJECTS)

purge: clean
	rm -rf $(PROGRAM_NAME)
