%define    BASE    0x100
%define KSIZE    30

[BITS 16]
[ORG 0x0]

jmp start

%include "UTIL.INC"
%include "GDT.INC"

start:

; inicialización de los segmentos en 0x07C0
    mov ax, 0x07C0
    mov ds, ax
    mov es, ax
    mov ax, 0x8000    ; stack en 0xFFFF
    mov ss, ax
    mov sp, 0xf000

; recuperación de la unidad de arranque
    mov [bootdrv], dl    

; muestra un mensaje
    mov si, msgDebut
    call afficher

; cargar el núcleo
    xor ax, ax
    int 0x13

    push es
    mov ax, BASE
    mov es, ax
    mov bx, 0
    
    mov ah, 2
    mov al, KSIZE
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [bootdrv]
    int 0x13
    pop es


; inicialización de la GDT
    ; descInit base(32), límite(20/32), acceso/tipo(8), flags(4/8), dirección(16)
    descInit 0, 0xFFFFF, 10011011b, 1101b, gdt_cs
    descInit 0, 0xFFFFF, 10010011b, 1101b, gdt_ds

; inicialización del puntero a la GDT
    mov ax, gdtend    ; calcule la limite de GDT
    mov bx, gdt
    sub ax, bx
    mov word [gdtptr], ax

    xor eax, eax    ; calcula la dirección lineal de la GDT
    mov  ax, ds
    mov  bx, gdt
    call calcadr
    mov dword [gdtptr+2], ecx

; cambio a modo protegido
    cli
    lgdt [gdtptr]    ; carga la gdt
    mov eax, cr0
    or   ax, 1
    mov cr0, eax    ; PE mis a 1 (CR0)

    jmp next
next:
    mov ax, 0x10    ; segmento de datos
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x9F000    

    jmp dword 0x8:0x1000

end:
    jmp end


;--------------------------------------------------------------------
msgDebut db "loading kernel", 13, 10, 0

gdt:
gdt_null:
    dw 0, 0, 0, 0
gdt_cs:
    dw 0, 0, 0, 0
gdt_ds:
    dw 0, 0, 0, 0
gdtend:

gdtptr:
    dw    0x0000    ; límite
    dd    0         ; base

bootdrv: db 0

;--------------------------------------------------------------------
;; NOP hasta 510
times 510-($-$$) db 144
dw 0xAA55

