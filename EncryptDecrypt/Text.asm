INCLUDE Irvine32.inc



.data
    ; Constants for file operations
    GENERIC_READ     EQU 80000000h
    GENERIC_WRITE    EQU 40000000h
    FILE_SHARE_READ  EQU 1
    CREATE_ALWAYS    EQU 2
    OPEN_EXISTING    EQU 3
    FILE_ATTRIBUTE_NORMAL EQU 80h

    ; Menu messages
    menuMsg     BYTE "1. Sign Up", 0dh, 0ah
                BYTE "2. Sign In", 0dh, 0ah
                BYTE "3. Exit", 0dh, 0ah
                BYTE "Choose option (1-3): ", 0
    
    ; Signup prompts
    namePrompt  BYTE "Enter name: ", 0
    emailPrompt BYTE "Enter email: ", 0
    agePrompt   BYTE "Enter age: ", 0
    contactPrompt BYTE "Enter contact: ", 0
    addressPrompt BYTE "Enter address: ", 0
    passPrompt  BYTE "Enter password: ", 0
    
    notFoundMsg    BYTE "Email not found.", 0dh, 0ah, 0
    foundMsg       BYTE "Encrypted password: ", 0
    userEmail      BYTE 50 DUP(?)
    ; Messages
    successMsg  BYTE "Operation successful!", 0dh, 0ah, 0
    errorMsg    BYTE "Error occurred!", 0dh, 0ah, 0
    emailExistsMsg BYTE "Email already exists!", 0dh, 0ah, 0
    loginSuccessMsg BYTE "Login successful! ", 0dh, 0ah, 0
    loginFail   BYTE "Invalid email or password!", 0dh, 0ah, 0
    
    ;printing
    printName BYTE "Name : ",0
    printEmail BYTE "Email : ",0
    printAge BYTE "Age : ",0
    printContact BYTE "Contact : ",0
    printAddress BYTE "Address : ",0
    printOrigPass BYTE "Orignal Password : ",0
    printEncPass BYTE "Encrypted Password : ",0


    ; File handling
    fileName    BYTE "users.txt", 0
    fileHandle  DWORD ?
    buffer      BYTE 5000 DUP(?)
    delimiter   BYTE "|", 0
        
    ; User data buffers
    username    BYTE 50 DUP(0),0
    email       BYTE 50 DUP(0),0
    age         BYTE 5 DUP(0),0
    contact     BYTE 15 DUP(0),0
    address     BYTE 100 DUP(0),0
    password    BYTE 50 DUP(0),0
    encPassword BYTE 50 DUP(0),0
    
    ; Temporary buffers for email and password
    tempEmail   BYTE 50 DUP(0)
    tempPass    BYTE 50 DUP(0)
    readBuffer  BYTE 5000 DUP(?)
    bytesRead   DWORD ?
    userFound   BYTE 0
    INVALID_HANDLE_VALUE EQU -1

    ; Messages for PrintUserDetails
    userNotFoundMsg BYTE "User not found.", 0dh, 0ah, 0
    fileNotFoundMsg BYTE "File not found.", 0dh, 0ah, 0
    userFoundMsg    BYTE "User details found:", 0dh, 0ah, 0 
    
    userDetails     BYTE 256 DUP(0)
.code
main PROC
    call MainMenu
    exit
main ENDP

MainMenu PROC
    .WHILE TRUE
        ; Display menu
        mov edx, OFFSET menuMsg
        call crlf
        call WriteString
        call ReadDec
        
        .IF eax == 1
            call SignUp
        .ELSEIF eax == 2
            call SignIn

        .ELSEIF eax == 3
            ret
        .ENDIF
    .ENDW
    ret
MainMenu ENDP

SignUp PROC
    ; Get user details
    mov edx, OFFSET namePrompt
    call WriteString
    
    mov edx, OFFSET username
    mov ecx, SIZEOF username
    call ReadString
    mov [username + ecx - 1], 0  ; Null-terminate

    mov edx, OFFSET emailPrompt
    call WriteString
    
    mov edx, OFFSET email
    mov ecx, SIZEOF email
    call ReadString
    mov [email + ecx - 1], 0  ; Null-terminate

    ; Check if email exists
    call CheckEmailExists
    .IF eax == 1
        mov edx, OFFSET emailExistsMsg
        call WriteString
        ret
    .ENDIF
    
    mov edx, OFFSET agePrompt
    call WriteString
    
    mov edx, OFFSET age
    mov ecx, SIZEOF age
    call ReadString
    mov [age + ecx - 1], 0  ; Null-terminate

    mov edx, OFFSET contactPrompt
    call WriteString
    
    mov edx, OFFSET contact
    mov ecx, SIZEOF contact
    call ReadString
    mov [contact + ecx - 1], 0  ; Null-terminate

    mov edx, OFFSET addressPrompt
    call WriteString
    
    mov edx, OFFSET address
    mov ecx, SIZEOF address
    call ReadString
    mov [address + ecx - 1], 0  ; Null-terminate

    mov edx, OFFSET passPrompt
    call WriteString
    
    mov edx, OFFSET password
    mov ecx, SIZEOF password
    call ReadString
    mov [password + ecx - 1], 0  ; Null-terminate

    ; Encrypt password
    call EncryptPassword
    
    ; Save to file
    call SaveToFile
    
    mov edx, OFFSET successMsg
    call WriteString
    ret
