#include <stdio.h>
#include <unistd.h>

#include "memory.h"

void *brk_cur = 0, *brk_orig = 0;

// obtem o endereco de brk
void setup_brk()
{
    brk_orig = sbrk(0);
    brk_cur = brk_orig;
}

// restaura o endereco de brk
void dismiss_brk()
{
    brk_cur = brk_orig;
    brk(brk_orig);
}

// 1. procura bloco livre com tamanho igual ou maior que a requisicao
// 2. se encontrar, marca ocupacao, quebra se sobrar mais de 16 e retorna
// o endereco do bloco
// 3. se nao encontrar, abre espaco para um novo bloco
void *memory_alloc( unsigned long long bytes )
{
    unsigned long long occupied;
    unsigned long long size;
    void *blockAddr = brk_orig;
    while (blockAddr < brk_cur) {
        occupied = *((unsigned long long *) blockAddr);
        size = *((unsigned long long *) (blockAddr + 8));
        if (!occupied) {
            if ((size >= bytes) && (size <= bytes + 16)) {
                *((unsigned long long *)blockAddr) = 1;
                return blockAddr+16;
            }

            if (size > bytes + 16) {
                *((unsigned long long *)blockAddr) = 1;
                *((unsigned long long *)(blockAddr + 8)) = bytes;
                *((unsigned long long *)(blockAddr + 16 + bytes)) = 0;
                *((unsigned long long *)(blockAddr + 16 + bytes + 8)) = size - (bytes + 16);
                return blockAddr+16;
            }
        }

        blockAddr += (size + 16);
    }

    int ret = brk(blockAddr + 16 + bytes);
    if (ret == -1) return NULL;
    brk_cur = sbrk(0);

    *((unsigned long long *)blockAddr) = 1;
    *((unsigned long long *)(blockAddr + 8)) = bytes;

    return blockAddr+16;
}

// marca um bloco ocupado como livre
int memory_free( void *p )
{
    p -= 16;
    if (p > brk_cur) {
        return 0;
    }

    unsigned long long *nP = (unsigned long long *) p;
    if (*nP == 0)
        return 0;

    *nP = 0;
    int ret = 1;

    return (ret != -1);
}
