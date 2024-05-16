section .data
    num1 : dd 13.0
    num2 : dd 29.0

section .bss
    resp : resq 1

section .text
    global main

main:
    push rbp
    mov rbp, rsp

    movss xmm0, [num1]

    vaddss xmm0, [num2]
     
    CVTSS2SI rax, xmm0

    mov [resp], rax

end:
    mov rsp, rbp
    pop rbp

    mov rax, 60 ; encerra o programa
    mov rdi, 0
    syscall