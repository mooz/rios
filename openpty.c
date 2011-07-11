#include "openpty.h"
#include <pty.h>

VALUE PTY = Qnil;

void Init_openpty() {
    PTY = rb_define_class("PTY", rb_cObject);
    rb_define_singleton_method(PTY, "openpty", method_openpty, 1);
}

VALUE method_openpty(VALUE self, VALUE fd) {
    int master;
    int slave;
    struct termios tt;
    struct winsize win;
    int fd_i = NUM2INT(fd);

    tcgetattr(fd_i, &tt);
    ioctl(fd_i, TIOCGWINSZ, &win);

    openpty(&master, &slave, NULL, &tt, &win);

    return rb_ary_new3(2, INT2NUM(master), INT2NUM(slave));
}
