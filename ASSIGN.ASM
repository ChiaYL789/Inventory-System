.model small
.stack 100h
.data
        welcomemsg db 'Welcome to  ABC Inventory System!!!$'
        menumsg db 'Menu' ;
                db 10,'----';
                db 10, '1. Display items';
                db 10, '2  Make Sales';
                db 10, '3. Quit$'
	Header db 'P.Name		Qty	Price	Prior	Status$'
	Header2 db 'P.Name		Qty		O.Status$'
	Data db 'Apple,20,30.5,High,Finished';
	     db 10,'Book,4,10,Medium,Finished';
	     db 10, 'Chair,7,20,High,Finished';
	     db 10,'Duck,3,100,High,Finished';
	     db 10,'Egg,100,15,Low,Finished';
	     db 10,'Fish,10,30,Medium,Unfinished';
	     db 10,'Gas,30,50,Low,Unfinished';
	     db 10,'Hammer,10,40,Medium,Finished';
	     db 10,'Icecream,25,3.80,Low,Finished';
	     db 10,'Jacket,7,40,Medium,Unfinished$'
	SupplierOrder db 'Knife,100,Approve';
		      db 10,'Duck,10,Pending';
		      db 10,'Jacket,25,Pending';
		      db 10,'Chair,30,Approve';
		      db 10,'Lipstick,100,Rejected$'
	DisplayMsg db 'List';
		   db 10,'----';
		   db 10,'1.All';
		   db 10,'2.Priority';
		   db 10,'3.Status';
		   db 10,'4.SupplierOrder';
		   db 10,'5.Products to order$'
	Priority db 'Priority';
		 db 10,'------';
		 db 10,'1.High';
	 	 db 10,'2.Medium';
		 db 10,'3.Low$'
	Status db 'Status';
	       db 10,'------'
	       db 10,'1.Finished';
	       db 10,'2.Unfinished$'
	NewDataMsg db 'This is the new inventory!$'
	ItemToSales db 'Items for sale: $'
	userinput db 0
	Quantity db 0
	count db 0	
	countcomma db 0
	productnamelen db 0
	hpriority db 'High$'
	mpriority db 'Medium$'
	lpriority db 'Low$'
	fstatus db 'Finished$'
	Ustatus db 'Unfinished$'
	ProductNameList db 100 dup('$')
	RowNum db 0
	AskingForItem db 'Which item you choose?: $'
	AskingForQuantity db 'How much you want?: $'
	ProductName db 50,? , 50 dup('$')
	Salesamount db 50,? , 50 dup('$')
	InvalidName db 'This item is not in the list!$'
	InvalidQuantity db 'We do not have enough stock!$'
	TempQuantity db 5 dup('$')
	NewQuantity db 5 dup('$')
	TQlens db 0
	NQlens db 0
	NewData db 255 dup('$')
	
.code
 
ShowMsg Macro msg

        lea dx,msg
        mov ah,09h
        int 21h

endM
 
Newline Macro
        mov ah,02h
        mov dl,10
        int 21h

endM

 
HTab Macro

	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, 09     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

endM
 
DecideFunc Macro userinput

	cmp userinput,'1'
	je Dipath
 
	cmp userinput,'2'
	je Salespath
 
	cmp userinput,'3'
	je exit1
        jmp again  

endM

DisplayArray Macro 
	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0
	
CheckQty:
	mov al,Data[di]
	inc di
	cmp al,','
	je firstcomma
	jmp CheckQty

firstcomma:
	mov al,Data[di+1]
	cmp al,','
	je comparing
	jmp print_loop

comparing:
	mov al,Data[di]
	sub al,'0'
	cmp al,5
	jge print_loop

highlight:
	mov bx,1	
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je halfwaytoreset

	cmp al,'$'
	je halfwaytoend

	cmp al,','
	je equalcomma

	; Print the character
    	mov ah,09h
	mov bh,0  ;display a character at current page
        mov bl,4Fh ;3 is the background color and 1 is te foreground colour
	mov cx,1
	int 10h

	; Update the cursor position
	mov bh,00h
	mov ah,03h
	int 10h
	mov ah,02h
	mov bh,00h
	inc dl
	int 10h

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	jmp highlight

print_loop:
	mov bx,0
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je halfwaytoreset

	cmp al,'$'
	je halfwaytoend

	cmp al,','
	je equalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp print_loop


halfwaytonormalprint:
	jmp print_loop
halfwaytoend:
	jmp end_print
halfwaytoreset:
	jmp resetlength
halfwaytocheck:
	jmp CheckQty
halfwaytohighlight:
	jmp highlight

equalcomma:
	inc count
	cmp count,1
	je twotab

	HTab
	inc si

	cmp bx,1
	je halfwaytohighlight
	jmp halfwaytonormalprint

twotab:
	cmp productnamelen,8
	jge nametoolong
	
	HTab
	Htab	
	inc si
	
	cmp bx,1
	je halfwaytohighlight
	jmp halfwaytonormalprint

nametoolong:	
	Htab
	inc si
	
	cmp bx,1
	je halfwaytohighlight
	jmp halfwaytonormalprint

