  /*****\\\\
 /       \\\\    Wrapper/Wrapper.cpp
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


#import "Wrapper.h"


typedef boost::coroutines::symmetric_coroutine<void> symm_coro;
typedef boost::coroutines::asymmetric_coroutine<void> asymm_coro;


typedef struct {
    asymm_coro::pull_type *coro;
} asymm_coro_wrapper;


extern "C" {
    const void *alloc_asymm_coro() {
        return malloc(sizeof(asymm_coro_wrapper));
    }

    void setup_asymm_coro(const void *coro, entry_point_t block) {
        ((asymm_coro_wrapper *)coro)->coro = new asymm_coro::pull_type([&block] (asymm_coro::push_type &push) {
            block(^{ push(); });
        });
    }

    void enter_asymm_coro(const void *coro) {
        (*((asymm_coro_wrapper *)coro)->coro)();
    }

    void destroy_asymm_coro(const void *coro) {
        delete ((asymm_coro_wrapper *)coro)->coro;
        free((void *)coro);
    }
}