%include "../utils/printf64.asm"

section .data

%define ARRAY_1_LEN 5
%define ARRAY_2_LEN 7
%define ARRAY_OUTPUT_LEN 12

section .data
array_1 dd 27, 46, 55, 83, 84
array_2 dd 1, 4, 21, 26, 59, 92, 105

section .text

extern printf
global main

main:
    push rbp
    mov rbp, rsp

    sub rsp, 4 * ARRAY_1_LEN
    and rsp, -16  ;; Align the stack to 16 bytes
    mov rax, rsp
    mov rdx, 0
array_1_on_stack:
    mov ecx, [array_1 + 4 * rdx]
    mov [rax], ecx
    inc rdx
    add rax, 4
    cmp rdx, ARRAY_1_LEN
    jl array_1_on_stack
    mov rax, rsp

    sub rsp, 4 * ARRAY_2_LEN
    and rsp, -16  ;; Align the stack to 16 bytes
    mov rbx, rsp
    mov rdx, 0
array_2_on_stack:
    mov ecx, [array_2 + 4 * rdx]
    mov [rbx], ecx
    inc rdx
    add rbx, 4
    cmp rdx, ARRAY_2_LEN
    jl array_2_on_stack
    mov rbx, rsp
    sub rsp, 4 * ARRAY_OUTPUT_LEN
    and rsp, -16  ;; Align the stack to 16 bytes
    mov rcx, rsp

merge_arrays:
    mov edx, [rax]
    cmp edx, [rbx]
    jg array_2_lower
array_1_lower:
    mov [rcx], edx  ; The element from array_1 is lower
    add rax, 4
    add rcx, 4
    jmp verify_array_end
array_2_lower:
    mov edx, [rbx]
    mov [rcx], edx  ; The elements of the array_2 is lower
    add rbx, 4
    add rcx, 4

verify_array_end:
    mov rdx, rbp
    cmp rax, rdx
    jge copy_array_2
    sub rdx, 4 * ARRAY_1_LEN
    cmp rbx, rbp
    jge copy_array_1
    jmp merge_arrays

copy_array_1:
    xor rdx, rdx
    mov eax, [rax]
    mov [rcx], edx
    add rcx, 4
    add rax, 4
    cmp rax, rbp
    jb copy_array_1
    jmp print_array
copy_array_2:
    xor rdx, rdx
    mov edx, [rbx]
    mov [rcx], edx
    add rcx, 4
    add rbx, 4
    mov rdx, rbp
    sub rdx, 4 * ARRAY_1_LEN
    cmp rbx, rdx
    jb copy_array_2

print_array:
    PRINTF64 `Array merged:\n\x0`
    xor rax, rax
    xor rcx, rcx

print:
    mov eax, [rsp]
    PRINTF64 `%d \x0`, rax
    add rsp, 4
    inc rcx
    cmp rcx, ARRAY_OUTPUT_LEN
    jb print

    PRINTF64 `\n\x0`
    xor rax, rax
    mov rsp, rbp

    leave
    ret
