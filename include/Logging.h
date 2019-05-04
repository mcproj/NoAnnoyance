#ifndef LOGGING_H
#define LOGGING_H

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_RESET   "\x1b[0m"

#ifdef DEBUG
  #define PNLog(fmt, ...) NSLog((@"<NoAnnoyance> %s [Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
  #define PNLog(...)
#endif

#endif
