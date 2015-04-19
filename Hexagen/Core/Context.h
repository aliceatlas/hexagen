  /*****\\\\
 /       \\\\    Core/Context.h
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


#import <CoreFoundation/CFDate.h>
#include <stdlib.h>


typedef void *jmpbuf[5];
typedef void (^entry_point)();

typedef struct {
    void* __nonnull _stack;
    void* __nullable _out;
    jmpbuf _reentry;
    void* __nullable  _arg;
    jmpbuf _nextexit;
    char _completed;
} coro_ctx;

typedef void (^coro_body)(coro_ctx* __nonnull);


void setup_stack(jmpbuf* __nonnull buf, void* __nonnull stack, unsigned long size, entry_point __nonnull func);

static inline coro_ctx* __nonnull ctx_create(unsigned long stacksize, coro_body __nonnull func) {
    void* stack = malloc(stacksize + sizeof(coro_ctx));
    coro_ctx* ctx = (coro_ctx*) stack + stacksize - sizeof(coro_ctx);
    ctx->_stack = stack;
    setup_stack(&ctx->_reentry, ctx->_stack, stacksize, ^{
        func(ctx);
        ctx->_completed = 1;
        __builtin_longjmp((void**) &ctx->_nextexit, 1);
    });
    return ctx;
}

static inline char ctx_enter(coro_ctx* __nonnull ctx, void* __nullable arg, void* __nullable* __nullable out) {
    ctx->_arg = arg;
    if (__builtin_setjmp((void**) &ctx->_nextexit) == 0) {
        __builtin_longjmp((void**) &ctx->_reentry, 1);
    }
    if (ctx->_completed) {
        //free(continuation->_stack);
        //free(continuation);
        return 0;
    } else if (out) {
        *out = ctx->_out;
    }
    return 1;
}

static inline void* __nullable ctx_yield(coro_ctx* __nonnull ctx, void* __nullable val) {
    ctx->_out = val;
    if (__builtin_setjmp((void**) &ctx->_reentry) == 0) {
        __builtin_longjmp((void**) &ctx->_nextexit, 1);
    }
    return ctx->_arg;
}