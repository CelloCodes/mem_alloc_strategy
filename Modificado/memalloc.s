.section .bss
    .global original_brk
    .global current_brk

    .lcomm original_brk 8
    .lcomm current_brk 8

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

    movq %rax, original_brk
    movq %rax, current_brk

    popq %rbp
    ret

dismiss_brk:
    pushq %rbp
    movq %rsp, %rbp

    movq original_brk, %rdi
    movq %rdi, current_brk
    movq $12, %rax
    syscall

    popq %rbp
    ret

memory_alloc:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %r15                 # r15 = bytes

    movq original_brk, %r12         # r12 = blockAddr
    movq original_brk, %rax         # rax = biggest
    movq $0, %rbx                   # rbx = biggestSize
    _ini_laco_malloc:
        cmp current_brk, %r12       # compara o endereco do bloco com o current_brk
        jge _fora_laco_malloc       # blockAddr >= current_brk

        movq 8(%r12), %r13          # r13 = size
        cmpq $0, (%r12)
        jne _fim_laco_malloc        # [blockAddr] != 0

        cmp %rbx, %r13
        jle _fim_laco_malloc        # size <= biggestSize

        movq %r12, %rax             # biggest = blockAddr
        movq %r13, %rbx             # biggestSize = size

        _fim_laco_malloc:
        addq $16, %r12              # incrementa o endereco do bloco em 16
        addq %r13, %r12             # incrementa o endereco do bloco em size
        jmp _ini_laco_malloc        # pula para o inicio do loop

    _fora_laco_malloc:
    cmp $0, %rbx
    jne _reutilizar_bloco

    movq %r15, %rdi                 # rdi = bytes
    addq $16, %rdi                  # incrementa rdi em 16
    addq %r12, %rdi                 # incrementa rdi em blockAddr (current_brk)
    movq $12, %rax                  # seta syscall de brk
    syscall
    
    cmp current_brk, %rax
    je _retorno_null                # brk_current == brk(blockAddr + 16 + bytes)

    movq %rax, current_brk          # brk_current = brk(blockAddr + 16 + bytes)
    movq %r12, %rax                 # rax = blockAddr
    movq %r15, 8(%r12)              # [blockAddr + 8] = bytes
    
    jmp _fim_malloc

    _reutilizar_bloco:
    movq 8(%rax), %r13              # r13 = size
    movq %r15, %r14                 # r14 = bytes
    addq $16, %r14                  # r14 += 16
    cmp %r14, %r13
    jle _fim_malloc                 # size <= bytes + 16 (nao comporta fragmentacao)

    movq %r15, 8(%rax)              # [blockAddr+8] = bytes
    addq %rax, %r14                 # r14 += blockAddr (r14 = blockAddr + 16 + bytes)
    movq $0, (%r14)                 # [r14] = 0
    subq $16, %r13                  # size -= 16
    subq %r15, %r13                 # size -= bytes
    movq %r13, 8(%r14)              # [r14 + 8] = size - (bytes + 16)
    jmp _fim_malloc

    _retorno_null:
    movq $0, %rax
    jmp _fim_malloc_pop

    _fim_malloc:
    movq $1, (%rax)                 # [biggest] = 1
    addq $16, %rax
    _fim_malloc_pop:
    popq %rbp
    ret

memory_free:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %r12
    subq $16, %r12
    cmp original_brk, %r12
    jl _retorno_zero
    cmp %r12, current_brk
    jl _retorno_zero
    cmpq $0, (%r12)
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
