#ifndef _MEMORY_H_
#define _MEMORY_H_

extern void *brk_orig, *brk_cur;

void setup_brk();

void dismiss_brk();

void *memory_alloc( unsigned long long bytes );

int memory_free( void *p );

#endif // _MEMORY_H_
