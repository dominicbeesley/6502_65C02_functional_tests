#!/bin/bash

ATOMBASE='3200'
BEEBBASE='1100'

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

function make_atm_header {
     len=`du -b $1 | awk '{print $1}'`     
     echo -n `basename $1` > hdr
     local ATOMEXEC=`printf '%x' $((0x$ATOMBASE + 0x200))`
     truncate -s 16 hdr
     echo $ATOMEXEC$ATOMEXEC | xxd -r -p >> hdr
     echo -e -n "\x`printf '%x' $(($len & 255))`" >> hdr
     echo -e -n "\x`printf '%x' $(($len / 256))`" >> hdr
     cat $1 >> hdr
     mv hdr $1
}

function make_inf_file {
    base=`basename $1`
    local BEEBEXEC=`printf '%x' $((0x$BEEBBASE + 0x200))`
    echo -e "\$.$base\t$BEEBEXEC\t$BEEBEXEC" > $1.inf
}


# Target 1 = ATOM
# Target 2 = BEEB

for TARGET in 1 2 
do

    if [ $TARGET == "1" ]
    then
       DIR=atom
       BASE="0x$ATOMBASE"
    else
       DIR=beeb
       BASE="0x$BEEBBASE"
    fi

    mkdir -p $DIR
    rm -f $DIR/*

    if [ $TARGET == "2" ]
    then
        rm -f $DIR/dormann.ssd
        ./tools/mmb_utils/blank_ssd.pl $DIR/dormann.ssd
        ./tools/mmb_utils/title.pl $DIR/dormann.ssd Dormann
    fi
    
    echo '##########'
    BIN=D6502
    $AS65 -DBASE=$BASE -DTARGET=$TARGET -o$DIR/$BIN -l$DIR/$BIN.lst -m -w -h0 6502_functional_test
    echo '##########'

    if [ $TARGET == "1" ]
    then
        make_atm_header $DIR/$BIN
    else
        make_inf_file $DIR/$BIN
        ./tools/mmb_utils/putfile.pl $DIR/dormann.ssd $DIR/$BIN
    fi

    for WDC_OP in 0 1
    do
        for RKWL_OP in 0 1
        do
            BIN=D65C$WDC_OP$RKWL_OP
            $AS65 -DBASE=$BASE -DTARGET=$TARGET -DWDC_OP=$WDC_OP -DRKWL_OP=$RKWL_OP -o$DIR/$BIN -l$DIR/$BIN.lst -m -w -x -h0 65C02_extended_opcodes_test

            if [ $TARGET == "1" ]
            then
                make_atm_header $DIR/$BIN
            else
                make_inf_file $DIR/$BIN
                ./tools/mmb_utils/putfile.pl $DIR/dormann.ssd $DIR/$BIN
            fi
        done
    done    
done


./tools/mmb_utils/info.pl beeb/dormann.ssd
