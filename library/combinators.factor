! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: kernel
USE: lists

: slip ( quot x -- x )
    >r call r> ; inline

: 2slip ( quot x y -- x y )
    >r >r call r> r> ; inline

: 3slip ( quot x y z -- x y z )
    >r >r >r call r> r> r> ; inline

: keep ( a quot -- a )
    #! Execute the quotation with a on the stack, and restore a
    #! after the quotation returns.
    over >r call r> ; inline

: 2keep ( a b quot -- a b )
    #! Execute the quotation with a and b on the stack, and
    #! restore a and b after the quotation returns.
    over >r pick >r call r> r> ; inline

: apply ( code input -- code output )
    #! Apply code to input.
    swap dup >r call r> swap ; inline

: cond ( x list -- )
    #! The list is of this form:
    #!
    #! [ [ condition 1 ] [ code 1 ]
    #!   [ condition 2 ] [ code 2 ]
    #!   ... ]
    #!
    #! Each condition is evaluated in turn. If it returns true,
    #! the code is evaluated. If it returns false, the next
    #! condition is checked.
    #!
    #! Before evaluating each condition, the top of the stack is
    #! duplicated. After the last condition is evaluated, the
    #! top of the stack is popped.
    #!
    #! So each condition and code block must have stack effect:
    #! ( X -- )
    #!
    #! This combinator will not compile.
    dup [
        uncons >r over >r call r> r> rot [
            car call
        ] [
            cdr cond
        ] ifte
    ] [
        2drop
    ] ifte ;

: ifte* ( cond true false -- )
    #! If the condition is not f, execute the 'true' quotation,
    #! with the condition on the stack. Otherwise, pop the
    #! condition and execute the 'false' quotation.
    pick [ drop call ] [ nip nip call ] ifte ; inline

: unless ( cond quot -- )
    #! Execute a quotation only when the condition is f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    [ ] swap ifte ; inline

: unless* ( cond quot -- )
    #! If cond is f, pop it off the stack and evaluate the
    #! quotation. Otherwise, leave cond on the stack.
    #!
    #! In order to compile, the quotation must consume one less
    #! value than it produces.
    over [ drop ] [ nip call ] ifte ; inline

: when ( cond quot -- )
    #! Execute a quotation only when the condition is not f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    [ ] ifte ; inline

: when* ( cond quot -- )
    #! If the condition is true, it is left on the stack, and
    #! the quotation is evaluated. Otherwise, the condition is
    #! popped off the stack.
    #!
    #! In order to compile, the quotation must consume one more
    #! value than it produces.
    dupd [ drop ] ifte ; inline

: forever ( quot -- )
    #! The code is evaluated in an infinite loop. Typically, a
    #! continuation is used to escape the infinite loop.
    #!
    #! This combinator will not compile.
    dup slip forever ;
