#!/usr/bin/env awk -f
@load "./md5"
BEGIN {
    DEBUG = 0
}
$0 !~ /^[a-z]+$/ {
    print "DATA ERROR"
    exit _exit=1
}
{
    split("", CODE)
    for (i = 0; i < 9999999999; ++i) if (substr(md5($0 i), 1, 5) == "00000") {
        position = substr(md5($0 i), 6, 1)
        if ((position ~ /[0-7]/) && !(position in CODE)) {
            CODE[position] = substr(md5($0 i), 7, 1)
            if (DEBUG) {
                print i, position, CODE[position]
            }
            if (length(CODE) == 8) {
                for (c = 0; c <= 7; ++c) {
                    printf("%c", CODE[c])
                }
                printf("\n")
                next
            }
        }
    }
    print $0, "CODE NOT FOUND"
}
END {
    if (_exit) {
        exit _exit
    }
}
