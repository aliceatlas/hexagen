  /*****\\\\
 /       \\\\    Wrapper/Wrapper.h
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


typedef void (^exit_call_t)();
typedef void (^entry_point_t)(exit_call_t);


#ifdef __cplusplus
extern "C" {
#endif

const void *alloc_asymm_coro();
void setup_asymm_coro(const void *, entry_point_t);
void enter_asymm_coro(const void *);
void destroy_asymm_coro(const void *);

#ifdef __cplusplus
}
#endif