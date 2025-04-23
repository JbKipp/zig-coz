// coz_interface.c
#include "coz.h"

void coz_progress(const char* name) {
    COZ_PROGRESS_NAMED(name);
}

void coz_begin(const char* name) {
    COZ_BEGIN(name);
}

void coz_end(const char* name) {
    COZ_END(name);
}