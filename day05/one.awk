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
    count = 0
    code = ""
    for (i = 0; i < 9999999999; ++i) if (substr(md5($0 i), 1, 5) == "00000") {
        code = code substr(md5($0 i), 6, 1)
        if (DEBUG) {
            print i, code
        }
        if (++count >= 8) {
            print code
            next
        }
    }
    print $0, "CODE NOT FOUND"
}
END {
    if (_exit) {
        exit _exit
    }
}
