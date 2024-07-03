# Reference Templates
# https://www.sweetscape.com/010editor/repository/files/BMP.bt
# https://raw.githubusercontent.com/synalysis/Grammars/master/bitmap.grammar

# Reference Documents
# http://www.digicamsoft.com/bmp/bmp.html
# http://en.wikipedia.org/wiki/BMP_file_format
#
# .types = ( bin );

set param_types [dict create \
    0 literal \
    1 register \
    2 address \
    3 pointer \
]	

little_endian
requires 0 "4C 53 59 53 42 49 4E"; # requires LSYSBIN
ascii 7 signature

for {set i 0} {![end]} {incr i} {
	section "Instruction" {
		hex 1 "opcode"

		set param0Type_n [uint8_bits 7,6,5,4]
		set param0Type [dict get $param_types $param0Type_n]
		entry "param 0 type" $param0Type
		move -1

		set param0Type_n [uint8_bits 3,2,1,0]
		set param0Type [dict get $param_types $param0Type_n]
		entry "param 1 type" $param0Type

		hex 4 "param0 (hex)"
		move -4 
		uint32 "param0 (dec)"
		hex 4 "param1 (hex)"
		move -4 
		uint32 "param1 (dec)"
	}
}