resetlength:
	inc di
	inc si
	Newline
	mov productnamelen,0
	mov count,0
	jmp halfwaytocheck

end_print:
endM

DisplaybasedonHPriority Macro

	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0

CheckHPriority:
	mov al,Data[di]
	inc di
	cmp al,','
	je HPcomma
	cmp al,'$'
	je HPhalfwaytoend1
	jmp CheckHPriority

HPcomma:
	inc countcomma
	cmp countcomma,3
	jne CheckHPriority

	mov al,Data[di]
	mov dl,hpriority[bx]
	cmp al,dl
	jne HPseekendofrow
	mov di,si
	jmp HPCheckQty

HPseekendofrow:
	mov al, Data[di]
	inc di
	cmp al,'$'
	je HPhalfwaytoend1
	cmp al, 10
	je HPnewrow
	jmp HPseekendofrow
	
HPnewrow:
	mov si,di
	mov bx,0
	mov countcomma,0
	jmp CheckHPriority
	
HPCheckQty:
	mov al,Data[di]
	inc di
	cmp al,','
	je HPfirstcomma
	jmp HPCheckQty

HPfirstcomma:
	mov al,Data[di+1]
	cmp al,','
	je HPcomparing
	jmp HPprint_loop

HPcomparing:
	mov al,Data[di]
	sub al,'0'
	cmp al,5
	jge HPprint_loop
	jmp HPhighlight

HPhalfwaytoend1:
	jmp HPhalfwaytoend

HPhighlight:
	mov bx,1	
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je HPhalfwaytoreset

	cmp al,'$'
	je HPhalfwaytoend

	cmp al,','
	je HPequalcomma

	; Print the character
    	mov ah,09h
	mov bh,0  ;display a character at current page
        mov bl,4Fh ;3 is the background color and 1 is te foreground colour
	mov cx,1
	int 10h

	; Update the cursor position
	mov bh,00h
	mov ah,03h
	int 10h
	mov ah,02h
	mov bh,00h
	inc dl
	int 10h

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	jmp HPhighlight

HPprint_loop:
	mov bx,0
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je HPhalfwaytoreset

	cmp al,'$'
	je HPhalfwaytoend

	cmp al,','
	je HPequalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp HPprint_loop


HPhalfwaytonormalprint:
	jmp HPprint_loop
HPhalfwaytoend:
	jmp HPend_print
HPhalfwaytoreset:
	jmp HPresetlength
HPhalfwaytocheck:
	jmp HPCheckQty
HPhalfwaytohighlight:
	jmp HPhighlight

HPequalcomma:
	inc count
	cmp count,1
	je HPtwotab

	HTab
	inc si

	cmp bx,1
	je HPhalfwaytohighlight
	jmp HPhalfwaytonormalprint

HPtwotab:
	cmp productnamelen,8
	jge HPnametoolong
	
	HTab
	Htab	
	inc si
	
	cmp bx,1
	je HPhalfwaytohighlight
	jmp HPhalfwaytonormalprint

HPnametoolong:	
	Htab
	inc si
	
	cmp bx,1
	je HPhalfwaytohighlight
	jmp HPhalfwaytonormalprint

HPresetlength:
	mov di,si
	inc di
	inc si
	Newline
	mov bx,0
	mov productnamelen,0
	mov countcomma,0
	mov count,0
	jmp CheckHPriority

HPend_print:
endM

DisplaybasedonMPriority Macro

	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0

CheckMPriority:
	mov al,Data[di]
	inc di
	cmp al,','
	je MPcomma
	cmp al,'$'
	je MPhalfwaytoend1
	jmp CheckMPriority

MPcomma:
	inc countcomma
	cmp countcomma,3
	jne CheckMPriority

	mov al,Data[di]
	mov dl,mpriority[bx]
	cmp al,dl
	jne MPseekendofrow
	mov di,si
	jmp MPCheckQty

MPseekendofrow:
	mov al, Data[di]
	inc di
	cmp al,'$'
	je MPhalfwaytoend1
	cmp al, 10
	je MPnewrow
	jmp MPseekendofrow
	
MPnewrow:
	mov si,di
	mov bx,0
	mov countcomma,0
	jmp CheckMPriority

	
MPCheckQty:
	mov al,Data[di]
	inc di
	cmp al,','
	je MPfirstcomma
	jmp MPCheckQty

MPfirstcomma:
	mov al,Data[di+1]
	cmp al,','
	je MPcomparing
	jmp MPprint_loop

MPcomparing:
	mov al,Data[di]
	sub al,'0'
	cmp al,5
	jge MPprint_loop
	jmp MPhighlight

MPhalfwaytoend1:
	jmp MPhalfwaytoend

MPhighlight:
	mov bx,1	
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je MPhalfwaytoreset

	cmp al,'$'
	je MPhalfwaytoend

	cmp al,','
	je MPequalcomma

	; Print the character
    	mov ah,09h
	mov bh,0  ;display a character at current page
        mov bl,4Fh ;3 is the background color and 1 is te foreground colour
	mov cx,1
	int 10h

	; Update the cursor position
	mov bh,00h
	mov ah,03h
	int 10h
	mov ah,02h
	mov bh,00h
	inc dl
	int 10h

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	jmp MPhighlight

