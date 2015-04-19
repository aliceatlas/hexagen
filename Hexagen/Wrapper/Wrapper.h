  /*****\\\\
 /       \\\\    Wrapper/Wrapper.h
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


typedef void (^exit_call_t)();
typedef void (^entry_point_t)(exit_call_t __nonnull);

#ifdef __cplusplus
extern "C" {
#endif

const void *__nonnull alloc_asymm_coro();
void setup_asymm_coro(const void *__nonnull, entry_point_t __nonnull);
void enter_asymm_coro(const void *__nonnull);
void destroy_asymm_coro(const void *__nonnull);

#ifdef __cplusplus
}
#endif