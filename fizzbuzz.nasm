; Technically, three or more digits are not supported,
; however, 100 prints 'buzz' so it's ok. But 101 won't work.

%define zero di ; always 0
%define zero_char si ; always '0'

%define output_length r15
%define literal_has_been_used r14b ; either 0 or 1

%macro literal 1
    mov r13d, dword [%1]
    mov dword [output_buffer + output_length], r13d
    add output_length, 4
    mov literal_has_been_used, 1
%endmacro

%macro char 1
    mov byte [output_buffer + output_length], %1
    inc output_length
%endmacro

section .data
    fizz db "FIZZ"
    buzz db "BUZZ"

section .bss
    output_buffer resb 9 * 100 + 1
    ; 'FIZZBUZZ ' is 9 bytes, we process 100 numbers, and final 1 is the newline.
    ; We'll actually use less, but memory is cheap.

section .text
global  _start
_start:
    xor zero, zero
    mov zero_char, '0'
    xor output_length, output_length
    xor ax, ax ; i % 3
    xor bx, bx ; i % 5
    mov cx, '0' ; first digit (as char, not as number)
    mov dx, '0' ; second digit (as char, not as number)
loop:    
    inc ax
    cmp ax, 3
    cmove ax, zero
    inc bx
    cmp bx, 5
    cmove bx, zero
    inc dx
    cmp dx, '0' + 10
    cmove dx, zero_char

    xor literal_has_been_used, literal_has_been_used
    test ax, ax
    jne after_fizz
    literal fizz
after_fizz:
    test bx, bx
    jne after_buzz
    literal buzz
after_buzz:
    cmp literal_has_been_used, 1
    je finally
    cmp cx, '0'
    je second_digit
; first digit
    char cl
second_digit:
    char dl
finally:
    lea r13, [rcx + 1]
    cmp dx, '0'
    cmove cx, r13w
    cmp cx, '0' + 10 ; we have reached 100
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