MPprint_loop:
	mov bx,0
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je MPhalfwaytoreset

	cmp al,'$'
	je MPhalfwaytoend

	cmp al,','
	je MPequalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp MPprint_loop


MPhalfwaytonormalprint:
	jmp MPprint_loop
MPhalfwaytoend:
	jmp MPend_print
MPhalfwaytoreset:
	jmp MPresetlength
MPhalfwaytocheck:
	jmp MPCheckQty
MPhalfwaytohighlight:
	jmp MPhighlight

MPequalcomma:
	inc count
	cmp count,1
	je MPtwotab

	HTab
	inc si

	cmp bx,1
	je MPhalfwaytohighlight
	jmp MPhalfwaytonormalprint

MPtwotab:
	cmp productnamelen,8
	jge MPnametoolong
	
	HTab
	Htab	
	inc si
	
	cmp bx,1
	je MPhalfwaytohighlight
	jmp MPhalfwaytonormalprint

MPnametoolong:	
	Htab
	inc si
	
	cmp bx,1
	je MPhalfwaytohighlight
	jmp MPhalfwaytonormalprint

MPresetlength:
	mov di,si
	inc di
	inc si
	mov ah,02h
        mov dl,10
	mov bx,0
        int 21h
	mov productnamelen,0
	mov countcomma,0
	mov count,0
	jmp CheckMPriority

MPend_print:
endM

DisplaybasedonLPriority Macro

	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0

CheckLPriority:
	mov al,Data[di]
	inc di
	cmp al,','
	je LPcomma
	cmp al,'$'
	je LPhalfwaytoend1
	jmp CheckLPriority

LPcomma:
	inc countcomma
	cmp countcomma,3
	jne CheckLPriority

	mov al,Data[di]
	mov dl,lpriority[bx]
	cmp al,dl
	jne LPseekendofrow
	mov di,si
	jmp LPCheckQty

LPseekendofrow:
	mov al, Data[di]
	inc di
	cmp al,'$'
	je LPhalfwaytoend1
	cmp al, 10
	je LPnewrow
	jmp LPseekendofrow
	
LPnewrow:
	mov si,di
	mov bx,0
	mov countcomma,0
	jmp CheckLPriority

LPCheckQty:
	mov al,Data[di]
	inc di
	cmp al,','
	je LPfirstcomma
	jmp LPCheckQty

LPfirstcomma:
	mov al,Data[di+1]
	cmp al,','
	je LPcomparing
	jmp LPprint_loop

LPcomparing:
	mov al,Data[di]
	sub al,'0'
	cmp al,5
	jge LPprint_loop
	jmp LPhighlight

LPhalfwaytoend1:
	jmp LPhalfwaytoend

LPhighlight:
	mov bx,1	
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je LPhalfwaytoreset

	cmp al,'$'
	je LPhalfwaytoend

	cmp al,','
	je LPequalcomma

	; Print the character
    	mov ah,09h
	mov bh,0  ;display a character at current page
        mov bl,4Fh ;3 is the background color and 1 is te foreground colour
	mov cx,1
	int 10h

	; Update the cursor position
	mov bh,00h
	mov ah,03h
	int 10h
	mov ah,02h
	mov bh,00h
	inc dl
	int 10h

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	jmp LPhighlight

LPprint_loop:
	mov bx,0
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je LPhalfwaytoreset

	cmp al,'$'
	je LPhalfwaytoend

	cmp al,','
	je LPequalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp LPprint_loop


LPhalfwaytonormalprint:
	jmp LPprint_loop
LPhalfwaytoend:
	jmp LPend_print
LPhalfwaytoreset:
	jmp LPresetlength
LPhalfwaytocheck:
	jmp LPCheckQty
LPhalfwaytohighlight:
	jmp LPhighlight

LPequalcomma:
	inc count
	cmp count,1
	je LPtwotab

	HTab
	inc si

	cmp bx,1
	je LPhalfwaytohighlight
	jmp LPhalfwaytonormalprint

LPtwotab:
	cmp productnamelen,8
	jge LPnametoolong
	
	HTab
	Htab	
	inc si
	
	cmp bx,1
	je LPhalfwaytohighlight
	jmp LPhalfwaytonormalprint

LPnametoolong:	
	Htab
	inc si
	
	cmp bx,1
	je LPhalfwaytohighlight
	jmp LPhalfwaytonormalprint

LPresetlength:
	mov di,si
	inc di
	inc si
	mov ah,02h
        mov dl,10
	mov bx,0
        int 21h
	mov productnamelen,0
	mov countcomma,0
	mov count,0
	jmp CheckLPriority

LPend_print:
endM

DisplaybasedonFStatus Macro 
	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0

CheckFStatus:
	mov al,Data[di]
	inc di
	cmp al,','
	je FScomma
	cmp al,'$'
	je FShalfwaytoend1
	jmp CheckFStatus

