;Este código calcula o n-ésimo número na sequência Fibonacci de forma iterativa
	
;nasm -f elf64 calculoFibonacci.asm 
;ld calculoFibonacci.o -o calculoFibonacci.x

%define maxChars 3

;flag open() - criar + escrita
%define createopenw  101o 
; Read+Write+Execute: -rw-r--r--
%define userWR 644o       


section .data
   strEntrada : db "Digite o n-ésimo número fibonacci que deseja calcular (1 >= n <= 93): "
   strEntradaL : equ $ - strEntrada

   strErro : db "Entrada inválida. Encerrando...", 10
   strErroL : equ $ - strErro

   nomeArquivoPt1 : db "fib("

   nomeArquivoPt2 : db ").bin"

   strPulaLinha : db 10

   aux1 : dq 0
   aux2 : dq 1
   soma : dq 0

section .bss
   entrada   : resb maxChars
   entradaL : resd 1
   char : resb 1
   num : resb 2
   nomeArquivoCompleto : resb 11


section .text
	global _start

_start:
   ; ssize_t write(int fd , const void *buf, size_t count);
   ; rax     write(int rdi, const void *rsi, size_t rdx  );
   mov rax, 1  ; WRITE
   mov rdi, 1
   lea rsi, [strEntrada]
   mov edx, strEntradaL
   syscall

leitura:
   mov dword [entradaL], maxChars ; define o tamanho da variável

   ; ssize_t read(int fd , const void *buf, size_t count);
   ; rax     read(int rdi, const void *rsi, size_t rdx  );
   mov rax, 0  ; READ
   mov rdi, 1
   lea rsi, [entrada] ; lê a variável
   mov edx, [entradaL]
   syscall

   cmp byte [entrada], 10 ; cata a posição do enter
   je _start

   mov r12, rax ; move a quantidade de caracteres lidos para r12

   cmp byte [entrada+eax-1], 10 ; verifica se o enter é o último caractere, se não for, então tem mais que 2, vai pro limpabuffer
   jne limpaBuffer

   cmp eax, 2 ; verifica se há somente um digito, se sim, vai pro solochar
   je solochar

doublechar:
   mov al, [entrada] ;pega caracter à esquerda, verifica seu valor e multiplica por 10
   sub al, 48
   mov rbx, 10
   mul rbx
   mov [num], rax

   mov al, [entrada+1] ;pega caracter à direita, verifica seu valor e soma com o valor da casa das dezenas
   sub al, 48
   add [num], al

   jmp verificaValor 

solochar:
   mov al, [entrada] ; pega o valor decimal do número
   sub al, 48
   mov [num], al

verificaValor:
   cmp word [num], 0 ; verifica se o número é zero, se for, vai pra saída erro
   je saidaErro 

   cmp word [num], 93 ; verifica se passa de 93, se sim, dá erro, pois estoura o inteiro
   ja saidaErro

   mov r8, 1 ; inicia o contador como 1

   cmp word [num], 1 ; verfica se o número digitado é um (caso especial)
   je calculaFibonacci ; vai direto para calcular fibonacci

   mov r8, [num] ; o contador recebe o número digitado
   dec r8 ; decrementa uma vez, necessário

   jmp calculaFibonacci

limpaBuffer:
   mov rax, 0  ; READ
   mov rdi, 1
   lea rsi, [char]  
   mov edx, 1      ; define que a chamada vaio ler um só caractere
   syscall
  
   ; resumo da chamada, lê o bufer restante até que contenha enter

   cmp byte [char], 10 ; verifica se o caracter do buffer é enter
   jne limpaBuffer ; se não for, retorna e lê de novo

saidaErro: ; escreve mensagem de erro e encerra
   mov rax, 1  ; WRITE
   mov rdi, 1
   lea rsi, [strErro]
   mov edx, strErroL
   syscall

   jmp fim

calculaFibonacci: ; calcula o número fibonacci na posição digitada pelo usuário
   mov rbx, 0 ;zera o rbx

   add rbx, [aux1] ;soma com a auxiliar 1
   add rbx, [aux2] ;soma com a auxlilar 2

   mov [soma], rbx ;coloca o resultado na variável soma
   
   mov rbx, [aux2] ; auxiliar 1 recebe o valor de auxiliar 2
   mov [aux1], rbx 

   mov rbx, [soma] ; auxiliar 2 recebe o valor da soma
   mov [aux2], rbx

   dec r8 ; decrementa o contador
   jnz calculaFibonacci  ; enquanto não chegar a zero, ele retorna
 
saidaNormal: ; escreve o arquivo e encerra
   dec r12 ; decrementa o r12, pega a quantia de caracteres lidos sem o enter

   mov rbx, [nomeArquivoPt1] ; rbx recebe a parte inicial do nome do arquivo 
   mov [nomeArquivoCompleto], rbx ; "" + "fib("  -> Adiciona a primeira parte do nome na string do nome completo

   mov rbx, [entrada] ; pega os números digitados
   lea rax, [nomeArquivoCompleto+4] ; coloca o cursor no fim da primeira parte (de tamanho 4 bytes, daí o +4)
   mov [rax], rbx ; "fib(" + entrada  -> concatena a string completa com os números digitados

   mov rbx, [nomeArquivoPt2] ; adiciona a parte 2 do nome 
   lea rax, [nomeArquivoCompleto+4+r12] ; coloca o cursor depois dos números digitados (última posição do nome do arquivo)
   mov [rax], rbx ; "fib(entrada" + ").bin"  -> concatena na string completa

escreveArquivo:
   lea rbx, [nomeArquivoCompleto+9+r12] ; pega o nome do arquivo completo
   mov byte [rbx], 0 

   mov rax, 2          ; open file, abre o arquivo
   lea rdi, [nomeArquivoCompleto] ; *pathname
   mov esi, createopenw; flags
   mov edx, userWR     ; mode
   syscall

   mov ebx, eax  ; eax retorna o descritor do arquivo, algo como um ponteiro

   mov rax, 1 ; WRITE -> escrevendo no arquivo
   mov edi, ebx 
   lea rsi, [soma] ; coloca o número lá dentro                                    
   mov edx, 8
   syscall

   mov rax, 3 ; fecha o arquivo
   mov edi, ebx
   syscall

fim:
   mov rax, 60 ; encerra o programa
   mov rdi, 0
   syscall
