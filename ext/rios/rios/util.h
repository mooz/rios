#include "ruby.h"

void Init_util();
VALUE method_openpty(VALUE self, VALUE fd);
VALUE method_set_controlling_tty(VALUE self, VALUE tty, VALUE source);