FScomma:
	inc countcomma
	cmp countcomma,4
	jne CheckFStatus

	mov al,Data[di]
	mov dl,fstatus[bx]
	cmp al,dl
	jne FSseekendofrow
	mov di,si
	jmp FSCheckQty

FSseekendofrow:
	mov al, Data[di]
	inc di
	cmp al,'$'
	je FShalfwaytoend1
	cmp al, 10
	je FSnewrow
	jmp FSseekendofrow
	
FSnewrow:
	mov si,di
	mov bx,0
	mov countcomma,0
	jmp CheckFStatus
	
FSCheckQty:
	mov al,Data[di]
	inc di
	cmp al,','
	je FSfirstcomma
	jmp FSCheckQty

FSfirstcomma:
	mov al,Data[di+1]
	cmp al,','
	je FScomparing
	jmp FSprint_loop

FScomparing:
	mov al,Data[di]
	sub al,'0'
	cmp al,5
	jge FSprint_loop
	jmp FShighlight

FShalfwaytoend1:
	jmp FShalfwaytoend

FShighlight:
	mov bx,1	
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je FShalfwaytoreset

	cmp al,'$'
	je FShalfwaytoend

	cmp al,','
	je FSequalcomma

	; Print the character
    	mov ah,09h
	mov bh,0  ;display a character at current page
        mov bl,4Fh ;3 is the background color and 1 is te foreground colour
	mov cx,1
	int 10h

	; Update the cursor position
	mov bh,00h
	mov ah,03h
	int 10h
	mov ah,02h
	mov bh,00h
	inc dl
	int 10h

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	jmp FShighlight

FSprint_loop:
	mov bx,0
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je FShalfwaytoreset

	cmp al,'$'
	je FShalfwaytoend

	cmp al,','
	je FSequalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp FSprint_loop


FShalfwaytonormalprint:
	jmp FSprint_loop
FShalfwaytoend:
	jmp FSend_print
FShalfwaytoreset:
	jmp FSresetlength
FShalfwaytocheck:
	jmp FSCheckQty
FShalfwaytohighlight:
	jmp FShighlight

FSequalcomma:
	inc count
	cmp count,1
	je FStwotab

	HTab
	inc si

	cmp bx,1
	je FShalfwaytohighlight
	jmp FShalfwaytonormalprint

FStwotab:
	cmp productnamelen,8
	jge FSnametoolong
	
	HTab
	Htab	
	inc si
	
	cmp bx,1
	je FShalfwaytohighlight
	jmp FShalfwaytonormalprint

FSnametoolong:	
	Htab
	inc si
	
	cmp bx,1
	je FShalfwaytohighlight
	jmp FShalfwaytonormalprint

FSresetlength:
	mov di,si
	inc di
	inc si
	mov ah,02h
        mov dl,10
	mov bx,0
        int 21h
	mov productnamelen,0
	mov countcomma,0
	mov count,0
	jmp CheckFStatus

FSend_print:
endM

DisplaybasedonUStatus Macro 
	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0

CheckUStatus:
	mov al,Data[di]
	inc di
	cmp al,','
	je UScomma
	cmp al,'$'
	je UShalfwaytoend1
	jmp CheckUStatus

UScomma:
	inc countcomma
	cmp countcomma,4
	jne CheckUStatus

	mov al,Data[di]
	mov dl,ustatus[bx]
	cmp al,dl
	jne USseekendofrow
	mov di,si
	jmp USCheckQty

USseekendofrow:
	mov al, Data[di]
	inc di
	cmp al,'$'
	je UShalfwaytoend1
	cmp al, 10
	je USnewrow
	jmp USseekendofrow
	
USnewrow:
	mov si,di
	mov bx,0
	mov countcomma,0
	jmp CheckUStatus

USCheckQty:
	mov al,Data[di]
	inc di
	cmp al,','
	je USfirstcomma
	jmp USCheckQty

USfirstcomma:
	mov al,Data[di+1]
	cmp al,','
	je UScomparing
	jmp USprint_loop

UScomparing:
	mov al,Data[di]
	sub al,'0'
	cmp al,5
	jge USprint_loop
	jmp UShighlight

UShalfwaytoend1:
	jmp UShalfwaytoend

UShighlight:
	mov bx,1	
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je UShalfwaytoreset

	cmp al,'$'
	je UShalfwaytoend

	cmp al,','
	je USequalcomma

	; Print the character
    	mov ah,09h
	mov bh,0  ;display a character at current page
        mov bl,4Fh ;3 is the background color and 1 is te foreground colour
	mov cx,1
	int 10h

	; Update the cursor position
	mov bh,00h
	mov ah,03h
	int 10h
	mov ah,02h
	mov bh,00h
	inc dl
	int 10h

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	jmp UShighlight

USprint_loop:
	mov bx,0
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je UShalfwaytoreset

	cmp al,'$'
	je UShalfwaytoend

	cmp al,','
	je USequalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp USprint_loop

UShalfwaytonormalprint:
	jmp USprint_loop
UShalfwaytoend:
	jmp USend_print
UShalfwaytoreset:
	jmp USresetlength
UShalfwaytocheck:
	jmp USCheckQty
UShalfwaytohighlight:
	jmp UShighlight

