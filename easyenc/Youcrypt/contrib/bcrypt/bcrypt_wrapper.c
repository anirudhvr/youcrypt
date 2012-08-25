#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <openssl/rand.h>
#include "pybc_blf.h"
#include "bcrypt_wrapper.h"

/* Code modified from 
   $Id: bcrypt_python.c,v 1.3 2009/10/01 13:09:52 djm Exp $ 
       Anirudh Ramachandran <anirudhvr@gmail.com>
 */


//static PyObject *
//bcrypt_encode_salt(PyObject *self, PyObject *args, PyObject *kw_args)
char *
bcrypt_encode_salt(unsigned char *csalt, int csaltlen, long log_rounds)
{
	char ret[64];

    if (!csalt) { 
        fprintf(stderr, "Salt is nil\n");
        return NULL;
    }
	if (csaltlen != 16) {
		fprintf(stderr, "Invalid salt length\n");
		return NULL;
	}
	if (log_rounds < 4 || log_rounds > 31) {
		fprintf(stderr, "Invalid number of rounds\n");
		return NULL;
	}

	encode_salt(ret, csalt, csaltlen, log_rounds);
	return strdup(ret);
}


//static PyObject *
//bcrypt_hashpw(PyObject *self, PyObject *args, PyObject *kw_args)
char *
bcrypt_hashpw(char *password, char *salt)
{
	char *ret, *password_copy, *salt_copy;

    if (!password || !salt) {
        fprintf(stderr, "Password or salt nil\n");
        return NULL;
    }

	password_copy = strdup(password);
	salt_copy = strdup(salt);

	ret = pybc_bcrypt(password_copy, salt_copy);

	free(password_copy);
	free(salt_copy);

	if ((ret == NULL) ||
	    strcmp(ret, ":") == 0) {
		fprintf(stderr, "Invalid salt\n");
		return NULL;
	}

	return ret;
}


#define min(a,b) ((a) <= (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))

char *
gensalt(int log_rounds)
{
    unsigned char rand[17] = {0};
    if (!RAND_bytes(rand, 16)) {
        fprintf(stderr, "Cannot generate 16 random bytes!");
        return NULL;
    }

    return bcrypt_encode_salt(rand, 16, min(max(log_rounds, 4), 31));
}

void test()
{

    char *salt = "$2a$10$L6L4WqjxRBoOe10JU.CvCe";
    char *pw = "password";
    
    char *output = bcrypt_hashpw(pw, salt);

    if (!output ||
        strcmp(output, "$2a$10$L6L4WqjxRBoOe10JU.CvCePjJDCLMmwLTp2Uc3XV2UrKjvB.qaWg6"))
        printf("Bcrypt error\n");
    else
        printf("Bcrypt success\n");
}

#if 0
int main(int argc, char *argv[])
{
    char *salt = NULL, *output = NULL;

    if (argc != 3) {
        printf("Usage: %s <saltlen> <password>\n", argv[0]);
        return EXIT_FAILURE;
    }

    //salt = gensalt(atoi(argv[1]));
    salt = "$2a$10$L6L4WqjxRBoOe10JU.CvCe";
    if (salt == NULL) {
        printf("Salt generation failed\n");
        return EXIT_FAILURE;
    }

    printf("Got salt: %s\n", salt);

    output = bcrypt_hashpw(argv[2], salt);
    if (output == NULL) {
        printf("Cannot generate bcrypted val\n");
        return EXIT_FAILURE;
    }

    printf("Output: [%s]\n", output);

    return EXIT_SUCCESS;
}
#endif

