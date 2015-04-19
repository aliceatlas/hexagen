  /*****\\\\
 /       \\\\    Core/Context.c
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


#import "Context.h"


void trombone() {
    entry_point func;
    asm("movq 0x8(%%rbp), %0;" : "=r"(func) : : );
    func();
}


void setup_stack(jmpbuf *buf, void *stack, unsigned long size, entry_point func) {
    void *dest = stack + size - sizeof(void*);
    (*buf)[0] = dest;
    (*buf)[2] = dest;
    *((unsigned long *) dest) = (unsigned long) Block_copy(func);
    (*buf)[1] = (void*) trombone;
}