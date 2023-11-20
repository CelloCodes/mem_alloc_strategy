#-#-# DECLARACAO DE VARIAVEIS #-#-#

CC = gcc

AS = as

CFLAGS = -g -no-pie

LFLAGS = -lm

OBJECTS = main.o memory.o

PROGRAM_NAME = main

#-#-# REGRAS DE COMPILACAO #-#-#

all: $(PROGRAM_NAME)

$(PROGRAM_NAME): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(PROGRAM_NAME)

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

memory.o: memory.s
	$(AS) $(CFLAGS) -c memory.s -o memory.o

clean:
	rm -rf $(OBJECTS)

purge: clean
	rm -rf $(PROGRAM_NAME)
