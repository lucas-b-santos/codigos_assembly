extern printf
extern scanf
section .data
    numv : dd 4, 8, 15, 16, 23, 42, 55, 89, 91, 99
    str1 : db "Entre com seu RA: ", 0
    str1c: db "%d", 0
    str2c: db "resultado = %d", 10, 0

section .bss
    ra : resd 1
section .text
    global main
main:
    push rbp
    mov rbp, rsp

    xor rax, rax
    lea rdi, [str1]
    call printf

    xor rax, rax
    lea rdi, [str1c]
    lea rsi, [ra]
    call scanf

    lea rdi, [ra]
    mov esi, 10
    call exec

    lea rdi, [str2c]
    mov esi, [numv + eax*4]
    xor rax, rax
    call printf
fim:
    mov rsp, rbp
    pop rbp
    mov rax, 60
    mov rdi, 0
    syscall
exec:
    push rbp
    mov rbp, rsp

    xor rdx, rdx
    mov eax, [rdi]
    idiv esi
    mov eax, edx

    mov rsp, rbp
    pop rbp
    ret 