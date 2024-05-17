; nasm -f elf64 Calculadora.asm
; gcc -m64 -no-pie Calculadora.o -o Calculadora.x
; ./Calculadora.x

section .data
    strCtrlEntrada : db "%f %c %f", 0

    strErro : db "%lf %c %lf = funcionalidade não disponível", 10, 0
    strOK : db "%lf %c %lf = %lf", 10, 0

    strOpcInvalida : db "Operacao invalida informada. Encerrando...", 10, 0

    fileName : db "saida.txt", 0

    openingMode : db "a", 0

section .text
    extern printf
    extern scanf
    extern fopen
    extern fclose
    extern fprintf
    global main
    
main:
    push rbp
    mov rbp, rsp

    ;==========================================================================================
    ; Reserva de memória para variáveis locais
    ; Para chamadas em C, necessário alinhar a pilha em 16 bytes
    ; Então, subtrai de rsp o próximo múltiplo de 16 em quantidade necessária para as variáveis
    sub rsp, 16
    ;==========================================================================================

    ;Leitura das variaveis
    mov rdi, strCtrlEntrada
    lea rsi, [rbp-4] ;primeira variavel local contendo o operando 1
    lea rdx, [rbp-5] ;segunda variavel local contendo o operador
    lea rcx, [rbp-9] ;terceira variavel local contendo o operando 2
    call scanf

    ;passando op1 e op2 como parametros para as funcoes
    movss xmm0, [rbp-4] 
    movss xmm1, [rbp-9]

    ; switch-case 

    cmp byte [rbp-5], 'a' 
    je callAdicao

    cmp byte [rbp-5], 's'
    je callSubtracao

    cmp byte [rbp-5], 'm'
    je callMult

    cmp byte [rbp-5], 'd'
    je callDivisao

    cmp byte [rbp-5], 'e'
    je callExp

    ;Caso opcao invalida
    xor rax, rax
    mov rdi, strOpcInvalida
    call printf

    jmp fim

callAdicao:
    call adicao

    movss [rbp-13], xmm0

    xor rax, rax
    mov rdi, fileName
    mov rsi, openingMode
    call fopen

    movss xmm2, [rbp-13]
    movss xmm0, [rbp-4]
    movss xmm1, [rbp-9]
    mov rdi, '+'
    mov rsi, rax
    call escrevesolucaoOK
    
    jmp fim

callSubtracao:
    call subtracao  

    movss [rbp-13], xmm0

    xor rax, rax
    mov rdi, fileName
    mov rsi, openingMode
    call fopen

    ;passagem de parametros para escrever arquivo
    movss xmm2, [rbp-13]
    movss xmm0, [rbp-4]
    movss xmm1, [rbp-9]
    mov rdi, '-'
    mov rsi, rax ; ponteiro do arquivo retornado por fopen passa para rsi
    call escrevesolucaoOK
    jmp fim

callMult:
    call multiplicacao  

    movss [rbp-13], xmm0

    xor rax, rax
    mov rdi, fileName
    mov rsi, openingMode
    call fopen

    movss xmm2, [rbp-13]
    movss xmm0, [rbp-4]
    movss xmm1, [rbp-9]
    mov rdi, '*'
    mov rsi, rax
    call escrevesolucaoOK
    
    jmp fim

callDivisao:
    xor rax, rax
    
    mov rdi, fileName
    mov rsi, openingMode
    call fopen

    ; Recupera valores para os registradores
    movss xmm0, [rbp-4] 
    movss xmm1, [rbp-9]

    mov rbx, '/' 

    mov dword [rbp-13], 0

    COMISS xmm1, [rbp-13]
    je callEscreveNOTOK

    call divisao

    ;passagem de parametros para escrever arquivo
    movss xmm2, xmm0 ;resultado
    movss xmm0, [rbp-4] ;op1
    movss xmm1, [rbp-9] ;op2
    mov rdi, rbx ;operador
    mov rsi, rax ; ponteiro do arquivo retornado por fopen passa para rsi
    call escrevesolucaoOK
    jmp fim


callExp:
    xor rax, rax
    
    mov rdi, fileName
    mov rsi, openingMode
    call fopen

    movss xmm0, [rbp-4] 
    movss xmm1, [rbp-9]
    
    mov rbx, '^'

    mov dword [rbp-13], 0

    COMISS xmm1, [rbp-13]
    jb callEscreveNOTOK

    call exponenciacao

    ;passagem de parametros para escrever arquivo
    movss xmm2, xmm0 ;resultado
    movss xmm0, [rbp-4] ;op1
    movss xmm1, [rbp-9] ;op2
    mov rdi, rbx ;operador
    mov rsi, rax ; ponteiro do arquivo retornado por fopen passa para rsi
    call escrevesolucaoOK
    jmp fim

callEscreveNOTOK:
    mov rdi, rbx
    mov rsi, rax
    call escrevesolucaoNOTOK
    jmp fim

fim:
    mov rsp, rbp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall
    
adicao: 
    push rbp
    mov rbp, rsp

    ;Adicao
    addss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret 

subtracao:
    push rbp
    mov rbp, rsp

    ;Subtracao
    subss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret

multiplicacao:
    push rbp
    mov rbp, rsp

    ;Multiplicacao
    mulss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret
    
divisao:
    push rbp
    mov rbp, rsp

    ;Divisão
    divss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret

exponenciacao:
    push rbp
    mov rbp, rsp

    sub rsp, 16

    mov dword [rbp-4], 0
    mov dword [rbp-8], 1

    comiss xmm0, [rbp-4]
    je casoOP1Equals0

    CVTTSS2SI r8, xmm1

    cmp r8, 1
    je casoOP2Equals1

    cmp r8, 0
    je casoOP2Equals0

    movss xmm2, xmm0

    loop:
        mulss xmm2, xmm0 
        dec r8
        cmp r8, 1
        jne loop

    movss xmm0, xmm2
    mov rsp, rbp
    pop rbp
    ret

    casoOP1Equals0:
        movss xmm0, [rbp-4]
        mov rsp, rbp
        pop rbp
        ret

    casoOP2Equals0:
        cvtsi2ss xmm0, dword [rbp-8]
        mov rsp, rbp
        pop rbp
        ret

    casoOP2Equals1:
        mov rsp, rbp
        pop rbp
        ret

escrevesolucaoOK:
    push rbp
    mov rbp, rsp

    sub rsp, 16

    ;Move para variável local o ponteiro para arquivo
    mov [rbp-8], rsi

    ;Parametros op1, op2 e resultado (converte p/ double)
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    cvtss2sd xmm2, xmm2
    ;Parametro operação (char)
    mov rdx, rdi
    ;Aponta que 3 floats serão escritos
    mov rax, 3    
    ;Parametro ponteiro para arquivo
    mov rdi, [rbp-8]
    ;Parametro string de controle
    mov rsi, strOK
    call fprintf

    mov rdi, [rbp-8]
    call fclose

    mov rsp, rbp
    pop rbp
    ret

escrevesolucaoNOTOK:
    push rbp
    mov rbp, rsp

    sub rsp, 16

    ;Move para variável local o ponteiro para arquivo
    mov [rbp-8], rsi

    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1

    ;Parametro operação (char)
    mov rdx, rdi
    ;Aponta que 2 floats serão escritos
    mov rax, 2    
    ;Parametro ponteiro para arquivo
    mov rdi, [rbp-8]
    ;Parametro string de controle
    mov rsi, strErro
    call fprintf

    mov rdi, [rbp-8]
    call fclose

    mov rsp, rbp
    pop rbp
    ret

