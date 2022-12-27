#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 1
}
{
    if (_error) {
        print "DATA ERROR"
        exit _exit=1
    }
}
END {
    if (_exit) {
        exit _exit
    }
    if ("PREVENT_LONG_RUN" in ENVIRON) {
        print NR
    }
    print NR
}
