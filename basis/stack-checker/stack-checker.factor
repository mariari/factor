! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel io effects namespaces sequences
quotations vocabs vocabs.loader generic words
stack-checker.backend stack-checker.state
stack-checker.known-words stack-checker.transforms
stack-checker.errors stack-checker.inlining
stack-checker.visitor.dummy ;
IN: stack-checker

: infer ( quot -- effect )
    [ infer-quot-here ] with-infer drop ;

: infer. ( quot -- )
    ! Safe to call from inference transforms.
    infer effect>string print ;

M: callable stack-effect infer ;
