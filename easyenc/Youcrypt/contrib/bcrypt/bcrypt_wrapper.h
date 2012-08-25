#ifndef _BCRYPT_WRAPPER_H
#define _BCRYPT_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif


char *
bcrypt_encode_salt(unsigned char *csalt, int csaltlen, long log_rounds);

char *
bcrypt_hashpw(char *password, char *salt);
    
char *
gensalt(int log_rounds);

/* Implemented in bcrypt.c */
char *pybc_bcrypt(const char *, const char *);
void encode_salt(char *, u_int8_t *, u_int16_t, u_int8_t);
    
    
void testbcrypt();
    
#ifdef __cplusplus
}
#endif
    
#endif
