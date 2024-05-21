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
    ; Então, subtrai de rsp o próximo múltiplo de 16 em quantidade suficiente para as variáveis
    sub rsp, 16
    ;==========================================================================================

    ;===== Leitura das variaveis com scanf ==================
    mov rdi, strCtrlEntrada ;String de controle

    ;Aqui passamos a referência das variáveis locais
    lea rsi, [rbp-4] ;operando 1
    lea rdx, [rbp-5] ;operador
    lea rcx, [rbp-9] ;operando 2
    call scanf
    ;========================================================

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

    ;necessário salvar xmm0 pois seu conteúdo é destruído na chamada openf
    movss [rbp-13], xmm0 

    xor rax, rax ;zeramos rax por convenção
    mov rdi, fileName ;arg1: nome do arquivo
    mov rsi, openingMode ;arq2: modo de abertura 
    call fopen

    movss xmm2, [rbp-13] ;arg 3 (PF): resultado
    movss xmm0, [rbp-4] ;arg 2 (PF): op 2
    movss xmm1, [rbp-9] ;arg 1 (PF): op 1
    mov rdi, '+' ;arg 1: operador
    mov rsi, rax ;arg 2: ponteiro para arquivo (retornado por fopen)
    call escrevesolucaoOK
    
    jmp fim

callSubtracao:
    ;Processos iguais à callAdicao, só muda operação

    call subtracao  

    movss [rbp-13], xmm0

    xor rax, rax
    mov rdi, fileName
    mov rsi, openingMode
    call fopen

    movss xmm2, [rbp-13]
    movss xmm0, [rbp-4]
    movss xmm1, [rbp-9]
    mov rdi, '-'
    mov rsi, rax 
    call escrevesolucaoOK
    jmp fim

callMult:
    ;Processos iguais à callAdicao, só muda operação

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
    ;abertura do arquivo
    xor rax, rax 
    mov rdi, fileName 
    mov rsi, openingMode
    call fopen

    ; Recupera valores para os registradores (foram destruídos pela chamada fopen)
    movss xmm0, [rbp-4] 
    movss xmm1, [rbp-9]

    ;Armazena o operador a ser escrito
    mov rbx, '/' 

    ;Variável local usada para fazer comparação
    mov dword [rbp-13], 0

    ; Verifica se op2 é igual à zero
    COMISS xmm1, [rbp-13]
    je callEscreveNOTOK

    ; Caso op2 não for zero, chama a função que faz cálculo
    call divisao

    ;passagem de parametros para escrever no arquivo
    movss xmm2, xmm0 ;resultado
    movss xmm0, [rbp-4] ;op1
    movss xmm1, [rbp-9] ;op2
    mov rdi, rbx ;operador
    mov rsi, rax ; ponteiro do arquivo retornado por fopen passa para rsi
    call escrevesolucaoOK
    jmp fim


callExp:
    ;Processo igual à callDivisao, só muda a comparação para verificar se op2 é menor que zero

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
    ;op1 e op2 já estão nos devidos registradores

    mov rdi, rbx ;arg 1: operador
    mov rsi, rax ;arg 2: ponteiro para o arquivo
    call escrevesolucaoNOTOK
    jmp fim

fim:
    ;Descria o stack-frame da main, encerra programa

    mov rsp, rbp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall
    
adicao: 
    ; retorna op1 + op2

    push rbp
    mov rbp, rsp

    ;Adicao
    addss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret 

subtracao:
    ; retorna op1 - op2

    push rbp
    mov rbp, rsp

    ;Subtracao
    subss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret

multiplicacao:
    ; retorna op1 * op2

    push rbp
    mov rbp, rsp

    ;Multiplicacao
    mulss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret
    
divisao:
    ; retorna op1 / op2

    push rbp
    mov rbp, rsp

    ;Divisão
    divss xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret

exponenciacao:
    ; retorna op1 ^ op2  

    push rbp
    mov rbp, rsp

    sub rsp, 16

    ; variáveis locais usadas para fazer comparações
    mov dword [rbp-4], 0
    mov dword [rbp-8], 1

    ; caso especial: op1 = 0
    comiss xmm0, [rbp-4]
    je casoOP1Equals0

    ; converte op2 para inteiro 
    CVTTSS2SI r8, xmm1

    ; caso especial: op2 = 1
    cmp r8, 1
    je casoOP2Equals1

    ; caso especial: op2 = 0
    cmp r8, 0
    je casoOP2Equals0

    ; usa xmm2 como auxiliar
    movss xmm2, xmm0

    ; calcula a exponenciação
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

    ; === Chamada fprintf ==================================

    ;Parametros op1, op2 e resultado (converte p/ double)
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    cvtss2sd xmm2, xmm2

    
    mov rdx, rdi ;Parametro operação (char)

    mov rax, 3 ;3 floats serão escritos

    
    mov rdi, [rbp-8] ;Parametro ponteiro para arquivo
    
    mov rsi, strOK ;Parametro string de controle
    call fprintf
    ; ==========================================================

    ; Fechar arquivo
    mov rdi, [rbp-8]
    call fclose

    mov rsp, rbp
    pop rbp
    ret

escrevesolucaoNOTOK:
    ; Função igual à escreveNOTOK, porém sem o parâmetro resultado 

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