SignUp ENDP

SignIn PROC
    push ebp
    mov ebp, esp    ; Set up stack frame
    
    mov edx, OFFSET emailPrompt
    call WriteString
    
    mov edx, OFFSET email
    mov ecx, SIZEOF email
    call ReadString    ; Read directly into email buffer
    
    mov edx, OFFSET passPrompt
    call WriteString
    
    mov edx, OFFSET password
    mov ecx, SIZEOF password
    call ReadString    ; Read directly into password buffer
    call encryptpassword
    call ValidateUser
    
    pop ebp
    ret
SignIn ENDP

EncryptPassword PROC
    push ebx            ; Save registers
    push esi
    push edi
    
    mov esi, OFFSET password
    mov edi, OFFSET encPassword
    xor ebx, ebx        ; Clear counter
    
EncryptLoop:
    mov al, [esi + ebx]
    cmp al, 0          ; Check for end of string
    je EncryptDone
    
    ; Simple encryption: XOR with fixed value
    xor al, 42
    mov [edi + ebx], al
    
    inc ebx
    jmp EncryptLoop
    
EncryptDone:
    mov BYTE PTR [edi + ebx], 0    ; Null terminate
    
    pop edi             ; Restore registers
    pop esi
    pop ebx
    ret
EncryptPassword ENDP

DecryptPassword PROC
    push ebx            ; Save registers
    push esi
    push edi
    
    mov esi, OFFSET encPassword
    mov edi, OFFSET password
    xor ebx, ebx        ; Clear counter
    
DecryptLoop:
    mov al, [esi + ebx]
    cmp al, 0          ; Check for end of string
    je DecryptDone
    
    ; Simple decryption: XOR with same value
    xor al, 42
    mov [edi + ebx], al
    
    inc ebx
    jmp DecryptLoop
    
DecryptDone:
    mov BYTE PTR [edi + ebx], 0    ; Null terminate
    
    pop edi             ; Restore registers
    pop esi
    pop ebx
    ret
DecryptPassword ENDP

CheckEmailExists PROC
    push ebp
    mov ebp, esp
    
    mov edx, OFFSET fileName
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je FileNotFound
    
    mov fileHandle, eax
    
    ; Clear tempEmail buffer
    mov edi, OFFSET tempEmail
    mov ecx, LENGTHOF tempEmail
    mov al, 0
    rep stosb
    
ReadLoop:
    mov eax, fileHandle
    mov edx, OFFSET readBuffer
    mov ecx, SIZEOF readBuffer
    call ReadFromFile
    mov bytesRead, eax
    cmp eax, 0
    je EndOfFile
    
    mov esi, OFFSET readBuffer
    xor ecx, ecx        ; Clear counter
    
ParseLoop:
    ; Skip username field
    .WHILE TRUE
        mov al, [esi + ecx]
        cmp al, 0
        je EndOfFile
        cmp al, '|'
        je ReadEmail
        inc ecx
    .ENDW
    
ReadEmail:
    inc ecx            ; Skip delimiter
    mov edi, OFFSET tempEmail
    xor edx, edx      ; Clear email length counter
    
    ; Read email from file
    .WHILE TRUE
        mov al, [esi + ecx]
        cmp al, '|'
        je CompareEmail
        cmp al, 0
        je EndOfFile
        mov [edi + edx], al
        inc ecx
        inc edx
        cmp edx, 49
        jae EndOfFile
    .ENDW
    
CompareEmail:
    mov BYTE PTR [edi + edx], 0    ; Null terminate
    
    push ecx
    mov esi, OFFSET email
    mov edi, OFFSET tempEmail
    call CompareStrings
    cmp eax, 1
    je EmailFound
    
    pop ecx
    mov esi, OFFSET readBuffer
    
    ; Skip to next line
    .WHILE TRUE
        mov al, [esi + ecx]
        cmp al, 0Ah
        je NextLine
        cmp al, 0
        je EndOfFile
        inc ecx
    .ENDW
    
