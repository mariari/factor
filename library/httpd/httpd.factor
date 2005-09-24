! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd
USING: errors kernel lists namespaces io strings threads http
sequences ;

: (url>path) ( uri -- path )
    url-decode "http://" ?head [
        "/" split1 dup "" ? nip
    ] when ;

: url>path ( uri -- path )
    "?" split1 dup [
      >r (url>path) "?" r> append3
    ] [
      drop (url>path)
    ] if ;

: secure-path ( path -- path )
    ".." over subseq? [ drop f ] when ;

: request-method ( cmd -- method )
    [
        [[ "GET" "get" ]]
        [[ "POST" "post" ]]
        [[ "HEAD" "head" ]]
    ] assoc [ "bad" ] unless* ;

: host ( -- string )
    #! The host the current responder was called from.
    "Host" "header" get assoc ":" split1 drop ;

: (handle-request) ( arg cmd -- method path host )
    request-method dup "method" set swap
    prepare-url prepare-header host ;

: handle-request ( arg cmd -- )
    [ (handle-request) serve-responder ] with-scope ;

: parse-request ( request -- )
    dup log-message
    " " split1 dup [
        " HTTP" split1 drop url>path secure-path dup [
            swap handle-request
        ] [
            2drop bad-request
        ] if
    ] [
        2drop bad-request
    ] if ;

: httpd ( port -- )
    \ httpd [
        60000 stdio get set-timeout
        readln [ parse-request ] when*
    ] with-server ;

: stop-httpd ( -- )
    #! Stop the server.
    \ httpd get stream-close ;
