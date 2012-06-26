//
//  pipetest.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Youcrypt_Mac_alpha_pipetest_h
#define Youcrypt_Mac_alpha_pipetest_h

#include <errno.h>

extern int errno;
#define BUFSZ 2048

int run_command(const char *command, char **out_msg, int *out_len,
                char **err_msg, int *err_len);


#endif
