#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 0
}
{
    text = ""
    code = $0
    while (match(code, /\(([[:digit:]]+)x([[:digit:]]+)\)/, MARKER)) {
        text = text substr(code, 1, RSTART - 1)
        for (i = 1; i <= MARKER[2]; ++i) {
            text = text substr(code, RSTART + RLENGTH, MARKER[1])
        }
        code = substr(code, RSTART + RLENGTH + MARKER[1])
    }
    text = text code
    if (DEBUG) print text
    print length(text)
}