NextLine:
    inc ecx
    jmp ParseLoop
    
EmailFound:
    pop ecx
    mov eax, 1          ; Email exists
    jmp CleanUp
    
EndOfFile:
FileNotFound:
    mov eax, 0          ; Email doesn't exist
    
CleanUp:
    push eax
    mov eax, fileHandle
    call CloseFile
    pop eax
    
    mov esp, ebp
    pop ebp
    ret
CheckEmailExists ENDP

SaveToFile PROC USES eax ebx ecx edx
    ;LOCAL fileHandle:DWORD
    
    ; Try to open file in append mode
    INVOKE CreateFile,
        ADDR fileName,          
        GENERIC_WRITE,          
        FILE_SHARE_READ,        
        NULL,                   
        OPEN_ALWAYS,           
        FILE_ATTRIBUTE_NORMAL,  
        0                      
        
    cmp eax, INVALID_HANDLE_VALUE
    je ErrorHandler
    mov fileHandle, eax
    
    ; Move to end of file
    INVOKE SetFilePointer,
        fileHandle,            
        0,                     
        0,                     
        FILE_END              
    
    ; Write username - only write actual length
    push eax
    mov edx, OFFSET username
    call StrLength     ; Get actual string length
    mov ecx, eax       ; Store length in ecx
    pop eax
    INVOKE WriteFile,
        fileHandle,           
        ADDR username,        
        ecx,                  ; Use actual length
        ADDR bytesRead,       
        0                     

    ; Write delimiter
    INVOKE WriteFile,
        fileHandle,
        ADDR delimiter,
        1,
        ADDR bytesRead,
        0

    ; Write email - only write actual length
    push eax
    mov edx, OFFSET email
    call StrLength
    mov ecx, eax
    pop eax
    INVOKE WriteFile,
        fileHandle,
        ADDR email,
        ecx,
        ADDR bytesRead,
        0

    ; Write delimiter
    INVOKE WriteFile,
        fileHandle,
        ADDR delimiter,
        1,
        ADDR bytesRead,
        0

    ; Write age - only write actual length
    push eax
    mov edx, OFFSET age
    call StrLength
    mov ecx, eax
    pop eax
    INVOKE WriteFile,
        fileHandle,
        ADDR age,
        ecx,
        ADDR bytesRead,
        0

    ; Write delimiter
    INVOKE WriteFile,
        fileHandle,
        ADDR delimiter,
        1,
        ADDR bytesRead,
        0

    ; Write contact - only write actual length
    push eax
    mov edx, OFFSET contact
    call StrLength
    mov ecx, eax
    pop eax
    INVOKE WriteFile,
        fileHandle,
        ADDR contact,
        ecx,
        ADDR bytesRead,
        0

    ; Write delimiter
    INVOKE WriteFile,
        fileHandle,
        ADDR delimiter,
        1,
        ADDR bytesRead,
        0

    ; Write address - only write actual length
    push eax
    mov edx, OFFSET address
    call StrLength
    mov ecx, eax
    pop eax
    INVOKE WriteFile,
        fileHandle,
        ADDR address,
        ecx,
        ADDR bytesRead,
        0

    ; Write delimiter
    INVOKE WriteFile,
        fileHandle,
        ADDR delimiter,
        1,
        ADDR bytesRead,
        0

    ; Write encrypted password - only write actual length
    push eax
    mov edx, OFFSET encPassword
    call StrLength
    mov ecx, eax
    pop eax
    INVOKE WriteFile,
        fileHandle,
        ADDR encPassword,
        ecx,
        ADDR bytesRead,
        0

    ; Write CRLF
    mov buffer[0], 0Dh
    mov buffer[1], 0Ah
    INVOKE WriteFile,
        fileHandle,
        ADDR buffer,
        2,
        ADDR bytesRead,
        0
    
    ; Close file
    INVOKE CloseHandle, fileHandle
    
    mov edx, OFFSET successMsg
    call WriteString
    mov eax, 1         ; Success
    ret
    
ErrorHandler:
    mov edx, OFFSET errorMsg
    call WriteString
    mov eax, 0         ; Failure
    ret
SaveToFile ENDP

