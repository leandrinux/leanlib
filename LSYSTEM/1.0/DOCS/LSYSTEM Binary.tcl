# Reference Templates
# https://www.sweetscape.com/010editor/repository/files/BMP.bt
# https://raw.githubusercontent.com/synalysis/Grammars/master/bitmap.grammar

# Reference Documents
# http://www.digicamsoft.com/bmp/bmp.html
# http://en.wikipedia.org/wiki/BMP_file_format
#
# .types = ( bin );

set param_types [dict create \
    0 "Literal" \
    1 "Register" \
    2 "Address" \
    3 "Pointer" \
]

set registers [dict create \
    10 "SP" \
    32 "BP" \
    48 "IP" \
    64 "CC" \
	80 "EAX" \
	81 "AX" \
	82 "AH" \
	83 "AL" \
	96 "EBX" \
	97 "BX" \
	98 "BH" \
	99 "BL" \
	112 "ECX" \
	113 "CX" \
	114 "CH" \
	115 "CL" \
	128 "EDX" \
	129 "DX" \
	130 "DH" \
	131 "DL" \
	160 "CS" \
	161 "DS" \
	162 "SS" \
]

set opnames [dict create \
    1 MOV \
	2 ADD \
	3 SUB \
	4 MUL \
	5 DIV \
	6 CMP \
	7 SHL \
	8 SHR \
	9 FADD \
	10 FSUB \
	11 FMUL \
	12 FDIV \
	33 JMP \
	34 JE \
	35 JG \
	36 JL \
	37 JZ \
	38 JP \
	39 JN \
	40 JNZ \
	49 AND \
	50 OR \
	51 NOT \
	52 XOR \
	65 PUSH \
	66 POP \
	67 PUSHA \
	68 POPA \
	69 CALL \
	70 RET \
	81 OUT \
	82 IN \
]

little_endian
requires 0 "4C 53 59 53 42 49 4E"; # requires LSYSBIN
ascii 7 signature

for {set i 0} {![end]} {incr i} {
	section "Instruction" {
		set opcode [uint8]
		set opname [dict get $opnames $opcode]
		entry "opname" $opname

		set param0Type_n [uint8_bits 7,6,5,4]
		set param0Type [dict get $param_types $param0Type_n]
		entry "param 0 type" $param0Type
		move -1

		set param1Type_n [uint8_bits 3,2,1,0]
		set param1Type [dict get $param_types $param1Type_n]
		entry "param 1 type" $param1Type

		set param0 [uint32]
		set param1 [uint32]

		if {$param0Type == "Register"} {
			set register0 [dict get $registers $param0]
		    entry "param0" $register0
		} else {
			entry "param0" $param0
		}

		if {$param1Type == "Register"} {
			set register1 [dict get $registers $param1]
		    entry "param1" $register1
		} else {
			entry "param1" $param1
		}

	}
}