USequalcomma:
	inc count
	cmp count,1
	je UStwotab

	HTab
	inc si

	cmp bx,1
	je UShalfwaytohighlight
	jmp UShalfwaytonormalprint

UStwotab:
	cmp productnamelen,8
	jge USnametoolong
	
	HTab
	Htab	
	inc si
	
	cmp bx,1
	je UShalfwaytohighlight
	jmp UShalfwaytonormalprint

USnametoolong:	
	Htab
	inc si
	
	cmp bx,1
	je UShalfwaytohighlight
	jmp UShalfwaytonormalprint

USresetlength:
	mov di,si
	inc di
	inc si
	mov ah,02h
        mov dl,10
	mov bx,0
        int 21h
	mov productnamelen,0
	mov countcomma,0
	mov count,0
	jmp CheckUStatus

USend_print:
endM

DisplayItemNeedtobeOrdered Macro

	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0
	
CheckINTBOQty:
	mov al,Data[di]
	inc di
	cmp al,','
	je INTBOfirstcomma
	jmp CheckINTBOQty

INTBOfirstcomma:
	mov al,Data[di+1]
	cmp al,','
	je INTBOcomparing
	jmp INTBOseekendofnow

INTBOcomparing:
	mov al,Data[di]
	sub al,'0'
	cmp al,5
	jge INTBOseekendofnow
	jmp INTBOprint_loop

INTBOseekendofnow:
	mov al, Data[di]
	inc di
	cmp al,'$'
	je INTBOhalfwaytoend
	cmp al, 10
	je INTBOnextrow
	jmp INTBOseekendofnow
	
INTBOnextrow:
	mov si,di
	mov bx,0
	mov countcomma,0
	jmp CheckINTBOQty

INTBOprint_loop:
	mov bx,0
	mov di, si
	mov al,Data[si]
	
	cmp al,10
	je INTBOhalfwaytoreset

	cmp al,'$'
	je INTBOhalfwaytoend

	cmp al,','
	je INTBOequalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp INTBOprint_loop


INTBOhalfwaytonormalprint:
	jmp INTBOprint_loop
INTBOhalfwaytoend:
	jmp INTBOend_print
INTBOhalfwaytoreset:
	jmp INTBOresetlength
INTBOhalfwaytocheck:
	jmp CheckINTBOQty

INTBOequalcomma:
	inc count
	cmp count,1
	je INTBOtwotab

	HTab
	inc si

	jmp INTBOhalfwaytonormalprint


INTBOtwotab:
	cmp productnamelen,8
	jge INTBOnametoolong
	
	HTab
	Htab	
	inc si

	jmp INTBOhalfwaytonormalprint

INTBOnametoolong:	
	Htab
	inc si

	jmp INTBOhalfwaytonormalprint

INTBOresetlength:
	inc di
	inc si
	Newline
	mov productnamelen,0
	mov count,0
	jmp INTBOhalfwaytocheck

INTBOend_print:
endM

DisplaySupplierOrder Macro
	ShowMsg Header2
	Newline

	mov si,0 

SOprint_loop:
	mov al,SupplierOrder[si]
	
	cmp al,10
	je SOreset

	cmp al,'$'
	je SOendprint

	cmp al,','
	je SOequalcomma

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	
    	; Repeat the loop to print the next character
    	jmp SOprint_loop


SOequalcomma:
	inc count
	cmp count,1
	je SOtwotab

	HTab
	HTab
	inc si
	jmp SOprint_loop

SOtwotab:
	cmp productnamelen,8
	jge SOnametoolong
	
	HTab
	Htab	
	inc si
	jmp SOprint_loop
	
SOnametoolong:
	HTab
	inc si
	jmp SOprint_loop

SOreset:
	mov productnamelen,0
	inc si
	Newline
	mov count,0
	jmp SOprint_loop

SOendprint:
endM

DisplayItemForSales Macro
	mov si,0
	mov di,0
	mov bx,0

IFSCheckStatus:
	mov al,Data[di]
	inc di
	cmp al,','
	je IFScomma
	jmp IFSCheckStatus

IFScomma:
	inc countcomma
	cmp countcomma,4
	jne IFSCheckStatus

	inc RowNum
	mov al,Data[di]
	mov dl,fstatus[bx]
	cmp al,dl
	jne IFSseekendofrow
	cmp RowNum,1
	je IFSResetposition
	jmp IFSRightposition

IFSseekendofrow:
	mov al, Data[di]
	inc di
	cmp al, 10
	je IFSnewrow
	cmp al,'$'
	jne IFSseekendofrow
	dec si
	jmp IFSStoringDone
	
IFSnewrow:
	mov bx,0
	mov countcomma,0
	jmp IFSCheckStatus

IFSResetposition:
	mov di,0
	jmp IFSStoreName

IFSRightposition:
	dec di
	mov al, Data[di]
	cmp al,10
	jne IFSRightposition
	inc di	
	
IFSStoreName:
	mov al,Data[di]
	cmp al,','
	je IFSNextrow
	mov ProductNameList[si],al
	inc di
	inc si
	jmp IFSStoreName

