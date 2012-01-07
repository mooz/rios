#ifndef RIOS_PTY_H_
#define RIOS_PTY_H_

#if defined __linux__
#  include <pty.h>
#elif defined __FreeBSD__
#  include <libutil.h>
#elif defined __APLLE__ || defined __MACOS_X || defined __NetBSD__ || defined __OpenBSD
#  include <util.h>
#endif

#endif  /* !RIOS_PTY_H_ */
