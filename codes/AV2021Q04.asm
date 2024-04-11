extern printf
section .data
    strControle : db "char = %c", 10,
    "hInt = %hu", 10,
    "fInt = %u", 10,
    "lInt = %lld", 10,
    "float = %f", 10,
    "double = %lf", 10,
    "string = %s", 10, 0
    halfInt : dw 42000
    fullInt : dd 420000000
    longInt : dq 4200000000000000000
    fpSingle : dd 3.1415
    fpDouble : dq 3.1415
    stringS : db "quarenta e dois", 10, 0
    charC : db "a"
section .text
    global main

main:
    push rbp
    mov rbp, rsp
    ; printf utilizando os parâmetros
    call printf
fim:
    mov rsp, rbp
    pop rbp
    mov rax, 60
    mov rdi, 0
    syscall
