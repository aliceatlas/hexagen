  /*****\\\\
 /       \\\\    Core/Context.h
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


#import <CoreFoundation/CFDate.h>
#include <stdlib.h>
#include <stdbool.h>


typedef void *jmpbuf[5];
typedef __attribute__((noreturn)) void (^entry_point)();

typedef struct {
    void* __nonnull _stack;
    void* __nullable _out;
    jmpbuf _reentry;
    void* __nullable  _arg;
    jmpbuf _nextexit;
    bool _completed;
} coro_ctx;

typedef void (^coro_body)(coro_ctx* __nonnull);


void* __nonnull llvm_stacksave(void) __asm__("llvm.stacksave");
void* __nonnull llvm_frameaddress(int) __asm__("llvm.frameaddress");


#if defined(__x86_64__)

#define arch_setjmp(buf) if (!__builtin_setjmp((void**) &buf))
#define arch_longjmp(buf) __builtin_longjmp((void**) &buf, 1)

#elif defined(__arm64__)

#define arch_setjmp(buf) \
    (buf)[0] = llvm_frameaddress(0); \
    (buf)[2] = llvm_stacksave(); \
    asm("adr %0, 1f\n" : "=r"((buf)[1]) : : );

#define arch_longjmp(buf) \
    asm("ldr x10, [%0]\n" \
        "ldr x11, [%0, #8]\n" \
        "ldr x12, [%0, #16]\n" \
        "mov fp, x10\n" \
        "mov sp, x12\n" \
        "br x11\n" \
        "1:\n" \
        : \
        : "r"(buf) \
        : "x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x10", "x11", "x12", "x13", "x14", "x15", "x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27", "x28", "x30", "v0", "v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15", "v16", "v17", "v18", "v19", "v20", "v21", "v22", "v23", "v24", "v25", "v26", "v27", "v28", "v29", "v30", "v31", "cc" \
    );

//#elif defined(__arm__)

//#elif defined(__i386__)

#else

#error "Unsupported architecture"

#endif


void setup_stack(jmpbuf* __nonnull buf, void* __nonnull stack, unsigned long size, entry_point __nonnull func);

static inline coro_ctx* __nonnull ctx_create(unsigned long stacksize, coro_body __nonnull func) {
    stacksize = stacksize & ~((1 << 4) - 1);
    void* stack = malloc(stacksize + sizeof(coro_ctx));
    coro_ctx* ctx = (coro_ctx*) ((unsigned long) stack + stacksize);
    ctx->_stack = stack;
    setup_stack(&ctx->_reentry, ctx->_stack, stacksize, ^{
        func(ctx);
        ctx->_completed = true;
        arch_longjmp(ctx->_nextexit);
    });
    return ctx;
}

static inline bool ctx_enter(coro_ctx* __nonnull ctx, void* __nullable arg, void* __nullable* __nullable out) {
    ctx->_arg = arg;
    arch_setjmp(ctx->_nextexit) {
        arch_longjmp(ctx->_reentry);
    }
    if (ctx->_completed) {
        return false;
    } else if (out) {
        *out = ctx->_out;
    }
    return true;
}

static inline void* __nullable ctx_yield(coro_ctx* __nonnull ctx, void* __nullable val) {
    ctx->_out = val;
    arch_setjmp(ctx->_reentry) {
        arch_longjmp(ctx->_nextexit);
    }
    return ctx->_arg;
}

static inline void ctx_destroy(coro_ctx* __nonnull ctx) {
    free(ctx->_stack);
}
