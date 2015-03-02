  /*****\\\\
 /       \\\\    Hexagen/Wrapper.h
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


#import <Foundation/Foundation.h>


typedef void (^exit_call_t)();
typedef void (^entry_point_t)(exit_call_t);


@interface AsymmetricCoroutineWrapper: NSObject
- (instancetype)initWithBlock:(entry_point_t)block;
- (void)enter;
@end