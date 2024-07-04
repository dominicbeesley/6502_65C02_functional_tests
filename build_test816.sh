#!/bin/bash

AS65=./tools/as65/as65.exe

#AS65 Assembler for R6502 [1.42].  Copyright 1994-2007, Frank A. Kingswood
# 
# Usage: AS65 [-DIcghilmnopqstuvwxz] file
# 
# Options:
# 	-D<name> : Define label, if no name given define DEBUG.
# 	-I<path> : Specify include file path string.
# 	-c       : Show number of cycles per instruction in listing.
# 	-g       : Generate source-level debug information.
# 	-h<num>  : Specify height of page for listing.
# 	-i       : Ignore case in opcodes.
# 	-l       : Generate pass 2 listing.
# 	-l<name> : Listing file name.
# 	-m       : Show macro expansions in listing.
# 	-n       : Disable optimizations.
# 	-o<name> : Binary/hex output file name.
# 	-p       : Generate pass 1 listing.
# 	-q       : Quiet mode.
# 	-s1 -s   : Write s-records instead of binary file.
# 	-s2      : Write intel-hex file instead of binary file.
# 	-t       : Generate symbol table.
# 	-u       : List memory usage map.
# 	-v       : Verbose mode.
# 	-w<wid>  : Specify listing width, 131 if no number given.
# 	-x1      : Use 6502 undefined instructions.
# 	-x2 -x   : Use 65SC02 extensions.
# 	-z       : Fill unused memory with zeros.
# 


# Target 1 = ATOM
# Target 2 = BEEB

TARGET=3

    DIR=test816
    ROMBASE="0xC000"
    DATBASE="0x200"
    TARGET=3

    mkdir -p $DIR
    rm -f $DIR/*

    
    echo '##########'
    BIN=D6502
    $AS65 -DBASE=$BASE -DTARGET=$TARGET -DDATBASE=$DATBASE -DROMBASE=$ROMBASE -o$DIR/$BIN -l$DIR/$BIN.lst -m -w -h0 6502_functional_test
    cat $DIR/$BIN | hexdump -v -e '/1 "%02x\n"' >$DIR/$BIN.hex

    echo '##########'


