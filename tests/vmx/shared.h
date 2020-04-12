#pragma once

#include <stdint.h>
#include <toshokan/export.h>
#include <toshokan/symbol.h>

//
//   *** SHARED FRIEND VARIABLES ***
//
// HOWTO
// 1. write a declaration here with SHARED_SYMBOL prefix
// 2. define it in a friend source file
extern bool SHARED_SYMBOL(is_vmx_available);

//
//   *** EXPORTED HAKASE FUNCTIONS ***
//
// HOWTO
// 1. write a declaration of *the original function*
//    if it's a function from libc, write it down explicitly
//    FRIEND CANNOT READ LIBC HEADERS
// 2. export it with EXPORT_SYMBOL prefix
