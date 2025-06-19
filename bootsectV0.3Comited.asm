; Esta version del arrancador cambia el CPU a modo protegido y salta al kernel.

?fine BASE    0x100  ; 0x0100:0x0 = 0x1000
?fine KSIZE   50     ; numero de sectores a cargar (50 * 512 = 25600 bytes)

[BITS 16]
[ORG 0x0]

jmp start
%include "UTIL.INC"
start:

; inicialización del segmento en 0x07C0
    mov ax, 0x07C0      ; BIOS carga el MBR en 0x7C00
    mov ds, ax          ; DS apunta al segmento de datos del bootloader
    mov es, ax          ; ES también apunta ahí por si se necesita copiar datos
    mov ax, 0x8000      ; stack en 0x8000
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

; inicialización del puntero en la GDT
    mov ax, gdtend      ; calcula el límite de GDT
    mov bx, gdt
    sub ax, bx
    mov word [gdtptr], ax   ; guarda el límite de GDT en gdtptr

    xor eax, eax        ; calcula la dirección lineal de GDT
    xor ebx, ebx        ; limpia EBX
    mov ax, ds          ; segmento de datos
    mov ecx, eax        ; limpia ECX
    shl ecx, 4  
    mov bx, gdt
    add ecx, ebx
    mov dword [gdtptr+2], ecx

; paso a modo protegido
    cli
    lgdt [gdtptr]    ; carga la gdt
    mov eax, cr0
    or  ax, 1
    mov cr0, eax        ; PE puesto a 1 (CR0)

    jmp next
next:
    mov ax, 0x10        ; segmento de datos
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x9F000    

    jmp dword 0x8:0x1000    ; reinicializa el segmento de código

;--------------------------------------------------------------------
bootdrv:  db 0
msgDebut: db "Cargando el núcleo...", 13, 10, 0
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

;; NOP hasta 510
times 510-($-$$) db 144
dw 0xAA55