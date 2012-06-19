#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "pipetest.h"

extern int errno;
#define BUFSZ 2048

int run_command(char *command, char **out_msg, int *out_len,
        char **err_msg, int *err_len)
{
    int rc = 0, err;
    FILE *fp;
    int curlen, curalloc;
    *out_len = 0;
    *err_len = 0;
    if (!(fp = popen(command, "r"))) {
        err = errno;
        *err_msg = (char*) strdup(strerror(err));
        *err_len = strlen(*err_msg);
        rc = 1;
        goto out_err;
    }

    curalloc = BUFSZ;
    *out_msg = (char*) calloc(BUFSZ, 1); /* XXX check success */
    fgets(*out_msg, sizeof(*out_msg), fp);

    while (!feof(fp)) {
        curlen = strlen(*out_msg);
        if (curlen >= curalloc || (curalloc - curlen < BUFSZ)) {
            *out_msg = (char*) realloc(*out_msg, curalloc + 2 * BUFSZ); /* XXX check success */
            curalloc = curalloc + 2 * BUFSZ;
        }
        fgets(*out_msg + curlen, BUFSZ, fp);
    }

    *out_len = sizeof(out_msg);
    rc = 0;

out_err:
    pclose(fp);
    return rc;
}
/*
int main(int argc, char *argv[])
{

    char cmd[1024] = {0}, *ptr;
    char *out = NULL, *err = NULL;
    int outlen, errlen;
    int i;

    ptr = cmd;

    for (i = 1; i < argc; ++i) {
        strcpy(ptr, argv[i]);
        ptr += strlen(argv[i]);
    }

    fprintf(stderr, "Executing [%s]\n", cmd);

    if (run_command(cmd, &out, &outlen, &err, &errlen)) {
        fprintf(stderr, "Command failed: %s\n", err);
    } else {
        fprintf(stderr, "Comamnd success!\n");
        printf("%s", out);
    }

    return 0;
}
*/
