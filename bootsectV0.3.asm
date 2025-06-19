%define BASE   0x100  
%define KSIZE  50  ; número de sectores de 512 bytes a cargar

[BITS 16]
[ORG 0x0]

jmp start
%include "UTIL.INC"
start:

; inicialización de segmentos en 0x07C0
    mov ax, 0x07C0      ; AX = segmento base del bootloader (BIOS lo cargó en 0x7C00)
    mov ds, ax          ; DS apunta al segmento de datos del bootloader
    mov es, ax          ; ES también apunta ahí por si se necesita copiar datos
    mov ax, 0x8000      ; Segmento para la pila (stack)
    mov ss, ax          ; SS apunta al segmento de pila
    mov sp, 0xf000      ; SP = desplazamiento de la pila -> pila empieza en 0x8F000

; Obtener unidad de arranque
    mov [bootdrv], dl   ; BIOS pasa en DL el número de la unidad de arranque (ej. 0x00 disquete, 0x80 disco duro)

; mostrar un mensaje
    mov si, msgDebut    ; SI apunta al mensaje "Cargando el nucleo..."
    call afficher       ; Llama a la rutina que imprime cadenas carácter por carácter usando BIOS

; cargar el núcleo
    xor ax, ax          ; AX = 0 (buena práctica antes de llamar a int 0x13)

    push es             ; Guarda ES en la pila (se restaurará luego)
    mov ax, BASE        ; AX = 0x100, segmento donde se cargará el kernel (dirección física 0x1000)
    mov es, ax          ; ES apunta al lugar en memoria donde se cargará el kernel
    mov bx, 0           ; BX = 0 (desplazamiento dentro del segmento ES)

    mov ah, 2           ; AH = 2 (servicio de lectura de sectores del disco)
    mov al, KSIZE       ; AL = número de sectores a leer (1 sector de 512 bytes)
    mov ch, 0           ; CH = 0 (cylinder 0)
    mov cl, 2           ; CL = 2 (sector 2, el primer sector es el de arranque)
    mov dh, 0           ; DH = 0 (head 0)
    mov dl, [bootdrv]   ; DL = unidad de arranque
    int 0x13            ; Llamada a la interrupción 0x13 para leer el sector
    pop es              ; Restaura ES desde la pila

; initialisation du pointeur sur la GDT 
    mov ax, gdtend    ; calcule la limite de GDT
    mov bx, gdt
    sub ax, bx
    mov word [gdtptr], ax

    xor eax, eax      ; calcule l'adresse linéaire de GDT
    xor ebx, ebx
    mov ax, ds
    mov ecx, eax
    shl ecx, 4
    mov bx, gdt
    add ecx, ebx
    mov dword [gdtptr+2], ecx

; passage en modep
    cli
    lgdt [gdtptr]    ; charge la gdt
    mov eax, cr0
    or  ax, 1
    mov cr0, eax        ; PE mis a 1 (CR0)

    jmp next
next:
    mov ax, 0x10        ; segment de donne
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x9F000    

    jmp dword 0x8:0x1000    ; réinitialise le segment de code

;--------------------------------------------------------------------
bootdrv:  db 0
msgDebut: db "Chargement du kernel", 13, 10, 0
;--------------------------------------------------------------------
gdt:
    db 0, 0, 0, 0, 0, 0, 0, 0
gdt_cs:
    db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10011011b, 11011111b, 0x0
gdt_ds:
    db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10010011b, 11011111b, 0x0
gdtend:
;--------------------------------------------------------------------
gdtptr:
    dw 0  ; limite
    dd 0  ; base
;--------------------------------------------------------------------

;; NOP jusqu'a 510
times 510-($-$$) db 144
dw 0xAA55