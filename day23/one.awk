#!/usr/bin/env awk -f
BEGIN {
    egg_count = 7
    REGISTERS["a"] = egg_count
    REGISTERS["b"] = REGISTERS["c"] = REGISTERS["d"] = 0
    split("CPY INC JNZ TGL", OPCODES)
    for (o in OPCODES) {
        OPCODE_NUMBER[OPCODES[o]] = o
    }
    DEBUG = 0
}
/^cpy ([abcd]|(-?[[:digit:]]+)) [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["CPY"]
    DST[NR] = $3
    VAL[NR] = $2
    next
}
/^inc [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["INC"]
    DST[NR] = $2
    VAL[NR] = 1
    next
}
/^dec [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["INC"]
    DST[NR] = $2
    VAL[NR] = -1
    next
}
/^jnz ([abcd]|(-?[[:digit:]]+)) ([abcd]|(-?[[:digit:]]+))$/ {
    OP[NR] = OPCODE_NUMBER["JNZ"]
    DST[NR] = $3
    VAL[NR] = $2
    next
}
/^tgl ([abcd]|(-?[[:digit:]]+))$/ {
    OP[NR] = OPCODE_NUMBER["TGL"]
    DST[NR] = $2
    VAL[NR] = 1
    next
}
{
    print "DATA ERROR, unrecognized instruction", $0
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    if (DEBUG) {
        print "PROGRAM:"
        for (i = 1; i <= NR; ++i) {
            printf("%02d %s %2s %2s\n", i, OPCODES[OP[i]], VAL[i], DST[i])
        }
        printf("REGISTERS: ")
        print REGISTERS["a"], REGISTERS["b"], REGISTERS["c"], REGISTERS["d"]
        print "EXECUTION:"
    }
    pc = 1
    while (pc <= NR) {
        next_pc = pc + 1
        if (DEBUG) {
            printf("%02d : %s %2s %2s  -> ", pc, OPCODES[OP[pc]], VAL[pc], DST[pc])
        }
        switch (OP[pc]) {
        case 1: # CPY
            if (DST[pc] in REGISTERS) {
                val = (VAL[pc] in REGISTERS) ? REGISTERS[VAL[pc]] : VAL[pc]
                REGISTERS[DST[pc]] = val
            }
            break
        case 2: # INC
            if (DST[pc] in REGISTERS) {
                REGISTERS[DST[pc]] += VAL[pc]
            }
            break
        case 3: # JNZ
            val = (VAL[pc] in REGISTERS) ? REGISTERS[VAL[pc]] : VAL[pc]
            dst = (DST[pc] in REGISTERS) ? REGISTERS[DST[pc]] : DST[pc]
            if (val) {
                next_pc = pc + dst
            }
            break
        case 4: # TGL
            dst = pc + ((DST[pc] in REGISTERS) ? REGISTERS[DST[pc]] : DST[pc])
            if ((dst > NR) || (dst < 1)) {
                if (DEBUG) {
                    printf("%02d OUT OF RANGE  -> ", dst)
                }
                break
            }
            if (DEBUG) {
                printf("%02d %s %2s %2s => ", dst, OPCODES[OP[dst]], VAL[dst], DST[dst])
            }
            switch (OP[dst]) {
                case 1: # CPY
                    OP[dst] = OPCODE_NUMBER["JNZ"]
                    break
                case 2: # INC
                    VAL[dst] *= -1
                    break
                case 3: # JNZ
                    OP[dst] = OPCODE_NUMBER["CPY"]
                    break
                case 4: # TGL
                    OP[dst] = OPCODE_NUMBER["INC"]
                    break
                default:
                    print "PROCESSING ERROR, unrecognized OPCODE", OP[dst], "at", dst
                    exit _exit=1
            }
            if (DEBUG) {
                printf("%s %2s %2s  -> ", OPCODES[OP[dst]], VAL[dst], DST[dst])
            }
            break
        default:
            print "PROCESSING ERROR, unrecognized OPCODE", OP[pc], "at pc", pc
            exit _exit=1
        }
        if (DEBUG) {
            print REGISTERS["a"], REGISTERS["b"], REGISTERS["c"], REGISTERS["d"]
        }
        pc = next_pc
    }
    print REGISTERS["a"]
}
