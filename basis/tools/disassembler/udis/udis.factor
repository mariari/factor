! Copyright (C) 2008, 2010 Slava Pestov, Jorge Acereda Macia.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax arrays
combinators destructors kernel layouts libc make math
math.order math.parser namespaces sequences splitting system
tools.disassembler.private tools.disassembler.utils tools.memory ;
IN: tools.disassembler.udis

<< "libudis86" {
    { [ os windows? ] [ "libudis86.dll" ] }
    { [ os macosx? ] [ "libudis86.dylib" ] }
    { [ os unix? ] [ "libudis86.so" ] }
} cond cdecl add-library >>

LIBRARY: libudis86

TYPEDEF: void ud

FUNCTION: void ud_translate_intel ( ud* u )
FUNCTION: void ud_translate_att ( ud* u )

: UD_SYN_INTEL ( -- addr ) &: ud_translate_intel ; inline
: UD_SYN_ATT ( -- addr ) &: ud_translate_att ; inline

CONSTANT: UD_EOI          -1
CONSTANT: UD_INP_CACHE_SZ 32
CONSTANT: UD_VENDOR_AMD   0
CONSTANT: UD_VENDOR_INTEL 1

FUNCTION: void ud_init ( ud* u )
FUNCTION: void ud_set_mode ( ud* u, uchar mode )
FUNCTION: void ud_set_pc ( ud* u, ulonglong pc )
FUNCTION: void ud_set_input_buffer ( ud* u, c-string offset, size_t size )
FUNCTION: void ud_set_vendor ( ud* u, uint vendor )
FUNCTION: void ud_set_syntax ( ud* u, void* syntax )
FUNCTION: void ud_input_skip ( ud* u, size_t size )
FUNCTION: int ud_input_end ( ud* u )
FUNCTION: uint ud_decode ( ud* u )
FUNCTION: uint ud_disassemble ( ud* u )
FUNCTION: c-string ud_insn_asm ( ud* u )
FUNCTION: void* ud_insn_ptr ( ud* u )
FUNCTION: ulonglong ud_insn_off ( ud* u )
FUNCTION: c-string ud_insn_hex ( ud* u )
FUNCTION: uint ud_insn_len ( ud* u )
FUNCTION: c-string ud_lookup_mnemonic ( int c )

: <ud> ( -- ud )
    1,000 malloc &free
    dup ud_init
    dup cell-bits ud_set_mode
    dup UD_SYN_INTEL ud_set_syntax ;

: with-ud ( ..a quot: ( ..a ud -- ..b ) -- ..b )
    [ [ [ <ud> ] dip call ] with-destructors ] with-code-blocks ; inline

SINGLETON: udis-disassembler

: buf/len ( from to -- buf len ) [ drop <alien> ] [ swap - ] 2bi ;

: resolve-call ( str -- str' ) "0x" split1-last [ resolve-xt append ] when* ;

: format-disassembly ( lines -- lines' )
    dup [ second length ] [ max ] map-reduce
    '[
        [
            [ first >hex cell 2 * CHAR: 0 pad-head % ": " % ]
            [ second _ CHAR: \s pad-tail % "  " % ]
            [ third resolve-call % ]
            tri
        ] "" make
    ] map ;

: (disassemble) ( ud -- lines )
    [
        dup '[
            _ ud_disassemble 0 =
            [ f ] [
                _
                [ ud_insn_off ]
                [ ud_insn_hex ]
                [ ud_insn_asm ]
                tri 3array , t
            ] if
        ] loop
    ] { } make ;

M: udis-disassembler disassemble*
    '[
        _ _
        [ drop ud_set_pc ]
        [ buf/len ud_set_input_buffer ]
        [ 2drop (disassemble) format-disassembly ]
        3tri
    ] with-ud ;

udis-disassembler disassembler-backend set-global
