[BITS 16]        ; Indicamos al ensamblador NASM que trabajamos en modo real (16 bits)
[ORG 0x0]        ; Indica que el código se cargará en la dirección 0x0000 (posición lógica)

; Inicialización de segmentos
    mov ax, 0x07C0     ; El BIOS carga el MBR en la dirección física 0x7C00.
                    ; Segmento = 0x07C0 → 0x07C0:0000 = 0x7C00.
    mov ds, ax         ; Segmento de datos.
    mov es, ax         ; Segmento extra (no usado, pero se inicializa por buenas prácticas).

    mov ax, 0x8000     ; Segmento de la pila (stack) → dirección 0x80000.
    mov ss, ax         ; Segmento de pila.
    mov sp, 0xF000     ; Puntero de pila. La pila empieza en 0x8F000 y crece hacia abajo.

; Mostrar mensaje
    mov si, msgDebut   ; Carga la dirección del mensaje en SI (registro fuente).
    call afficher      ; Llama a la subrutina que imprimirá carácter por carácter.

end:
    jmp end            ; Bucle infinito. El sistema se queda aquí una vez mostrado el mensaje.

; Variables
    msgDebut db "Hello World !", 13, 10, 0

; Subrutina afficher: imprimir string con INT 10h
afficher:
    push ax            ; Guardamos el contenido de AX
    push bx            ; Guardamos el contenido de BX

.debut:
    lodsb              ; Carga el byte apuntado por DS:SI en AL y avanza SI.
    cmp al, 0          ; ¿Fin del string (carácter nulo)?
    jz .fin            ; Si es 0, salta al final de la rutina.

    mov ah, 0x0E       ; Servicio de la BIOS: teletipo (TTY) → imprime carácter en AL.
    mov bx, 0x07       ; Atributos de color/texto: página 0, color gris claro sobre negro.
    int 0x10           ; Llamada a la interrupción BIOS para imprimir el carácter.

    jmp .debut         ; Repetir con el siguiente carácter.

.fin:
    pop bx             ; Restauramos los registros
    pop ax
    ret                ; Volver a donde fue llamado

;  Relleno + firma de sector de arranque
    times 510-($-$$) db 144
    dw 0xAA55