ValidateUser PROC
    push ebp
    mov ebp, esp
    
    mov edx, OFFSET fileName
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je NotFound
    
    mov fileHandle, eax
    
    ; Clear buffers
    mov edi, OFFSET tempEmail
    mov ecx, LENGTHOF tempEmail
    mov al, 0
    rep stosb
    
    mov edi, OFFSET tempPass
    mov ecx, LENGTHOF tempPass
    mov al, 0
    rep stosb
    
    ; Read file content
    mov eax, fileHandle
    mov edx, OFFSET readBuffer
    mov ecx, SIZEOF readBuffer
    call ReadFromFile
    cmp eax, 0
    je NotFound
    mov bytesRead, eax
    
    mov readBuffer[eax], 0
    mov esi, OFFSET readBuffer
    xor ecx, ecx
    
ParseLine:
    ; Check for end of file
    cmp BYTE PTR [esi + ecx], 0
    je NotFound
    
    ; Skip username
    .WHILE BYTE PTR [esi + ecx] != '|'
        inc ecx
    .ENDW
    inc ecx    ; Skip delimiter
    
    ; Read email into tempEmail
    mov edi, OFFSET tempEmail
    xor edx, edx    ; Clear counter
    
ReadEmail:
    mov al, [esi + ecx]
    cmp al, '|'
    je CompareEmail
    mov [edi + edx], al
    inc ecx
    inc edx
    jmp ReadEmail
    
CompareEmail:
    mov BYTE PTR [edi + edx], 0    ; Null terminate
    
    ; Compare with user input
    push ecx
    mov edi, OFFSET tempEmail
    
    call crlf
    mov edx, OFFSET email
    
    
CompareLoop:
    mov al, [edi]
    mov bl, [edx]
    cmp al, bl
    jne NotMatched
    cmp al, 0
    je EmailMatched
    inc edi
    inc edx
    jmp CompareLoop
    
NotMatched:
    pop ecx
    
    ; Skip to next line
SkipLine:
    mov al, [esi + ecx]
    cmp al, 0
    je NotFound
    cmp al, 0Ah
    je NextLine
    inc ecx
    jmp SkipLine
    
NextLine:
    inc ecx
    jmp ParseLine
    
EmailMatched:
    pop ecx
    
    ; Skip next three fields (age, contact, address)
    mov edx, 4    ; Fields to skip
SkipFields:
    .WHILE BYTE PTR [esi + ecx] != '|'
        inc ecx
        push ecx

        pop ecx
    .ENDW

    inc ecx    ; Skip delimiter
    dec edx
    jnz SkipFields
    
    ; Read password
    mov edi, OFFSET tempPass
    xor edx, edx
    
ReadPassword:
    mov al, [esi + ecx]
    cmp al, 0Dh    ; CR
    je FoundPassword
    cmp al, 0Ah    ; LF
    je FoundPassword
    cmp al, 0      ; EOF
    je FoundPassword
    
    mov [edi + edx], al
    inc ecx
    inc edx
    jmp ReadPassword
    
FoundPassword:
    mov BYTE PTR [edi + edx], 0    ; Null terminate

    
    mov edx, OFFSET tempPass

     mov esi,offset encpassword
    mov edi ,offset tempPass
    call CompareStrings
    cmp eax,0
    je notfound
    jne yes
    
NotFound:
    mov edx, OFFSET loginfail
    call WriteString
    jmp Done

Error_Exit:
    mov edx, OFFSET errorMsg
    call WriteString
    jmp done
    yes:
    mov edx,offset loginsuccessmsg
    call writestring
    call crlf
   test eax,0
   jmp done
Done:
    mov eax, fileHandle
    call CloseFile

    cmp eax,0
    je en
    call printuserdetails

    en:
    pop eax
    
    mov esp, ebp
    pop ebp
    ret
ValidateUser ENDP
DisplayUserDetails PROC
    push eax
    push edx
    
    mov edx, OFFSET username
    call WriteString
    call Crlf
    mov edx, OFFSET email
    call WriteString
    call Crlf
    mov edx, OFFSET age
    call WriteString
    call Crlf
    mov edx, OFFSET contact
    call WriteString
    call Crlf
    mov edx, OFFSET address
    call WriteString
    call Crlf
    
    pop edx
    pop eax
    ret
DisplayUserDetails ENDP

CompareStrings PROC
    push esi
    push edi
    
CompareLoop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne NotEqual
    cmp al, 0
    je Equal
    inc esi
    inc edi
    jmp CompareLoop
    
NotEqual:
    mov eax, 0
    jmp Done
    
Equal:
    mov eax, 1
    
Done:
    pop edi
    pop esi
    ret
CompareStrings ENDP

OpenAppendFile PROC
    INVOKE CreateFile,
        edx,                    ; filename
        GENERIC_WRITE,          ; access mode
        0,                      ; share mode
        NULL,                   ; security attributes
        OPEN_EXISTING,          ; open existing file
        FILE_ATTRIBUTE_NORMAL,  ; normal file attribute
        0                      ; template file handle
    ret