IFSNextrow:
	mov al,Data[di]
	inc di
	mov bx,0
	mov countcomma,0
	cmp al,'$'
	je IFSStoringDone
	cmp al,10
	je IFSStoreComma
	jmp IFSNextrow

IFSStoreComma:
	mov ProductNameList[si],','
	inc si
	jmp IFSCheckStatus
	
IFSStoringDone:
	mov ProductNameList[si],'$'
	ShowMsg ItemToSales
	ShowMsg ProductNameList	
endM

ValidateProductNameInput Macro
 
AskingInput:
	ShowMsg AskingForItem
	mov ah,0Ah
	lea dx,ProductName
	int 21h

	mov si,0
	mov di,2

CompareName:
	mov al,ProductNameList[si]
	mov dl,ProductName[di]
	inc di
	inc si
	cmp al,','
	je ValidDone
	cmp al,'$'
	je ValidDone
	cmp al,dl
	jne NextName
	jmp CompareName

NextName:
	mov al,ProductNameList[si]
	mov di,2
	inc si
	cmp al,','
	je CompareName
	cmp al,'$'
	je InvalidInput
	jmp NextName

InvalidInput:
	ShowMsg InvalidName
	Newline
	jmp AskingInput
ValidDone:
endM

ValidateProductQuantity Macro

AskingQInput:
	Newline
	ShowMsg AskingForQuantity
	mov ah,0Ah
	lea dx,Salesamount
	int 21h
	
	mov TQlens,0
	mov NQlens,-1
	mov si,0
	mov di,2

CheckName:
	mov al,Data[si]
	mov dl,ProductName[di]
	inc si
	inc di
	cmp al,','
	je StoreCurrentQuantity
	cmp al,dl
	jne NextrowInData
	jmp CheckName
	
NextrowInData:
	mov di,2
	mov al,Data[si]
	inc si
	cmp al,10
	je CheckName
	cmp al,'$'
	je halfwaytodone
	jmp NextrowInData

StoreCurrentQuantity:
	mov di,0
L1:
	mov al,Data[si]
	cmp al,','
	je DoneStoringCurrentQuantity
	mov TempQuantity[di],al
	inc si
	inc di
	inc TQlens
	jmp L1

DoneStoringCurrentQuantity:
	
	mov di,2
	mov si,0
	jmp StoreInput

halfwaytodone:
	jmp ValidQDone

StoreInput:
	mov al,Salesamount[di]
	cmp al,'$'
	je CheckTQlen
	mov NewQuantity[si],al
	inc di
	inc si
	inc NQlens
	jmp StoreInput


CheckTQlen:	
	cmp TQlens,1
	je OneDigitNQlen

	cmp TQlens,2
	je OneTwoDigitNQLen

	cmp TQlens,3
	je ThreeDigitTQlenAndOneTwoDigitNQLen
	jmp ValidQDone

OneDigitNQlen:
	cmp NQlens,1
	je BothOneDigit
	jmp InvalidQInput
	
OneTwoDigitNQLen:
	cmp NQlens,1
	je TQTwoDigitNQOneDigit
	
	cmp NQlens,2
	je TQTwoDigitNQTwoDigit
	jmp InvalidQInput

ThreeDigitTQlenAndOneTwoDigitNQLen:
	cmp NQlens,1
	je halfwaytoCompareThreeOne

	cmp NQlens,2
	je halfwaytoCompareThreeTwo
	jmp InvalidQInput

BothOneDigit:
	mov dl,NewQuantity[0]
	mov al,TempQuantity[0]
	sub al,'0'
	sub dl,'0'
	sub al,dl
	js halfwaytoinvalid
	add al,'0'
	mov NewQuantity[0],al
	Newline
	ShowMsg NewQuantity
	jmp ValidQDone

TQTwoDigitNQOneDigit:
	mov al,TempQuantity[0]
	sub al,'0'
	mov ah,10
	mul ah
	mov dl,TempQuantity[1]
	sub dl,'0'
	add al,dl

	mov dl,NewQuantity[0]
	sub dl,'0'
	sub al,dl
	js halfwaytoinvalid
	cmp al, 10
	jl halfwaytoOD
	jmp TwoDigits

halfwaytoinvalid:
	jmp halfwaytoinvalid1
halfwaytoCompareThreeone:
	jmp TQThreeDigitNQOneDigit
halfwaytoCompareThreeTwo:
	jmp TQThreeDigitNQTwoDigit
	
TQTwoDigitNQTwoDigit:
	mov al,NewQuantity[0]
	sub al,'0'
	mov ah,10
	mul ah
	mov dl,NewQuantity[1]
	sub dl,'0'
	add al,dl

	mov bl,al

	mov al,TempQuantity[0]
	sub al,'0'
	mov ah,10
	mul ah
	mov dl,TempQuantity[1]
	sub dl,'0'
	add al,dl

	sub al,bl
	js halfwaytoinvalid2
	cmp al,10
	jl OneDigit
	jmp TwoDigits

