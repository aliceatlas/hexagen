  /*****\\\\
 /       \\\\    Hexagen/Wrapper/Wrapper.mm
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


#import "Wrapper.h"
#import <boost/coroutine/all.hpp>


typedef boost::coroutines::symmetric_coroutine<void> symm_coro;
typedef boost::coroutines::asymmetric_coroutine<void> asymm_coro;


@interface AsymmetricCoroutineWrapper () {
    asymm_coro::pull_type coro;
}
@end


@implementation AsymmetricCoroutineWrapper

- (instancetype)initWithBlock:(entry_point_t)block {
    coro = asymm_coro::pull_type([&block] (asymm_coro::push_type &push) {
        block(^{ push(); });
    });
    
    return self;
}

- (void)enter {
    coro();
}

@end