! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: stdio
DEFER: stdio

IN: streams
USE: io-internals
USE: errors
USE: hashtables
USE: kernel
USE: stdio
USE: strings
USE: namespaces
USE: generic

TRAITS: fd-stream

M: fd-stream fwrite-attr ( str style stream -- )
    [ drop "out" get blocking-write ] bind ;M

M: fd-stream freadln ( stream -- str )
    [ "in" get dup [ blocking-read-line ] when ] bind ;M

M: fd-stream fread# ( count stream -- str )
    [ "in" get dup [ blocking-read# ] [ nip ] ifte ] bind ;M

M: fd-stream fflush ( stream -- )
    [ "out" get [ blocking-flush ] when* ] bind ;M

M: fd-stream fauto-flush ( stream -- )
    drop ;M

M: fd-stream fclose ( -- )
    [
        "out" get [ dup blocking-flush close-port ] when*
        "in" get [ close-port ] when*
    ] bind ;M

C: fd-stream ( in out -- stream )
    [ "out" set "in" set ] extend ;C

: <filecr> ( path -- stream )
    t f open-file <fd-stream> ;

: <filecw> ( path -- stream )
    f t open-file <fd-stream> ;

: <filebr> ( path -- stream )
    <filecr> ;

: <filebw> ( path -- stream )
    <filecw> ;

: init-stdio ( -- )
    stdin stdout <fd-stream> <stdio-stream> stdio set ;

: (fcopy) ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'. Use fcopy; this word does not close
    #! streams.
    "out" swap hash >r "in" swap hash r> blocking-copy ;

: fcopy ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'.
    [ 2dup (fcopy) ] [ -rot fclose fclose rethrow ] catch ;

: resource-path ( -- path )
    "resource-path" get [ "." ] unless* ;

: <resource-stream> ( path -- stream )
    resource-path swap cat2 <filecr> ;
