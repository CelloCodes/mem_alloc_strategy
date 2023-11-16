.section .bss
    .global brk_orig
    .global brk_cur

    .lcomm brk_orig 8
    .lcomm brk_cur 8

.section .text
.global setup_brk
.global dismiss_brk
.global memory_alloc
.global memory_free

setup_brk:
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rdi
    movq $12, %rax
    syscall

    movq %rax, brk_orig
    movq %rax, brk_cur

    popq %rbp
    ret

dismiss_brk:
    pushq %rbp
    movq %rsp, %rbp

    movq brk_orig, %rdi
    movq %rdi, brk_cur
    movq $12, %rax
    syscall

    popq %rbp
    ret

memory_alloc:
    pushq %rbp
    movq %rsp, %rbp
    movq %rdi, %r15

    movq brk_orig, %r12
    _ini_laco_malloc:
        cmp brk_cur, %r12           # compara o endereco do bloco com o brk_cur
        jge _fora_laco_malloc       # end >= brk_cur

        cmp $0, (%r12)
        jne _fim_laco_malloc        # [end] == 0

        movq 8(%r12), %r13          # size
        movq %r15, %r14             # bytes
        cmp %r13, %r14
        jg _fim_laco_malloc         # bytes > size

        addq $16, %r14              # incrementa bytes em 16
        cmp %r13, %r14
        jl _segunda_cond_malloc     # bytes + 16 < size

        movq $1, (%r12)             # seta bloco para ocupado
        addq $16, %r12              # incrementa endereco do bloco em 16
        movq %r12, %rax             # seta endereco incrementado como retorno
        jmp _fim_malloc             # pula para o final

        _segunda_cond_malloc:
        movq %r12, %rax             # move o endereco do bloco para rax
        addq $16, %rax              # incrementa rax em 16
        movq $1, (%r12)             # seta a ocupacao do bloco para 1
        movq %r15, %r14             # movq bytes para r14
        movq %r14, 8(%r12)          # seta o tamanho do bloco para bytes
        addq %r14, %r12             # soma bytes no endereco do bloco
        movq $0, 16(%r12)           # seta a ocupacao do proximo bloco para 0
        addq $16, %r14              # soma 16 em bytes
        subq %r14, %r13             # size -= bytes + 16
        movq %r13, 24(%r12)         # seta o tamanho do proximo bloco em size
        jmp _fim_malloc             # pula para o fim

        _fim_laco_malloc:
        addq $16, %r12              # incrementa o endereco do bloco em 16
        addq %r15, %r12             # incrementa o endereco do bloco em size
        jmp _ini_laco_malloc        # pula para o inicio do loop

    _fora_laco_malloc:
    addq $16, %r12              # incrementa o enredeco do bloco em 16
    addq %r15, %r12             # incrementa o enredeco do bloco em bytes
    movq %r12, %rdi             # seta o endereco do bloco para brk
    movq $12, %rax              # seta syscall de brk
    syscall

    cmp brk_cur, %rax
    je _retorno_null            # retorno_brk == brk_cur

    movq brk_cur, %r13          # move o brk_cur para r13
    movq %rax, brk_cur          # move o retorno do brk para brk_cur
    movq $1, (%r13)             # [end] = 1
    movq %r15, %rcx             # move bytes para rcx
    movq %rcx, 8(%r13)          # [end+8] = bytes
    addq $16, %r13              # soma 16 no endereco do bloco
    movq %r13, %rax             # move o endereco para rax
    jmp _fim_malloc             # pula para o final 

    _retorno_null:
    movq $0, %rax
    jmp _fim_malloc

    _fim_malloc:
    popq %rbp
    ret

memory_free:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %r12
    subq $16, %r12
    cmp brk_orig, %r12
    jl _retorno_zero
    cmp %r12, brk_cur
    jl _retorno_zero
    cmp $0, (%r12)
    je _retorno_zero

    movq $0, (%r12)
    movq $1, %rax
    jmp _fim_free

    _retorno_zero:
    movq $0, %rax
    jmp _fim_free

    _fim_free:
    popq %rbp
    ret
