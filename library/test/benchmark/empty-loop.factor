IN: scratchpad
USE: compiler
USE: kernel
USE: math
USE: test

: empty-loop-1 ( n -- )
    [ ] times ;

: empty-loop-2 ( n -- )
    [ drop ] times* ;

[ ] [ 5000000 empty-loop-1 ] unit-test
[ ] [ 5000000 empty-loop-2 ] unit-test
