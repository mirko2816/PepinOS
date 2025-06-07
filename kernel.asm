[BITS 16]
[ORG 0x0]

jmp start

%include "UTIL.INC"

start:
; Inicializa el DS y ES en 0x100
    mov ax, 0x100       ; Segmento base del kernel (dirección física 0x1000)
    mov ds, ax
    mov es, ax          ; Inicializa el segmento extra

; Inicializa el segmento de pila
    mov ax, 0x8000      ; Segmento de pila (stack) → dirección 0x80000
    mov ss, ax          ; Segmento de pila
    mov sp, 0xf000      ; Puntero de pila. La pila empieza en 0x8F000 y crece hacia abajo.

; Muestra un mensaje
    mov si, msg00
    call afficher

end:
    jmp end


msg00: db 'Kernel is speaking !', 10, 0