OpenAppendFile ENDP

PrintUserDetails PROC
    mov edx, OFFSET fileName
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je NotFound

    mov fileHandle, eax

    ; Clear buffers
    mov edi, OFFSET tempEmail
    mov ecx, LENGTHOF tempEmail
    mov al, 0
    rep stosb

    mov edi, OFFSET tempPass
    mov ecx, LENGTHOF tempPass
    mov al, 0
    rep stosb

    ; Read file content
    mov eax, fileHandle
    mov edx, OFFSET readBuffer
    mov ecx, SIZEOF readBuffer
    call ReadFromFile
    cmp eax, 0
    je NotFound
    mov bytesRead, eax

    ; Null-terminate the buffer
    mov readBuffer[eax], 0
    mov esi, OFFSET readBuffer
    xor ecx, ecx

ParseLine:
    ; Check for end of buffer
    cmp BYTE PTR [esi + ecx], 0
    je NotFound

    ; Read username into buffer
    mov edi, OFFSET username
    xor edx, edx ; Clear counter

ReadUsername:
    mov al, [esi + ecx]
    cmp al, '|'
    je ReadEmail
    mov [edi + edx], al
    inc ecx
    inc edx
    jmp ReadUsername

ReadEmail:
    mov BYTE PTR [edi + edx], 0 ; Null terminate
    inc ecx ; Skip delimiter

    ; Read email into tempEmail
    mov edi, OFFSET tempEmail
    xor edx, edx ; Clear counter

ReadTempEmail:
    mov al, [esi + ecx]
    cmp al, '|'
    je CompareEmail
    mov [edi + edx], al
    inc ecx
    inc edx
    jmp ReadTempEmail

CompareEmail:
    mov BYTE PTR [edi + edx], 0 ; Null terminate

    ; Compare with user input email
    push ecx
    mov edi, OFFSET tempEmail
    mov edx, OFFSET email

CompareLoop:
    mov al, [edi]
    mov bl, [edx]
    cmp al, bl
    jne NotMatched
    cmp al, 0
    je EmailMatched
    inc edi
    inc edx
    jmp CompareLoop

NotMatched:
    pop ecx

    ; Skip to the next line
SkipLine:
    mov al, [esi + ecx]
    cmp al, 0
    je NotFound
    cmp al, 0Ah
    je NextLine
    inc ecx
    jmp SkipLine

NextLine:
    inc ecx
    jmp ParseLine

EmailMatched:
    pop ecx
    
    call crlf
    mov edx, offset userFoundMsg
    call writestring


    ; Print username
    mov edx,OFFSET printName
    call writestring
    mov edx, OFFSET username
    call WriteString
    call Crlf

    mov edx,OFFSET printEmail
    call writestring
    mov edx,offset tempemail
    call WriteString
    call Crlf

    ; Skip email field
    .WHILE BYTE PTR [esi + ecx ] != '|'
        inc ecx
    .ENDW
    inc ecx ; Skip delimiter

    ; Print age
    mov edx,OFFSET printAge
    call writestring
    mov edx, OFFSET age
    call PrintField

    ; Print contact
    mov edx,OFFSET printContact
    call writestring
    mov edx, OFFSET contact
    call PrintField

    ; Print address
    mov edx,OFFSET printAddress
    call writestring
    mov edx, OFFSET address
    call PrintField

    ; Print encrypted password and exit immediately
    mov edx,OFFSET printencpass
    call writestring
    mov edx, OFFSET tempPass
    call PrintField

    mov edx,OFFSET printorigpass
    call writestring
    mov edx, OFFSET password
    call writestring
    call crlf
    jmp Cleanup

PrintField:
    ; Clear buffer
    mov edi, edx
    xor edx, edx

FieldCopy:
    mov al, [esi + ecx]
    cmp al, '|'
    je FieldEnd
    cmp al,0ah
    je fieldend
    mov [edi + edx], al
    inc edx
    inc ecx
    jmp FieldCopy

FieldEnd:
    mov BYTE PTR [edi + edx], 0 ; Null terminate
    inc ecx ; Skip delimiter

    ; Print the field
    mov edx, edi
    call WriteString
    call Crlf
    ret

NotFound:
    mov edx, OFFSET notFoundMsg
    call WriteString
    jmp Cleanup

Cleanup:
    push eax
    mov eax, fileHandle
    call CloseFile
    pop eax
    ret
PrintUserDetails ENDP


END main
