#if defined(__linux__)
#include <pty.h>

#elif defined(__FreeBSD__)
#include <libutil.h>

#elif defined(__APLLE__) || defined(__MACOS_X)
#include <util.h>

#elif defined(__NetBSD__) || defined(__OpenBSD)
#include <util.h>

#endif
