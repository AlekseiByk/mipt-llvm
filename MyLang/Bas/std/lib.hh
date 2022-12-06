#include <iostream>

#ifdef __cplusplus
extern "C" {
#endif

void __win_print(int n);
int __win_scan();
void __win_init_window(unsigned width, unsigned height);
void __win_put_pixel(int x, int y, int state);
void __win_flush();
int __win_rand();

#ifdef __cplusplus
}
#endif
