; Technically, three or more digits are not supported,
; however, 100 prints 'buzz' so it's ok. But 101 won't work.

%define output_length r15
%define zero r8w ; always 0
%define zero_char si ; always '0'
%define literal_has_been_used r13b ; either 0 or 1

%macro literal 1
    mov ebx, dword [%1]
    mov dword [output_buffer + output_length], ebx
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
    xor output_length, output_length
    xor r12w, r12w ; i % 3
    xor r11w, r11w ; i % 5
    xor zero, zero
    mov cx, '0' ; first digit (as char, not as number)
    mov dx, '0' ; second digit (as char, not as number)
    mov zero_char, '0'
loop:    
    inc r12w
    cmp r12w, 3
    cmove r12w, zero
    inc r11w
    cmp r11w, 5
    cmove r11w, zero
    inc dx
    cmp dx, '0' + 10
    cmove dx, zero_char

    xor literal_has_been_used, literal_has_been_used
    cmp r12w, 0
    jne after_fizz
    literal fizz
after_fizz:
    cmp r11w, 0
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
    lea rbx, [rcx + 1]
    cmp dx, '0'
    cmove cx, bx
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
