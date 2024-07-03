# Reference Templates
# https://www.sweetscape.com/010editor/repository/files/BMP.bt
# https://raw.githubusercontent.com/synalysis/Grammars/master/bitmap.grammar

# Reference Documents
# http://www.digicamsoft.com/bmp/bmp.html
# http://en.wikipedia.org/wiki/BMP_file_format
#
# .types = ( bin );

little_endian
requires 0 "4C 53 59 53 42 49 4E"; # requires LSYSBIN
ascii 7 signature

for {set i 0} {![end]} {incr i} {
	section "Instruction" {
		hex 1 "opcode"
		uint8_bits 7,6,5,4 "param0Type"
		move -1
		uint8_bits 3,2,1,0 "param1Type"
		hex 4 "Arg0 (hex)"
		move -4 
		uint32 "Arg0 (dec)"
		hex 4 "Arg1 (hex)"
		move -4 
		uint32 "Arg1 (dec)"
	}
}