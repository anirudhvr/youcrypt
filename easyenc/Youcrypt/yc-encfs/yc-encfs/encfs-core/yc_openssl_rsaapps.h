//
//  youcrypt_openssl_apps.h
//  Youcrypt
//
//  Created by avr on 8/27/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef Youcrypt_youcrypt_openssl_apps_h
#define Youcrypt_youcrypt_openssl_apps_h


///////////////////////////////////////////////////////
// Copypaste from apps.h
////////////////////////////////////////////////////////
#ifdef SIGPIPE
#define do_pipe_sig()	signal(SIGPIPE,SIG_IGN)
#else
#define do_pipe_sig()
#endif

#define OPENSSL_NO_ENGINE 1 // To cut out some bullshit in yc_openssl_rsaapps
#define MONOLITH          1 // To cut out some bullshit
#undef OPENSSL_C          // To cut out some bullshit

#if defined(MONOLITH) && !defined(OPENSSL_C)
#  define apps_startup() \
		do_pipe_sig()
#  define apps_shutdown()
#else
#  ifndef OPENSSL_NO_ENGINE
#    define apps_startup() \
			do { do_pipe_sig(); CRYPTO_malloc_init(); \
			ERR_load_crypto_strings(); OpenSSL_add_all_algorithms(); \
			ENGINE_load_builtin_engines(); setup_ui_method(); } while(0)
#    define apps_shutdown() \
			do { CONF_modules_unload(1); destroy_ui_method(); \
			OBJ_cleanup(); EVP_cleanup(); ENGINE_cleanup(); \
			CRYPTO_cleanup_all_ex_data(); ERR_remove_thread_state(NULL); \
			ERR_free_strings(); zlib_cleanup();} while(0)
#  else
#    define apps_startup() \
			do { do_pipe_sig(); CRYPTO_malloc_init(); \
			ERR_load_crypto_strings(); OpenSSL_add_all_algorithms(); \
			setup_ui_method(); } while(0)
#    define apps_shutdown() \
			do { CONF_modules_unload(1); destroy_ui_method(); \
			OBJ_cleanup(); EVP_cleanup(); \
			CRYPTO_cleanup_all_ex_data(); ERR_remove_thread_state(NULL); \
			ERR_free_strings(); zlib_cleanup(); } while(0)
#  endif
#endif

#define FORMAT_UNDEF    0
#define FORMAT_ASN1     1
#define FORMAT_TEXT     2
#define FORMAT_PEM      3
#define FORMAT_NETSCAPE 4
#define FORMAT_PKCS12   5
#define FORMAT_SMIME    6
#define FORMAT_ENGINE   7
#define FORMAT_IISSGC	8	/* XXX this stupid macro helps us to avoid
                             * adding yet another param to load_*key() */
#define FORMAT_PEMRSA	9	/* PEM RSAPubicKey format */
#define FORMAT_ASN1RSA	10	/* DER RSAPubicKey format */
#define FORMAT_MSBLOB	11	/* MS Key blob format */
#define FORMAT_PVK	12	/* MS PVK file format */

#define APP_PASS_LEN	1024
#define NETSCAPE_CERT_HDR	"certificate"


#define PW_MIN_LENGTH 4
typedef struct pw_cb_data
	{
	const void *password;
	const char *prompt_info;
	} PW_CB_DATA;

int password_callback(char *buf, int bufsiz, int verify,
	PW_CB_DATA *cb_data);

///////////////////////////////////////////////////////
// End copypaste from apps.h
////////////////////////////////////////////////////////

///////////////////////////////////////////////////////
// Copypaste from e_os.h
////////////////////////////////////////////////////////

#ifndef OPENSSL_EXIT
# if defined(MONOLITH) && !defined(OPENSSL_C)
#  define OPENSSL_EXIT(n) return(n)
# else
#  define OPENSSL_EXIT(n) do { EXIT(n); return(n); } while(0)
# endif
#endif

///////////////////////////////////////////////////////
// End copypaste from e_os.h
////////////////////////////////////////////////////////


// To pass pointers to/from rsautl
struct rsautl_args {
    unsigned char *inbuf;
    int insize;
    unsigned char **outbuf;
    int outsize;
};

///////////////////////////////////////////////////////
// The three chief function prototypes
///////////////////////////////////////////////////////
int genpkey(int argc, char **argv);
int rsa(int argc, char **argv);
int rsautl(int argc, char **argv, struct rsautl_args *rsautlargs);


#endif
