bits 16
org 0x7E00

start:
    ; Postavi video mod (80x25, 16 boja)
    mov ax, 0x0003
    int 0x10

    ; Sakri kursor
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

main_loop:
    ; Postavi poziciju kursora (red 0, stupac 0)
    mov ah, 0x02
    xor bh, bh
    xor dx, dx
    int 0x10

    ; Ispis poruke
    mov si, msg
    call print_string

    ; Postavi poziciju kursora (red 1, stupac 0)
    mov ah, 0x02
    xor bh, bh
    mov dx, 0x0100
    int 0x10

    ; Pročitaj i prikaži vrijeme
    call print_time

    ; Čekaj malo (delay loop)
    mov cx, 0x000F
    mov dx, 0x4240
    mov ah, 0x86
    int 0x15

    ; Ponovi
    jmp main_loop

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

print_time:
    ; Provjeri je li RTC dostupan
    mov ah, 0x02       ; BIOS - read RTC time
    int 0x1A
    jc .fail

    ; Prilagodi za Hrvatsku vremensku zonu (UTC+1)
    ; Dodaj 1 sat (provjeri je li DST aktivan)
    mov al, ch
    call bcd_to_bin
    add al, 1          ; UTC+1
    cmp al, 24
    jb .no_overflow
    sub al, 24
.no_overflow:
    call bin_to_bcd
    mov ch, al

    ; Ispis "Trenutno vrijeme (Hrvatska): "
    mov si, time_prefix
    call print_string

    ; Prikaz HH
    mov al, ch
    call print_bcd

    mov al, ':'
    call print_char

    ; Prikaz MM
    mov al, cl
    call print_bcd

    mov al, ':'
    call print_char

    ; Prikaz SS
    mov al, dh
    call print_bcd

    ret

.fail:
    mov si, time_fail
    call print_string
    ret

print_char:
    mov ah, 0x0E
    int 0x10
    ret

; Ispis BCD broja iz AL
print_bcd:
    push ax
    shr al, 4
    add al, '0'
    call print_char
    pop ax
    and al, 0x0F
    add al, '0'
    call print_char
    ret

; Konvertiraj BCD u binarni (AL -> AL)
bcd_to_bin:
    push cx
    mov cl, al
    and cl, 0x0F
    shr al, 4
    mov ch, 10
    mul ch
    add al, cl
    pop cx
    ret

; Konvertiraj binarni u BCD (AL -> AL)
bin_to_bcd:
    push cx
    xor ah, ah
    mov cl, 10
    div cl
    shl al, 4
    or al, ah
    pop cx
    ret

msg db "ZeroOS - Live sat (Hrvatska)", 0xD, 0xA, 0
time_prefix db "Trenutno vrijeme: ", 0
time_fail db "Greska pri citanju vremena!", 0xD, 0xA, 0

; Popuni ostatak sektora
times 512-($-$$) db 0
