#include "ruby.h"

void Init_openpty();
VALUE method_openpty(VALUE self);
VALUE method_close(VALUE self, VALUE fd);
