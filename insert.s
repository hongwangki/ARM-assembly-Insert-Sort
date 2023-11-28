	AREA code_area, CODE, READONLY
      ENTRY

float_number_series EQU 0x0450
sorted_number_series EQU 0x00018AEC
final_result_series EQU 0x00031190

;========== Do not change this area ===========

initialization
   LDR r0, =0xDEADBEEF            ; seed for random number
   LDR r1, =float_number_series   
   LDR r2, =10000         ; The number of element in stored sereis
   LDR r3, =0x0EACBA90            ; constant for random number

save_float_series
   CMP r2, #0
   BEQ is_init
   BL random_float_number
   STR r0, [r1], #4
   SUB r2, r2, #1
   MOV r5, #0
   B save_float_series

random_float_number
   MOV r5, LR
   EOR r0, r0, r3
   EOR r3, r0, r3, ROR #2
   CMP r0, r1
   BLGE shift_left
   BLLT shift_right
   BX r5

shift_left
   LSL r0, r0, #1
   BX LR

shift_right
   LSR r0, r0, #1
   BX LR
   
;============================================

;========== Start your code here ===========
   
is_init
    MOV r0, #1
    LDR r1, =float_number_series    ;r1 save float_number_series 
    LDR r2, =final_result_series    ;r2 save r2, =final_result_series 
    LDR r0, [r1], #4    ;r0 save r1 and memory 4 MOVE
    STR r0, [r2]    ;Insert r0 into r2 memory
    LDR r3,=10000   ;Number of random number generations
    MOV r4, #0             ;r4=0 (count register)
    MOV r7, #4  ; memory point register

   LDR r9, =final_result_series  ;memory remember register
outer_loop
    LDR r5, [r1], #4    ;LOAD r1 memory data into r5 and 4 memory move
    ADD r4, r4, #1  ;count++
    CMP r4, r3  ;if count= 10000 => exit
    BEQ exit
    LDR r8, [r2],#4     ;LOAD r2 memory data into r8 and 4 memory move
	MOV r7,r2       ; remember r2 memeory Location
    B check_signbit     ; go cheack sign bit

;If the insertion position is determined
rslt_check_nonchange
	STR r5, [r2]   ;r5 data insert r2 memmory
    LDR r8, [r2], r7    ;Move the r2 memory position by r7
	MOV r2 ,r7   ;r2=r7
    B outer_loop    ;Repeat after insertion is completed

;If it needs to change compared to previous data
rslt_check_change
    ;repositioning data
    STR r8,[r2],#-4
    STR r5,[r2],#-4
    
    LDR r8,[r2],#4  ;memory move 4
	
    ;After comparing the data to the end
    CMP r2, r9
	MOVEQ r2, r7
	BEQ	outer_loop
	
    ;go check_signbit

;cheack sign bit
check_signbit
    ;r10= r5 sign bit
    MOV r10, r5
    MOV r10, r10, LSR #31
    ;r11= r5 sign bit
    MOV r11, r8
    MOV r11, r11, LSR#31
    
    
    CMP r10, r11
    ;if (r10<r11)
    BLLT rslt_check_nonchange
    ;if (r10>r11)
    BLGT rslt_check_change

    ;if r10 = r11 => go exponent

check_exponent
    ;r11 and r10 ALL negative case
    ADD r10,r10,r11
    CMP r10, #2
    BEQ cheak_miexponent

    //r10= r5 exponent
    MOV r10,r5,LSR #23
    AND r10, r10,#255

    //r11= r8 exponent
    MOV r11,r8,LSR #23
    AND r11, r11,#255

    CMP r10, r11
    ;if (r10>r11)
    BLGT rslt_check_nonchange
    ;if (r10<r11)
    BLLT rslt_check_change
    ;if (r10=r11)
    B check_mentissa

; two data all negative case compare exponent
cheak_miexponent    ;minus exponent
    //r10= r8 exponent
    MOV r10,r8,LSR #23
    AND r10, r10,#255

    //r11= r5 exponent
    MOV r11,r5,LSR #23
    AND r11, r11,#255

    CMP r10, r11
    ;if (r10>r11)
    BLGT rslt_check_nonchange
    ;if (r10<r11)
    BLLT rslt_check_change
    ;if (r10=r11)
    B cheak_mimentissa  ;go minus case mentissa

; tow data same sign and exponet case
;chenk two data mentissa
check_mentissa
    ;r10= r5 mentissa
    MOV r10, r5, LSL#9
    MOV r10, r10, LSR#9
    //r1=r8 mentissa
    MOV r11, r8, LSL#9
    MOV r11, r11, LSR#9
    
    CMP r10, r11
    ;if (r10>=r11)
    BLGE rslt_check_nonchange
     ;if (r10<r11)
    BLLT rslt_check_change

; tow data minus case cheak mentissa
cheak_mimentissa
    ;r10= r8 mentissa
    MOV r10, r8, LSL#9
    MOV r10, r10, LSR#9
   ;r11= r5 mentissa
    MOV r11, r5, LSL#9
    MOV r11, r11, LSR#9
    
    CMP r10, r11
     ;if (r10>=r11)
    BLGE rslt_check_nonchange
    ;if (r10<r11)
    BLLT rslt_check_change

exit
	MOV pc, #0
    END
;==============End your code here=============== 