TQThreeDigitNQOneDigit:
	mov al, TempQuantity[0] ; Load hundreds place
	sub al, '0'              ; Convert from ASCII to binary
	mov ah, 100
	mul ah                   ; Multiply by 100 (10 * 10)
	mov bh, al               ; Store result in BH

	mov al, TempQuantity[1]  ; Load tens place
	sub al, '0'              ; Convert from ASCII to binary
	mov ah, 10
	mul ah                   ; Multiply by 10
	add bh, al               ; Add to previous result

	mov al, TempQuantity[2]  ; Load ones place
	sub al, '0'              ; Convert from ASCII to binary
	add bh, al               ; Add to previous result
	
	mov al,bh ;Move the value in tempquantity to al

	mov dl,NewQuantity[0]
	sub dl,'0'
	sub al,dl
	js halfwaytoinvalid
	cmp al, 10
	jl OneDigit
	jmp TwoDigits

halfwaytoOD:
	jmp OneDigit

TQThreeDigitNQTwoDigit:
	mov al,NewQuantity[0]
	sub al,'0'
	mov ah,10
	mul ah

	mov dl,NewQuantity[1]
	sub dl,'0'
	add al,dl
	
	mov bl, al ;Store al value to bl

	mov al, TempQuantity[0] ; Load hundreds place
	sub al, '0'              ; Convert from ASCII to binary
	mov ah, 100
	mul ah                   ; Multiply by 100 (10 * 10)
	mov bh, al               ; Store result in BH

	mov al, TempQuantity[1]  ; Load tens place
	sub al, '0'              ; Convert from ASCII to binary
	mov ah, 10
	mul ah                   ; Multiply by 10
	add bh, al               ; Add to previous result

	mov al, TempQuantity[2]  ; Load ones place
	sub al, '0'              ; Convert from ASCII to binary
	add bh, al               ; Add to previous result
	
	mov al,bh ;Store bh value to al

	sub al,bl
	js halfwaytoinvalid1
	cmp al, 10
	jl OneDigit
	jmp TwoDigits

halfwaytoinvalid2:
	jmp halfwaytoinvalid1
	
OneDigit:
	; handle one-digit result
	add al, '0'
	mov NewQuantity[0], al
	mov NewQuantity[1],'$'
	mov NQlens,1
	Newline
	ShowMsg NewQuantity
	jmp ValidQDone

halfwaytoinvalid1:
	jmp InvalidQInput

TwoDigits:
	; handle two-digit result
	aam 10
	add al, '0'
	add ah, '0'
	mov NewQuantity[0], ah ; store tens place
	mov NewQuantity[1], al ; store ones place
	mov NQlens,2
	Newline
	ShowMsg NewQuantity
	jmp ValidQDone

InvalidQInput:
	ShowMsg InvalidQuantity
	mov si, offset Salesamount ; Get the address of Salesamount
	mov cx, 50 ; Set CX to the length of Salesamount

ResetLoop:
    	mov byte ptr [si], '$' ; Set the current byte to '$'
    	inc si ; Move to the next byte
    	loop ResetLoop ; Repeat until CX is zero
	jmp AskingQInput
	
ValidQDone:
endM


MakeSales Macro
	DisplayItemForSales
	NewLine

	ValidateProductNameInput
	ValidateProductQuantity

	mov si,0
	mov di,0
	mov bx,2

StoringnewData:
	mov al,Data[si]
	mov dl,ProductName[bx]
	mov NewData[di],al
	inc si
	inc di
	inc bx
	cmp al,','
	je StoreNewQuantity
	cmp al,dl
	jne nextrow2
	jmp StoringnewData

StoreNewQuantity:
	cmp NQlens,2
	je NewQuantityTwoDigit
	jmp NewQuantityOneDigit
	NewQuantityTwoDigit:
		mov al,NewQuantity[0]
		mov NewData[di],al
		inc di

		mov al,NewQuantity[1]
		mov NewData[di],al
		inc di
		jmp Nextpart
	NewQuantityOneDigit:
		mov al,NewQuantity[0]
		mov NewData[di],al
		inc di
		jmp Nextpart
Nextpart:
	mov NewData[di],','
	inc di
	L3:
		mov al,Data[si]
		inc si
		cmp al,','
		je nextrow2
		jmp L3
	
nextrow2:
	mov al,Data[si]
	mov NewData[di],al
	inc si
	inc di
	cmp al,10
	je Resetdi
	cmp al,'$'
	je DoneSales
	jmp nextrow2

Resetdi:
	mov bx,2
	jmp StoringnewData	

DoneSales:
	Newline
	ShowMsg NewDataMsg
	Newline
	ShowMsg Header
	Newline

	mov si,0  
	mov di,0
	mov bx,0
	
CheckQty2:
	mov al,NewData[di]
	inc di
	cmp al,','
	je firstcomma2
	jmp CheckQty2

firstcomma2:
	mov al,NewData[di+1]
	cmp al,','
	je comparing2
	jmp print_loop2

comparing2:
	mov al,NewData[di]
	sub al,'0'
	cmp al,5
	jge print_loop2

