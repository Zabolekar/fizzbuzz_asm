; Technically, three or more digits are not supported,
; however, 100 prints 'buzz' so it's ok. But 101 won't work.
%define MAX 100

%define output_length r15
%define i r14w
%define literal_has_been_used r13b ; either 0 or 1

%macro literal 1
    mov ecx, dword [%1]
    mov dword [output_buffer + output_length], ecx
    add output_length, 4
    mov literal_has_been_used, 1
%endmacro

%macro char 1
    mov byte [output_buffer + output_length], %1
    inc output_length
%endmacro

%macro divmod 1
    xor dx, dx
    mov ax, i
    mov bx, %1
    div bx
%endmacro

section .data
    fizz db "FIZZ"
    buzz db "BUZZ"

section .bss
    output_buffer resb 9 * MAX + 1
    ; 'FIZZBUZZ ' is 9 bytes, final 1 is the newline.
    ; We'll actually use less, but memory is cheap.

section .text
global  _start
_start:
    xor output_length, output_length
    xor i, i
loop:
    inc i
    xor literal_has_been_used, literal_has_been_used
    divmod 3
    cmp dx, 0
    jne after_fizz
    literal fizz
after_fizz:
    divmod 5
    cmp dx, 0
    jne after_buzz
    literal buzz
after_buzz:
    cmp literal_has_been_used, 1
    je finally
    divmod 10
    cmp ax, 0
    je second_digit
; first digit
    add ax, '0'
    char al
second_digit:
    add dx, '0'
    char dl
finally:
    cmp i, MAX
    je done
    char ' '
    jmp loop
done:
    char `\n`
; print
    mov rax, 1
    mov rdi, 1
    mov rsi, output_buffer
    mov rdx, output_length
    syscall
; exit
    mov rax, 60
    xor rdi, rdi
    syscall
