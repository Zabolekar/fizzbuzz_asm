; Technically, three or more digits are not supported,
; however, 100 prints 'buzz' so it's ok. But 101 won't work.

%define zero_char si ; always '0'
%define print_number dil ; boolean
%define output_length r15

%macro literal 1
    mov dword [output_buffer + output_length], %1
    add output_length, 4
    xor print_number, print_number
%endmacro

%macro char 1
    mov byte [output_buffer + output_length], %1
    inc output_length
%endmacro

section .bss
    output_buffer resb 9 * 100 + 1
    ; 'FIZZBUZZ ' is 9 bytes, we process 100 numbers, and final 1 is the newline.
    ; We'll actually use less, but memory is cheap.

section .text
global  _start
_start:
    mov zero_char, '0'
    xor output_length, output_length
    xor ax, ax ; i % 3
    xor bx, bx ; i % 5
    mov cx, '0' ; first digit (as char, not as number)
    mov dx, '0' ; second digit (as char, not as number)
loop:
    inc ax
    inc bx
    inc dx
    inc print_number
    cmp ax, 3
    jne after_fizz
    xor ax, ax
    literal "FIZZ"
after_fizz:
    cmp bx, 5
    jne after_buzz
    xor bx, bx
    literal "BUZZ"
after_buzz:
    test print_number, print_number
    je finally
    cmp cx, '0'
    je second_digit
; first digit
    char cl
second_digit:
    char dl
finally:
    lea r13, [rcx + 1]
    cmp dx, '0' + 10
    cmove dx, zero_char
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
