#pragma once

#if WIN32
    #define SIZEOF_OFF_T 4
#else
    #define SIZEOF_OFF_T 8
#endif
