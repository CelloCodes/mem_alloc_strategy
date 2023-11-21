#include <stdio.h>
#include <stdlib.h>

#include "memalloc.h" 							

#define RED     "\e[1;31m"
#define GREEN   "\e[1;32m"
#define END     "\e[0m"

extern void *original_brk;	/* Você precisa ter a variável global que armazena o valor de brk como um extern aqui.
							No código de teste estou chamandando de original_brk, mas se utilizarem outro nome,
							substituir as ocorrências por ele aqui. */

int main() {

	printf("============================== ROTINAS DE TESTE ==============================\n");

	setup_brk();
	void *initial_brk = original_brk;
	void *pnt_1, *pnt_2, *pnt_3, *pnt_4;
    char* c = GREEN"CORRETO!"END;
    char* i = RED"INCORRETO!"END;

	pnt_1 = memory_alloc(100);
	printf("==>> ALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	printf("\tLOCAL: %s\n", pnt_1-16 == initial_brk ? c : i);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_1-16)) == 1 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_1-8)) == 100 ? c : i);

	pnt_2 = memory_alloc(130);
	printf("==>> ALOCANDO UM ESPAÇO DE 130 BYTES:\n");
	printf("\tLOCAL: %s\n", pnt_2-16 == initial_brk + 116 ? c : i);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_2-16)) == 1 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_2-8)) == 130 ? c : i);
	printf("\tREL. PRIMEIRA ALOCAÇÃO: %s\n", (long long) (pnt_2-pnt_1) == 116 ? c : i);

	printf("==>> DESALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	memory_free(pnt_1);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_1-16)) == 0 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_1-8)) == 100 ? c : i);

	printf("==>> DESALOCANDO UM ESPAÇO DE 130 BYTES:\n");
	memory_free(pnt_2);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_2-16)) == 0 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_2-8)) == 130 ? c : i);

	pnt_3 = memory_alloc(24);
	printf("==>> ALOCANDO UM ESPAÇO DE 24 BYTES:\n");
	printf("\tLOCAL: %s\n", pnt_3 == pnt_2 ? c : i);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_3-16)) == 1 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_3-8)) == 24 ? c : i);

	pnt_4 = memory_alloc(90);
	printf("==>> ALOCANDO UM ESPAÇO DE 90 BYTES:\n");
	printf("\tLOCAL: %s\n", pnt_4 == pnt_1 ? c : i);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_4-16)) == 1 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_4-8)) == 100 ? c : i);

	printf("==>> DESALOCANDO UM ESPAÇO DE 24 BYTES:\n");
	memory_free(pnt_3);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_3-16)) == 0 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_3-8)) == 24 ? c : i);

	printf("==>> DESALOCANDO UM ESPAÇO DE 90 BYTES:\n");
	memory_free(pnt_4);
	printf("\tIND. DE USO: %s\n", *((long long*) (pnt_4-16)) == 0 ? c : i);
	printf("\tTAMANHO: %s\n", *((long long*) (pnt_4-8)) == 100 ? c : i);

	return 0;
}