highlight2:
	mov bx,1	
	mov di, si
	mov al,NewData[si]
	
	cmp al,10
	je halfwaytoreset2

	cmp al,'$'
	je halfwaytoend2

	cmp al,','
	je equalcomma2

	; Print the character
    	mov ah,09h
	mov bh,0  ;display a character at current page
        mov bl,4Fh ;3 is the background color and 1 is te foreground colour
	mov cx,1
	int 10h

	; Update the cursor position
	mov bh,00h
	mov ah,03h
	int 10h
	mov ah,02h
	mov bh,00h
	inc dl
	int 10h

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen

	jmp highlight2

print_loop2:
	mov bx,0
	mov di, si
	mov al,NewData[si]
	
	cmp al,10
	je halfwaytoreset2

	cmp al,'$'
	je halfwaytoend2

	cmp al,','
	je equalcomma2

    	; Print the character
    	mov ah, 02h    ; DOS function for displaying a character
    	mov dl, al     ; Load the character to be displayed into DL
    	int 21h        ; Call interrupt 21h to display the character

   	; Move to the next character in the buffer
    	inc si
	inc productnamelen
	
    	; Repeat the loop to print the next character
    	jmp print_loop2


halfwaytonormalprint2:
	jmp print_loop2
halfwaytoend2:
	jmp end_print2
halfwaytoreset2:
	jmp resetlength2
halfwaytocheck2:
	jmp CheckQty2
halfwaytohighlight2:
	jmp highlight2

equalcomma2:
	inc count
	cmp count,1
	je twotab2

	HTab
	inc si

	cmp bx,1
	je halfwaytohighlight2
	jmp halfwaytonormalprint2

twotab2:
	cmp productnamelen,8
	jge nametoolong2
	
	HTab
	Htab	
	inc si
	
	cmp bx,1
	je halfwaytohighlight2
	jmp halfwaytonormalprint2

nametoolong2:	
	Htab
	inc si
	
	cmp bx,1
	je halfwaytohighlight2
	jmp halfwaytonormalprint2

resetlength2:
	inc di
	inc si
	Newline
	mov productnamelen,0
	mov count,0
	jmp halfwaytocheck2

end_print2:
endM

main proc
        ;Assign data to ds
        mov ax,@data
        mov ds,ax
	mov es,ax
 
	;Display Welcome Msg
again:  
	ShowMsg welcomemsg
        Newline
 
        ;Display Menu Msg
  	ShowMsg menumsg

        Newline
 
 
        ;Read userinput
	mov ah, 00h
    	int 16h

	mov userinput, al

	;Display userinput
	mov ah,02h
	mov dl,userinput
	int 21h

	Newline	
	DecideFunc userinput
 
exit1:
	jmp exit2	

Dipath:
	jmp Displayitem
 
Salespath:
	jmp Sales
 
Displayitem: 
	ShowMsg DisplayMsg
	Newline
Loop1:
	mov ah,01h
	mov userinput,al
	int 21h
	
	cmp userinput,'1'
	je DisplayAll
	
	cmp userinput,'2'
	je halfwaytoPBDP
	
	cmp userinput,'3'
	je halfwaytoPBDS

	cmp userinput,'4'
	je halfwaytoPSO

	cmp userinput,'5'
	je halfwaytoPTO
	jmp Loop1

halfwaytoPBDP:
	jmp PrintBasedonPriorty
halfwaytoPBDS:
	jmp PrintbasedonStatus
halfwaytoPSO:
	jmp PrintSupplierOrder
halfwaytoPTO:
	jmp ProductToOrder

DisplayAll:
	Newline
	DisplayArray
	jmp exit2

PrintBasedonPriorty:
	Newline
	ShowMsg Priority
	Newline
	Loop2:
		;Read userinput
		mov ah,01h
		mov userinput,al
		int 21h

		cmp userinput,'1'
		je PriorityHigh
	
		cmp userinput,'2'
		je halfwaytoPM

		cmp userinput,'3'
		je halfwaytoPL
		jmp Loop2
	halfwaytoPM:
		jmp PriorityMedium
	halfwaytoPL:
		jmp PriorityLow
	PriorityHigh:
		Newline
		DisplaybasedonHPriority 
		jmp exit2
	PriorityMedium:
		Newline
		DisplaybasedonMPriority 
		jmp exit2
	PriorityLow:
		Newline
		DisplaybasedonLPriority 
		jmp exit2

PrintbasedonStatus:
	Newline
	ShowMsg Status
	Newline
	Loop3:
		;Read userinput
		mov ah,01h
		mov userinput,al
		int 21h

		cmp userinput,'1'
		je StatusFinished
	
		cmp userinput,'2'
		je halfwaytoSU
		jmp Loop3
 	halfwaytoSU:
		jmp StatusUnfinished
	StatusFinished:
		Newline
		DisplaybasedonFStatus 
		jmp exit2
	StatusUnfinished:
		Newline
		DisplaybasedonUStatus 
		jmp exit2

PrintSupplierOrder:
	Newline
	DisplaySupplierOrder
	jmp exit2
ProductToOrder:
	Newline
	DisplayItemNeedtobeOrdered
	jmp exit2
Sales: 
	MakeSales
        jmp exit2
 
exit2:  
	mov ah,4ch
        int 21h

main endp
end main
