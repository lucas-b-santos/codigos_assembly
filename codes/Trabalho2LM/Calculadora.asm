; nasm -f elf64 Calculadora.asm
; gcc -m64 -no-pie Calculadora.o -o Calculadora.x
; ./Calculadora.x

section .data
    strCtrlSaida : db "%lf %c %lf", 10, 0
    strCtrlEntrada : db "%f %c %f", 0

    strErro : db "%lf %c %lf = funcionalidade não disponível", 10, 0
    strOK : db "%lf %c %lf = %lf", 10, 0

    strOpcInvalida : db "Operacao invalida informada. Encerrando...", 10, 0

    fileName : db "saida.txt", 0

    openingMode : db "a", 0

; section .bss
    ; op1 : resd 1
    ; op2 : resd 1
    ; operador : resb 1
    ; result : resd 1
    ; fileP : resq 1
    ; operador2: resb 1

section .text
    extern printf
    extern scanf
    extern fopen
    extern fclose
    extern fprintf
    global main


main:
    ;Prologo
    push rbp
    mov rbp, rsp

    xor rax, rax

    sub rsp, 4 ; op1    
    mov [rbp-4], eax

    sub rsp, 1 ; operador    
    mov byte [rbp-5], 0

    sub rsp, 4 ; op2
    mov [rbp-9], eax

    ;Leitura das variaveis
    xor rax, rax
    mov rdi, strCtrlEntrada
    lea rsi, [rbp-4]
    lea rdx, [rbp-5]
    lea rcx, [rbp-9]
    ; call scanf

    ; movss xmm0, [rbp]
    ; movss xmm1, [rbp-5]

    ; mov rax, 2
    ; mov rdi, strOpcInvalida
    ; mov rsi, [rbp-4]
    ; call printf
b1:
    jmp fim

    ; switch-case

    ; cmp byte [operador], 'a' 
    ; mov byte operador2, [operador]
    ; je callAdicao

    ; cmp byte [operador], 's'
    ; mov byte operador2, [operador]
    ; je callSubtracao

    ; cmp byte [operador], 'm'
    ; mov byte operador2, [operador]
    ; je callMult

    ; cmp byte [operador], 'd'
    ; mov byte operador2, [operador]
    ; je callDivisao

    ; cmp byte [operador], 'e'
    ; mov byte operador2, [operador]
    ; je callExp

    ;Caso opcao invalida
    ; xor rax, rax
    ; mov rdi, strOpcInvalida
    ; call printf

    ; jmp fim

; callAdicao:
;     call adicao

;     xor rax, rax
    
;     mov rdi, fileName
;     mov rsi, openingMode
;     call fopen

;     mov [fileP], rax

;     call escrevesolucaoOK
;     jmp fim

; callSubtracao:

;     call subtracao  

;     xor rax, rax
    
;     mov rdi, fileName
;     mov rsi, openingMode
;     call fopen

;     mov [fileP], rax

;     call escrevesolucaoOK
;     jmp fim

; callMult:

;     call multiplicacao

;     xor rax, rax
    
;     mov rdi, fileName
;     mov rsi, openingMode
;     call fopen

;     mov [fileP], rax

;     call escrevesolucaoOK
;     jmp fim

; callDivisao:
;     xor rax, rax
    
;     mov rdi, fileName
;     mov rsi, openingMode
;     call fopen

;     mov [fileP], rax

;     COMISS xmm1, 0
;     je callEscreveNOTOK

;     call divisao
;     call escrevesolucaoOK
;     jmp fim


; callExp:
;     xor rax, rax
    
;     mov rdi, fileName
;     mov rsi, openingMode
;     call fopen

;     mov [fileP], rax

;     COMISS xmm1, 0
;     jb callEscreveNOTOK

;     call exponenciacao
;     call escrevesolucaoOK
;     jmp fim

; callEscreveNotOK:

;     xor rax, rax
;     mov rdi, 
;     call printf
;     jmp fim

fim:
    mov rsp, rbp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall
    
; adicao: 
;     push rbp
;     mov rbp, rsp

;     ;Adicao
;     addss xmm0, xmm1

;     mov rbp, rsp
;     pop rbp
;     ret 

; subtracao:
;     push rbp
;     mov rbp, rsp

;     ;Subtracao
;     subss xmm0, xmm1

;     mov rbp, rsp
;     pop rbp
;     ret

; multiplicacao:
;     push rbp
;     mov rbp, rsp

;     ;Multiplicacao
;     mulss xmm0, xmm1

;     mov rbp, rsp
;     pop rbp
;     ret
    
; divisao:
;     push rbp
;     mov rbp, rsp

;     ;Divisão
;     divss xmm0, xmm1

;     mov rbp, rsp
;     pop rbp
;     ret

; exponenciacao:
;     push rbp
;     mov rbp, rsp

;     ;Potenciacao

;     comiss xmm0, 0
;     je casoOP1Equals0
    
;     CVTTSS2SI r8, xmm1 

;     cmp r8, 0 
;     je casoOP2Equals0

;     cmp r8, 1
;     je casoOP2Equals1

;     loop:
;         mulss xmm0, xmm0
;         dec r8
;         cmp r8, 1
;         jne loop

;     mov rbp, rsp
;     pop rbp
;     ret

;     casoOP1Equals0:
;         mov xmm0, 0
;         mov rbp, rsp
;         pop rbp
;         ret

;     casoOP2Equals0:
;         mov xmm0, 1
;         mov rbp, rsp
;         pop rbp
;         ret

;     casoOP2Equals1:
;         mov rbp, rsp
;         pop rbp
;         ret

; escrevesolucaoOK:
;     push rbp
;     mov rbp, rsp

;     cvtss2sd xmm0, [op1]
;     cvtss2sd xmm1, [op2]

;     mov rax, 2
;     mov rdi, [fileP]
;     mov rsi, strCtrlSaida
;     mov rdx, [operador]
;     call fprintf

;     mov rdi, [fileP]
;     call fclose
;     jmp fim

;     mov rbp, rsp
;     pop rbp
;     ret
; escrevesolucaoNOTOK:
;     push rbp
;     mov rbp, rsp

;     xor rax, rax
    
;     mov rdi, fileName
;     mov rsi, openingMode
;     call fopen

;     mov [fileP], rax

;     cvtss2sd xmm0, [op1]
;     cvtss2sd xmm1, [op2]

;     mov rax, 2
;     mov rdi, [fileP]
;     mov rsi, strCtrlSaida
;     mov rdx, [operador]
;     call fprintf

;     mov rdi, [fileP]
;     call fclose
;     jmp fim

;     mov rbp, rsp
;     pop rbp
;     ret

