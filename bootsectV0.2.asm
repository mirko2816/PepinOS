%define BASE   0x100  
%define KSIZE  1  ; nombre de secteurs de 512 octets a charger

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
    mov si, msgDebut    ; SI apunta al mensaje "Chargement du kernel"
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

; saltar al kernel
    jmp dword BASE:0    ; Salto lejano (far jump) al segmento BASE (0x100), offset 0
                        ; → Salta al kernel que acaba de ser cargado en 0x1000


msgDebut: db "Cargando el núcleo", 13, 10, 0    ; Cadena de texto a imprimir (fin con 0)

bootdrv: db 0           ; Variable para almacenar el número de unidad de arranque

;; NOP hasta 510
times 510-($-$$) db 144 ; Rellenar con NOPs hasta 510 bytes
dw 0xAA55               ; Firma del sector de arranque (0xAA55)
