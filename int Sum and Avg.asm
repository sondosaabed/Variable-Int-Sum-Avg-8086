;;; Sondos Aabed 1190652, Rama Hani Abuadas 1192100 
;;; Dr. Mohammad Helal, Compuer organization 


;;; Our code were divided into main sections just like our document:
;;; these main sections are:
;; 
;   1- READ_INPUT: read the count of the numbers and valdate it if valid go to
;;
;   2- READ_SIZE: read the size (1-16) and validate it if valid go to 
;; 
;   3- READ_NUMBERS: read the numbers and validate it and convert it to BCD 
;;                    also add the numbers to the sum
;
;   4- CALCULATE_AVG: calculate the average of the numbers save it
;;
;   5- PRINT_OUTPUTS: print the calculated outputs using subroutine print_bcd

.model small
.data
    
    ;; Define messages prompt for the user
    greeting db 0Dh, 0Ah, "Hello user, enter the inputs numebr: ", 0Dh, 0Ah, "$"
    invalidn db 0Dh, 0Ah, "Error: Not a decimal number. Please re-enter. ", 0Dh, 0Ah, "$"  
    prompt db 0Dh, 0Ah, "Enter the size of the number (1-16): ", 0Dh, 0Ah, "$"
    invalidsize db 0Dh, 0Ah, "nvalid size. Please enter a value between 1 and 16 ", 0Dh, 0Ah, "$"  
    toolarge db 0Dh, 0Ah, "Input too large. Please enter a shorter string.", 0dh, 0ah, "$" ; error message for input too large
    prompt1 db 0Dh, 0Ah, "Enter a number: ", 0Dh, 0Ah, "$"
    prompt2 db 0Dh, 0Ah, "The Sum of your numbers is: ", 0Dh, 0Ah, "$"
    prompt3 db 0Dh, 0Ah, "The Average of your numbers is: ", 0Dh, 0Ah, "$"
    
    
    ;; define variables used for inputs and calulations
    n db ?
    size db ?
    sum db ?
    avg db ? 
    
    input_buffer_sized dw size ; define input buffer with predefined size
    input_buffer db 16 ; define input buffer with size 16 bytes
    
.code
    ; Initialize data segment
    mov AX, @DATA
    mov DS, AX
    
    
    ; Display message to prompt user to enter number
    lea DX, greeting
    mov AH, 09H
    int 21H
    
    ; Read input from user
    READ_INPUT:
        mov AH, 0AH  
        mov dx, offset input_buffer
        int 21H 
        
        mov si, offset input_buffer+1 ; skip the first byte (length byte)
        xor ax, ax ; clear AX register
        
        convert_loop:
            mov bl, [si] ; load next character
            cmp bl, 0dh ; check for carriage return
            je convert_done ; if CR, exit loop
            sub bl, 30h ; convert from ASCII to binary
            mov cx, 10 ; multiply previous value by 10
            mul cx
            add bx, ax ; add new value to previous value
            xor ax, ax ; clear AX register
            mov ax, bx ; move new value to AX register
            inc si ; increment index
            jmp convert_loop ; loop back for next character

    
        convert_done:
        ; the resulting decimal integer is stored in AX register
    
            sub AL, 30H ; convert ASCII digit to binary value
            mov n, AL
        
            ; Check if input is decimal
            ;cmp n, 0AH ; check if value is less than 10 (decimal)
            jb READ_SIZE
            lea DX, invalidn ; display error message
            mov AH, 09H
            int 21H
            
            jmp READ_INPUT ; jump back to read input
        
    READ_SIZE:
        ; Prompt user to enter size of number
        get_size:
            mov ah, 9
            lea dx, prompt
            int 21h
    
            mov AH, 0AH  
            mov dx, offset input_buffer
            int 21H 
            
            mov si, offset input_buffer+1 ; skip the first byte (length byte)
            xor ax, ax ; clear AX register
            
        convert_size_loop:
            mov bl, [si] ; load next character
            cmp bl, 0dh ; check for carriage return
            je convert_size_done ; if CR, exit loop
            sub bl, 30h ; convert from ASCII to binary
            mov cx, 10 ; multiply previous value by 10
            mul cx
            add ax, bx ; add new value to previous value
            inc si ; increment index
            jmp convert_size_loop ; loop back for next character
    
        convert_size_done:
        ; the resulting decimal integer is stored in AX register
    
            sub AL, 30H ; convert ASCII digit to binary value
            mov n, AL
        
            ; Check if input is decimal
            ;cmp n, 0AH ; check if value is less than 10 (decimal)
            jb READ_NUMBERS
            lea DX, invalidsize ; display error message
            mov AH, 09H
            int 21H
            
            jmp get_size ; jump back to read input 
            
            
    READ_NUMBERS: 
        ;; validation of number is decimal and size is size done so it's time to enter the numbers
        ;mov dl, n
        ;mov ah, 02h
        ;int 21h
        
        mov cl, n ; initial loop value
        
        ; Loop to read n decimal integers
        read_loop:
            lea DX, prompt1
            mov AH, 09H
            int 21H
            
            ; Read input as string
            lea DX, input_buffer_sized
            mov AH, 0AH
            int 21H
            
            ; Convert string to BCD value
            mov al, input_buffer+2 ; first character of input string
            mov ah, 0
            sub al, '0' ; convert from ASCII to decimal
            aam ; ASCII adjust for multiplication
            mov dl, ah ; high BCD nibble
            shl dl, 4 ; shift left to make room for low nibble
            mov al, al ; low BCD nibble
            aam ; ASCII adjust for multiplication
            or dl, al ; combine high and low nibbles
            add sum, dl
            
            ; Validate that input is a decimal number
            mov al, input_buffer+2 ; first character of input string
            cmp al, '0'
            jb invalid
            
            cmp al, '9'
            ja invalid
            
            ; Validate that input is within size range
            cmp si, size-1
            je CALCULATE_AVG
            inc si 
            
            loop read_loop
            
            invalid:
                lea dx, invalidn ; display error message
                mov ah, 09H
                int 21H
                jmp read_loop
        
    CALCULATE_AVG:
        xor AX, AX ; clear AX register
        mov AL, sum ; move the sum to the AL register
        mov BL, n ; move the count of numbers to BL register
        mov AH, 0 ; clear AH register

        div BL ; divide sum by the count of numbers

        mov avg, AL ; store result in avg variable

    PRINT_OUTPUTS:
    
        ; Display message to prompt user the sum
        lea DX, prompt2
        mov AH, 09H
        int 21H
        
        ; display the sum
        mov AL, sum
        call print_bcd
        
        ; Display message to prompt user the average
        lea DX, prompt3
        mov AH, 09H
        int 21H
        
        ; display the average
        mov AL, avg
        call print_bcd
    
    ; Exit program
    mov ah, 4ch
    int 21h
    
    print_bcd proc 
        push AX ; save register state            
        mov BL, 10 ; set divisor to 10
        mov CX, 4 ; set loop counter to 4

        bcd_loop:
            xor DX, DX ; clear DX register
            div BL ; divide by 10
            push DX ; save remainder on stack
            dec CX ; decrement loop counter
            jnz bcd_loop ; loop back if not zero

        print_loop:
            pop AX ; load remainder from stack
            add AL, 30h ; convert to ASCII
            mov AH, 02h ; set print function
            int 21h ; print to console
            loop print_loop ; loop back if not zero

        pop AX ; restore register state
        ret ; return from subroutine
    endp
                            
; End of program
END