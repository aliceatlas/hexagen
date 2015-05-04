  /*****\\\\
 /       \\\\    Core/Context.c
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


#import "Context.h"


void trampoline() {
    entry_point func;
    #if defined(__x86_64__)
        asm("movq 0x8(%%rbp), %0" : "=r"(func) : : );
    #elif defined(__arm64__)
        asm("ldr %0, [fp, #16]" : "=r"(func) : : );
    //#elif defined(__arm__)
    //#elif defined(__i386__)
    #else
        #error "Unsupported architecture"
    #endif
    
    func();
}


void setup_stack(jmpbuf *buf, void *stack, unsigned long size, entry_point func) {
    #if defined(__x86_64__)
        void *dest = (void*) ((unsigned long)stack + size - __SIZEOF_POINTER__);
    #elif defined(__arm64__)
        void *dest = (void*) (((unsigned long)stack + size - __SIZEOF_POINTER__) & ~((1 << 4) - 1));
    #endif
    (*buf)[0] = dest;
    (*buf)[2] = dest;
    *((unsigned long *) dest) = (unsigned long) Block_copy(func);
    /* 
     THIS IS CHEATING:
     the LLVM docs define the second field of a jmpbuf to be an opaque value produced by llvm.eh.sjlj.setjmp and consumed by llvm.eh.sjlj.longjmp, with its specific semantics being target-specific and not guaranteed to be usable in any particular way other than as described. on x86_64 it happens to just be the address to jump to, and it seems likely that it's the same or similar on other platforms, but at least in principle, this is not a 100% documented and officially-correct use of these intrinsics.
     */
    (*buf)[1] = (void*) trampoline;
}