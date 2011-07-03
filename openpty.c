#include "openpty.h"
#include <pty.h>

VALUE PTY = Qnil;

void Init_openpty() {
    PTY = rb_define_class("PTY", rb_cObject);
    rb_define_singleton_method(PTY, "openpty", method_openpty, 0);
    rb_define_singleton_method(PTY, "close", method_close, 1);
}

/* ============================================================ */

VALUE method_openpty(VALUE self) {
    int master;
    int slave;
    struct termios tt;
    struct winsize win;

    openpty(&master, &slave, NULL, &tt, &win);

    return rb_ary_new3(2, INT2NUM(master), INT2NUM(slave));
}

VALUE method_close(VALUE self, VALUE fd) {
    close(NUM2INT(fd));
    return;
}
