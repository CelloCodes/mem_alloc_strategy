#include <stdio.h>
#include <unistd.h>

#include "memory.h"

void *current_brk = 0, *original_brk = 0;

// obtem o endereco de brk
void setup_brk()
{
    original_brk = sbrk(0);
    current_brk = original_brk;
}

// restaura o endereco de brk
void dismiss_brk()
{
    current_brk = original_brk;
    brk(original_brk);
}

// 1. procura bloco livre com tamanho igual ou maior que a requisicao
// 2. se encontrar, marca ocupacao, quebra se sobrar mais de 16 e retorna
// o endereco do bloco
// 3. se nao encontrar, abre espaco para um novo bloco
void *memory_alloc( unsigned long long bytes )
{
    unsigned long long occupied;
    unsigned long long size;
    void *blockAddr = original_brk;
    void *biggest = original_brk;
    unsigned long long biggestSize = 0;
    while (blockAddr < current_brk) {
        occupied = *((unsigned long long *) blockAddr);
        size = *((unsigned long long *) (blockAddr + 8));
        if ((!occupied) && (size >= bytes) && (size > biggestSize)) {
            biggest = blockAddr;
            biggestSize = size;
        }

        blockAddr += (size + 16);
    }

    if (biggestSize == 0) {
        int ret = brk(blockAddr + 16 + bytes);
        if (ret == -1) return NULL;
        current_brk = sbrk(0);
        biggest = blockAddr;

        *((unsigned long long *) (biggest + 8)) = bytes;

    } else {
        size = *((unsigned long long *) (biggest + 8));
        if (size > bytes + 16) {
            *((unsigned long long *) (biggest + 8)) = bytes;
            *((unsigned long long *) (biggest + 16 + bytes)) = 0;
            *((unsigned long long *) (biggest + 16 + bytes + 8)) = size - (bytes + 16);
        }
    }

    *((unsigned long long *) biggest) = 1;
    return biggest+16;
}

// marca um bloco ocupado como livre
int memory_free( void *p )
{
    p -= 16;
    if (p > current_brk) {
        return 0;
    }

    unsigned long long *nP = (unsigned long long *) p;
    if (*nP == 0)
        return 0;

    *nP = 0;
    int ret = 1;

    return (ret != -1);
}
