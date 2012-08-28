#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/bio.h>
#include <openssl/x509.h>
#include <openssl/lhash.h>
#include <openssl/conf.h>
#include <openssl/txt_db.h>
#include <openssl/rsa.h>
#include <openssl/x509.h>
#include <openssl/pkcs12.h>
#include <openssl/bn.h>
#include <openssl/ui.h>

#include "yc_openssl_rsaapps.h"

#ifndef OPENSSL_NO_OCSP
#include <openssl/ocsp.h>
#endif
#include <openssl/ossl_typ.h>




BIO *bio_err = NULL;
static UI_METHOD *ui_method = NULL;

static char *app_get_pass(BIO *err, char *arg, int keepbio);
int app_passwd(BIO *err, char *arg1, char *arg2, char **pass1, char
        **pass2);

int password_callback(char *buf, int bufsiz, int verify,
	PW_CB_DATA *cb_tmp);
int pkey_ctrl_string(EVP_PKEY_CTX *ctx, char *value);
int str2fmt(char *s);
static int init_keygen_file(BIO *err, EVP_PKEY_CTX **pctx,
        const char *file, ENGINE *e);
static int genpkey_cb(EVP_PKEY_CTX *ctx);
int init_gen_str(BIO *err, EVP_PKEY_CTX **pctx,
        const char *algname, ENGINE *e, int do_param);
int app_RAND_load_file(const char *file, BIO *bio_e, int dont_warn);
X509 *load_cert(BIO *err, const char *file, int format,
	const char *pass, ENGINE *e, const char *cert_descrip);
static int load_pkcs12(BIO *err, BIO *in, const char *desc,
		pem_password_cb *pem_cb,  void *cb_data,
		EVP_PKEY **pkey, X509 **cert, STACK_OF(X509) **ca);
int bio_to_mem(unsigned char **out, int maxlen, BIO *in);


EVP_PKEY *load_pubkey(BIO *err, const char *file, int format, int maybe_stdin,
	const char *pass, ENGINE *e, const char *key_descrip);
EVP_PKEY *load_key(BIO *err, const char *file, int format, int maybe_stdin,
	const char *pass, ENGINE *e, const char *key_descrip);

#if 0
int main(void)
{
    char *genprivkey_argv[] = {"genpkey", "-out", "priv.pem", "-outform", "PEM", "-pass",
        "pass:asdfgh", "-aes-256-cbc", "-algorithm", "RSA"};
    char *genpubkey_argv[] = {"rsa", "-pubout", "-in", "priv.pem",
        "-out", "pub.pem"};
    char *rsautl_encrypt_argv[] = {"rsautl", "-encrypt", "-inkey",
        "pub.pem", "-pubin", "-in", "plain.txt", "-out", "cipher.txt"};
    char *rsautl_decrypt_argv[] = {"rsautl", "-decrypt", "-inkey",
        "priv.pem", "-in", "cipher.txt", "-out", "plain2.txt",
        "-passin", "pass:asdfgh"};

    genpkey(sizeof(genprivkey_argv)/sizeof(genprivkey_argv[0]),
            genprivkey_argv);
    rsa(sizeof(genpubkey_argv)/sizeof(genpubkey_argv[0]),
            genpubkey_argv);

    rsautl(sizeof(rsautl_encrypt_argv)/sizeof(rsautl_encrypt_argv[0]),
            rsautl_encrypt_argv);

    rsautl(sizeof(rsautl_decrypt_argv)/sizeof(rsautl_decrypt_argv[0]),
            rsautl_decrypt_argv);

    return 0;
}
#endif

////////////////////////////////////////////////////////////////
// Generates private keys. Taken from openssl 1.0.1c's apps/genpkey.c
// See arguments accpted by doing `$ openssl genpkey help`
////////////////////////////////////////////////////////////////

int genpkey(int argc, char **argv)
{
    ENGINE *e = NULL;
    char **args, *outfile = NULL;
    char *passarg = NULL;
    BIO *in = NULL, *out = NULL;
    const EVP_CIPHER *cipher = NULL;
    int outformat;
    int text = 0;
    EVP_PKEY *pkey=NULL;
    EVP_PKEY_CTX *ctx = NULL;
    char *pass = NULL;
    int badarg = 0;
    int ret = 1, rv;

    int do_param = 0;

    if (bio_err == NULL)
        bio_err = BIO_new_fp (stderr, BIO_NOCLOSE);

    //if (!load_config(bio_err, NULL))
    //goto end;

    outformat=FORMAT_PEM;

    ERR_load_crypto_strings();
    OpenSSL_add_all_algorithms();
    args = argv + 1;
    while (!badarg && *args && *args[0] == '-')
    {
        if (!strcmp(*args,"-outform"))
        {
            if (args[1])
            {
                args++;
                outformat=str2fmt(*args);
            }
            else badarg = 1;
        }
        else if (!strcmp(*args,"-pass"))
        {
            if (!args[1]) goto bad;
            passarg= *(++args);
        }
#ifndef OPENSSL_NO_ENGINE
        else if (strcmp(*args,"-engine") == 0)
        {
            if (!args[1])
                goto bad;
            e = setup_engine(bio_err, *(++args), 0);
        }
#endif
        else if (!strcmp (*args, "-paramfile"))
        {
            if (!args[1])
                goto bad;
            args++;
            if (do_param == 1)
                goto bad;
            if (!init_keygen_file(bio_err, &ctx, *args, e))
                goto end;
        }
        else if (!strcmp (*args, "-out"))
        {
            if (args[1])
            {
                args++;
                outfile = *args;
            }
            else badarg = 1;
        }
        else if (strcmp(*args,"-algorithm") == 0)
        {
            if (!args[1])
                goto bad;
            if (!init_gen_str(bio_err, &ctx, *(++args),e, do_param))
                goto end;
        }
        else if (strcmp(*args,"-pkeyopt") == 0)
        {
            if (!args[1])
                goto bad;
            if (!ctx)
            {
                BIO_puts(bio_err, "No keytype specified\n");
                goto bad;
            }
            else if (pkey_ctrl_string(ctx, *(++args)) <= 0)
            {
                BIO_puts(bio_err, "parameter setting error\n");
                ERR_print_errors(bio_err);
                goto end;
            }
        }
        else if (strcmp(*args,"-genparam") == 0)
        {
            if (ctx)
                goto bad;
            do_param = 1;
        }
        else if (strcmp(*args,"-text") == 0)
            text=1;
        else
        {
            cipher = EVP_get_cipherbyname(*args + 1);
            if (!cipher)
            {
                BIO_printf(bio_err, "Unknown cipher %s\n",
                        *args + 1);
                badarg = 1;
            }
            if (do_param == 1)
                badarg = 1;
        }
        args++;
    }

    if (!ctx)
        badarg = 1;

    if (badarg)
    {
bad:
        BIO_printf(bio_err, "Usage: genpkey [options]\n");
        BIO_printf(bio_err, "where options may be\n");
        BIO_printf(bio_err, "-out file          output file\n");
        BIO_printf(bio_err, "-outform X         output format (DER or PEM)\n");
        BIO_printf(bio_err, "-pass arg          output file pass phrase source\n");
        BIO_printf(bio_err, "-<cipher>          use cipher <cipher> to encrypt the key\n");
#ifndef OPENSSL_NO_ENGINE
        BIO_printf(bio_err, "-engine e          use engine e, possibly a hardware device.\n");
#endif
        BIO_printf(bio_err, "-paramfile file    parameters file\n");
        BIO_printf(bio_err, "-algorithm alg     the public key algorithm\n");
        BIO_printf(bio_err, "-pkeyopt opt:value set the public key algorithm option <opt>\n"
                "                   to value <value>\n");
        BIO_printf(bio_err, "-genparam          generate parameters, not key\n");
        BIO_printf(bio_err, "-text              print the in text\n");
        BIO_printf(bio_err, "NB: options order may be important!  See the manual page.\n");
        goto end;
    }

    if (!app_passwd(bio_err, passarg, NULL, &pass, NULL))
    {
        BIO_puts(bio_err, "Error getting password\n");
        goto end;
    }

    if (outfile)
    {
        if (!(out = BIO_new_file (outfile, "wb")))
        {
            BIO_printf(bio_err,
                    "Can't open output file %s\n", outfile);
            goto end;
        }
    }
    else
    {
        out = BIO_new_fp (stdout, BIO_NOCLOSE);
#ifdef OPENSSL_SYS_VMS
        {
            BIO *tmpbio = BIO_new(BIO_f_linebuffer());
            out = BIO_push(tmpbio, out);
        }
#endif
    }

    EVP_PKEY_CTX_set_cb(ctx, genpkey_cb);
    EVP_PKEY_CTX_set_app_data(ctx, bio_err);

    if (do_param)
    {
        if (EVP_PKEY_paramgen(ctx, &pkey) <= 0)
        {
            BIO_puts(bio_err, "Error generating parameters\n");
            ERR_print_errors(bio_err);
            goto end;
        }
    }
    else
    {
        if (EVP_PKEY_keygen(ctx, &pkey) <= 0)
        {
            BIO_puts(bio_err, "Error generating key\n");
            ERR_print_errors(bio_err);
            goto end;
        }
    }

    if (do_param)
        rv = PEM_write_bio_Parameters(out, pkey);
    else if (outformat == FORMAT_PEM) 
        rv = PEM_write_bio_PrivateKey(out, pkey, cipher, NULL, 0,
                NULL, pass);
    else if (outformat == FORMAT_ASN1)
        rv = i2d_PrivateKey_bio(out, pkey);
    else
    {
        BIO_printf(bio_err, "Bad format specified for key\n");
        goto end;
    }

    if (rv <= 0)
    {
        BIO_puts(bio_err, "Error writing key\n");
        ERR_print_errors(bio_err);
    }

    if (text)
    {
        if (do_param)
            rv = EVP_PKEY_print_params(out, pkey, 0, NULL);
        else
            rv = EVP_PKEY_print_private(out, pkey, 0, NULL);

        if (rv <= 0)
        {
            BIO_puts(bio_err, "Error printing key\n");
            ERR_print_errors(bio_err);
        }
    }

    ret = 0;

end:
    if (pkey)
        EVP_PKEY_free(pkey);
    if (ctx)
        EVP_PKEY_CTX_free(ctx);
    if (out)
        BIO_free_all(out);
    BIO_free(in);
    if (pass)
        OPENSSL_free(pass);

    return ret;
}


static int init_keygen_file(BIO *err, EVP_PKEY_CTX **pctx,
        const char *file, ENGINE *e)
{
    BIO *pbio;
    EVP_PKEY *pkey = NULL;
    EVP_PKEY_CTX *ctx = NULL;
    if (*pctx)
    {
        BIO_puts(err, "Parameters already set!\n");
        return 0;
    }

    pbio = BIO_new_file(file, "r");
    if (!pbio)
    {
        BIO_printf(err, "Can't open parameter file %s\n", file);
        return 0;
    }

    pkey = PEM_read_bio_Parameters(pbio, NULL);
    BIO_free(pbio);

    if (!pkey)
    {
        BIO_printf(bio_err, "Error reading parameter file %s\n", file);
        return 0;
    }

    ctx = EVP_PKEY_CTX_new(pkey, e);
    if (!ctx)
        goto err;
    if (EVP_PKEY_keygen_init(ctx) <= 0)
        goto err;
    EVP_PKEY_free(pkey);
    *pctx = ctx;
    return 1;

err:
    BIO_puts(err, "Error initializing context\n");
    ERR_print_errors(err);
    if (ctx)
        EVP_PKEY_CTX_free(ctx);
    if (pkey)
        EVP_PKEY_free(pkey);
    return 0;

}

int init_gen_str(BIO *err, EVP_PKEY_CTX **pctx,
        const char *algname, ENGINE *e, int do_param)
{
    EVP_PKEY_CTX *ctx = NULL;
    const EVP_PKEY_ASN1_METHOD *ameth;
    ENGINE *tmpeng = NULL;
    int pkey_id;

    if (*pctx)
    {
        BIO_puts(err, "Algorithm already set!\n");
        return 0;
    }

    ameth = EVP_PKEY_asn1_find_str(&tmpeng, algname, -1);

#ifndef OPENSSL_NO_ENGINE
    if (!ameth && e)
        ameth = ENGINE_get_pkey_asn1_meth_str(e, algname, -1);
#endif

    if (!ameth)
    {
        BIO_printf(bio_err, "Algorithm %s not found\n", algname);
        return 0;
    }

    ERR_clear_error();

    EVP_PKEY_asn1_get0_info(&pkey_id, NULL, NULL, NULL, NULL, ameth);
#ifndef OPENSSL_NO_ENGINE
    if (tmpeng)
        ENGINE_finish(tmpeng);
#endif
    ctx = EVP_PKEY_CTX_new_id(pkey_id, e);

    if (!ctx)
        goto err;
    if (do_param)
    {
        if (EVP_PKEY_paramgen_init(ctx) <= 0)
            goto err;
    }
    else
    {
        if (EVP_PKEY_keygen_init(ctx) <= 0)
            goto err;
    }

    *pctx = ctx;
    return 1;

err:
    BIO_printf(err, "Error initializing %s context\n", algname);
    ERR_print_errors(err);
    if (ctx)
        EVP_PKEY_CTX_free(ctx);
    return 0;

}

static int genpkey_cb(EVP_PKEY_CTX *ctx)
{
    char c='*';
    BIO *b = EVP_PKEY_CTX_get_app_data(ctx);
    int p;
    p = EVP_PKEY_CTX_get_keygen_info(ctx, 0);
    if (p == 0) c='.';
    if (p == 1) c='+';
    if (p == 2) c='*';
    if (p == 3) c='\n';
    BIO_write(b,&c,1);
    (void)BIO_flush(b);
#ifdef LINT
    p=n;
#endif
    return 1;
}

////////////////////////////////////////////////////////////////
// Generates public key from private key. Taken from openssl 1.0.1c's
// apps/rsa.c
// See arguments accpted by doing `$ openssl rsa help`
////////////////////////////////////////////////////////////////


/* -inform arg	- input format - default PEM (one of DER, NET or PEM)
 * -outform arg - output format - default PEM
 * -in arg	- input file - default stdin
 * -out arg	- output file - default stdout
 * -des		- encrypt output if PEM format with DES in cbc mode
 * -des3	- encrypt output if PEM format
 * -idea	- encrypt output if PEM format
 * -seed	- encrypt output if PEM format
 * -aes128	- encrypt output if PEM format
 * -aes192	- encrypt output if PEM format
 * -aes256	- encrypt output if PEM format
 * -camellia128 - encrypt output if PEM format
 * -camellia192 - encrypt output if PEM format
 * -camellia256 - encrypt output if PEM format
 * -text	- print a text version
 * -modulus	- print the RSA key modulus
 * -check	- verify key consistency
 * -pubin	- Expect a public key in input file.
 * -pubout	- Output a public key.
 */

int rsa(int argc, char **argv)
{
    ENGINE *e = NULL;
    int ret=1;
    RSA *rsa=NULL;
    int i,badops=0, sgckey=0;
    const EVP_CIPHER *enc=NULL;
    BIO *out=NULL;
    int informat,outformat,text=0,check=0,noout=0;
    int pubin = 0, pubout = 0;
    char *infile,*outfile,*prog;
    char *passargin = NULL, *passargout = NULL;
    char *passin = NULL, *passout = NULL;
#ifndef OPENSSL_NO_ENGINE
    char *engine=NULL;
#endif
    int modulus=0;

    int pvk_encr = 2;

    apps_startup();

    if (bio_err == NULL)
        if ((bio_err=BIO_new(BIO_s_file())) != NULL)
            BIO_set_fp(bio_err,stderr,BIO_NOCLOSE|BIO_FP_TEXT);

    //if (!load_config(bio_err, NULL))
        //goto end;

    infile=NULL;
    outfile=NULL;
    informat=FORMAT_PEM;
    outformat=FORMAT_PEM;

    prog=argv[0];
    argc--;
    argv++;
    while (argc >= 1)
    {
        if 	(strcmp(*argv,"-inform") == 0)
        {
            if (--argc < 1) goto bad;
            informat=str2fmt(*(++argv));
        }
        else if (strcmp(*argv,"-outform") == 0)
        {
            if (--argc < 1) goto bad;
            outformat=str2fmt(*(++argv));
        }
        else if (strcmp(*argv,"-in") == 0)
        {
            if (--argc < 1) goto bad;
            infile= *(++argv);
        }
        else if (strcmp(*argv,"-out") == 0)
        {
            if (--argc < 1) goto bad;
            outfile= *(++argv);
        }
        else if (strcmp(*argv,"-passin") == 0)
        {
            if (--argc < 1) goto bad;
            passargin= *(++argv);
        }
        else if (strcmp(*argv,"-passout") == 0)
        {
            if (--argc < 1) goto bad;
            passargout= *(++argv);
        }
#ifndef OPENSSL_NO_ENGINE
        else if (strcmp(*argv,"-engine") == 0)
        {
            if (--argc < 1) goto bad;
            engine= *(++argv);
        }
#endif
        else if (strcmp(*argv,"-sgckey") == 0)
            sgckey=1;
        else if (strcmp(*argv,"-pubin") == 0)
            pubin=1;
        else if (strcmp(*argv,"-pubout") == 0)
            pubout=1;
        else if (strcmp(*argv,"-RSAPublicKey_in") == 0)
            pubin = 2;
        else if (strcmp(*argv,"-RSAPublicKey_out") == 0)
            pubout = 2;
        else if (strcmp(*argv,"-pvk-strong") == 0)
            pvk_encr=2;
        else if (strcmp(*argv,"-pvk-weak") == 0)
            pvk_encr=1;
        else if (strcmp(*argv,"-pvk-none") == 0)
            pvk_encr=0;
        else if (strcmp(*argv,"-noout") == 0)
            noout=1;
        else if (strcmp(*argv,"-text") == 0)
            text=1;
        else if (strcmp(*argv,"-modulus") == 0)
            modulus=1;
        else if (strcmp(*argv,"-check") == 0)
            check=1;
        else if ((enc=EVP_get_cipherbyname(&(argv[0][1]))) == NULL)
        {
            BIO_printf(bio_err,"unknown option %s\n",*argv);
            badops=1;
            break;
        }
        argc--;
        argv++;
    }

    if (badops)
    {
bad:
        BIO_printf(bio_err,"%s [options] <infile >outfile\n",prog);
        BIO_printf(bio_err,"where options are\n");
        BIO_printf(bio_err," -inform arg     input format - one of DER NET PEM\n");
        BIO_printf(bio_err," -outform arg    output format - one of DER NET PEM\n");
        BIO_printf(bio_err," -in arg         input file\n");
        BIO_printf(bio_err," -sgckey         Use IIS SGC key format\n");
        BIO_printf(bio_err," -passin arg     input file pass phrase source\n");
        BIO_printf(bio_err," -out arg        output file\n");
        BIO_printf(bio_err," -passout arg    output file pass phrase source\n");
        BIO_printf(bio_err," -des            encrypt PEM output with cbc des\n");
        BIO_printf(bio_err," -des3           encrypt PEM output with ede cbc des using 168 bit key\n");
#ifndef OPENSSL_NO_IDEA
        BIO_printf(bio_err," -idea           encrypt PEM output with cbc idea\n");
#endif
#ifndef OPENSSL_NO_SEED
        BIO_printf(bio_err," -seed           encrypt PEM output with cbc seed\n");
#endif
#ifndef OPENSSL_NO_AES
        BIO_printf(bio_err," -aes128, -aes192, -aes256\n");
        BIO_printf(bio_err,"                 encrypt PEM output with cbc aes\n");
#endif
#ifndef OPENSSL_NO_CAMELLIA
        BIO_printf(bio_err," -camellia128, -camellia192, -camellia256\n");
        BIO_printf(bio_err,"                 encrypt PEM output with cbc camellia\n");
#endif
        BIO_printf(bio_err," -text           print the key in text\n");
        BIO_printf(bio_err," -noout          don't print key out\n");
        BIO_printf(bio_err," -modulus        print the RSA key modulus\n");
        BIO_printf(bio_err," -check          verify key consistency\n");
        BIO_printf(bio_err," -pubin          expect a public key in input file\n");
        BIO_printf(bio_err," -pubout         output a public key\n");
#ifndef OPENSSL_NO_ENGINE
        BIO_printf(bio_err," -engine e       use engine e, possibly a hardware device.\n");
#endif
        goto end;
    }

    ERR_load_crypto_strings();

#ifndef OPENSSL_NO_ENGINE
    e = setup_engine(bio_err, engine, 0);
#endif

    if(!app_passwd(bio_err, passargin, passargout, &passin, &passout)) {
        BIO_printf(bio_err, "Error getting passwords\n");
        goto end;
    }

    if(check && pubin) {
        BIO_printf(bio_err, "Only private keys can be checked\n");
        goto end;
    }

    out=BIO_new(BIO_s_file());

    {
        EVP_PKEY	*pkey;

        if (pubin)
        {
            int tmpformat=-1;
            if (pubin == 2)
            {
                if (informat == FORMAT_PEM)
                    tmpformat = FORMAT_PEMRSA;
                else if (informat == FORMAT_ASN1)
                    tmpformat = FORMAT_ASN1RSA;
            }
            else if (informat == FORMAT_NETSCAPE && sgckey)
                tmpformat = FORMAT_IISSGC;
            else
                tmpformat = informat;

            pkey = load_pubkey(bio_err, infile, tmpformat, 1,
                    passin, e, "Public Key");
        }
        else
            pkey = load_key(bio_err, infile,
                    (informat == FORMAT_NETSCAPE && sgckey ?
                     FORMAT_IISSGC : informat), 1,
                    passin, e, "Private Key");

        if (pkey != NULL)
            rsa = EVP_PKEY_get1_RSA(pkey);
        EVP_PKEY_free(pkey);
    }

    if (rsa == NULL)
    {
        ERR_print_errors(bio_err);
        goto end;
    }

    if (outfile == NULL)
    {
        BIO_set_fp(out,stdout,BIO_NOCLOSE);
#ifdef OPENSSL_SYS_VMS
        {
            BIO *tmpbio = BIO_new(BIO_f_linebuffer());
            out = BIO_push(tmpbio, out);
        }
#endif
    }
    else
    {
        if (BIO_write_filename(out,outfile) <= 0)
        {
            perror(outfile);
            goto end;
        }
    }

    if (text) 
        if (!RSA_print(out,rsa,0))
        {
            perror(outfile);
            ERR_print_errors(bio_err);
            goto end;
        }

    if (modulus)
    {
        BIO_printf(out,"Modulus=");
        BN_print(out,rsa->n);
        BIO_printf(out,"\n");
    }

    if (check)
    {
        int r = RSA_check_key(rsa);

        if (r == 1)
            BIO_printf(out,"RSA key ok\n");
        else if (r == 0)
        {
            unsigned long err;

            while ((err = ERR_peek_error()) != 0 &&
                    ERR_GET_LIB(err) == ERR_LIB_RSA &&
                    ERR_GET_FUNC(err) == RSA_F_RSA_CHECK_KEY &&
                    ERR_GET_REASON(err) != ERR_R_MALLOC_FAILURE)
            {
                BIO_printf(out, "RSA key error: %s\n", ERR_reason_error_string(err));
                ERR_get_error(); /* remove e from error stack */
            }
        }

        if (r == -1 || ERR_peek_error() != 0) /* should happen only if r == -1 */
        {
            ERR_print_errors(bio_err);
            goto end;
        }
    }

    if (noout)
    {
        ret = 0;
        goto end;
    }
    BIO_printf(bio_err,"writing RSA key\n");
    if 	(outformat == FORMAT_ASN1) {
        if(pubout || pubin) 
        {
            if (pubout == 2)
                i=i2d_RSAPublicKey_bio(out,rsa);
            else
                i=i2d_RSA_PUBKEY_bio(out,rsa);
        }
        else i=i2d_RSAPrivateKey_bio(out,rsa);
    }
#ifndef OPENSSL_NO_RC4
    else if (outformat == FORMAT_NETSCAPE)
    {
        unsigned char *p,*pp;
        int size;

        i=1;
        size=i2d_RSA_NET(rsa,NULL,NULL, sgckey);
        if ((p=(unsigned char *)OPENSSL_malloc(size)) == NULL)
        {
            BIO_printf(bio_err,"Memory allocation failure\n");
            goto end;
        }
        pp=p;
        i2d_RSA_NET(rsa,&p,NULL, sgckey);
        BIO_write(out,(char *)pp,size);
        OPENSSL_free(pp);
    }
#endif
    else if (outformat == FORMAT_PEM) {
        if(pubout || pubin)
        {
            if (pubout == 2)
                i=PEM_write_bio_RSAPublicKey(out,rsa);
            else
                i=PEM_write_bio_RSA_PUBKEY(out,rsa);
        }
        else i=PEM_write_bio_RSAPrivateKey(out,rsa,
                enc,NULL,0,NULL,passout);
#if !defined(OPENSSL_NO_DSA) && !defined(OPENSSL_NO_RC4)
    } else if (outformat == FORMAT_MSBLOB || outformat == FORMAT_PVK) {
        EVP_PKEY *pk;
        pk = EVP_PKEY_new();
        EVP_PKEY_set1_RSA(pk, rsa);
        if (outformat == FORMAT_PVK)
            i = i2b_PVK_bio(out, pk, pvk_encr, 0, passout);
        else if (pubin || pubout)
            i = i2b_PublicKey_bio(out, pk);
        else
            i = i2b_PrivateKey_bio(out, pk);
        EVP_PKEY_free(pk);
#endif
    } else	{
        BIO_printf(bio_err,"bad output format specified for outfile\n");
        goto end;
    }
    if (i <= 0)
    {
        BIO_printf(bio_err,"unable to write key\n");
        ERR_print_errors(bio_err);
    }
    else
        ret=0;
end:
    if(out != NULL) BIO_free_all(out);
    if(rsa != NULL) RSA_free(rsa);
    if(passin) OPENSSL_free(passin);
    if(passout) OPENSSL_free(passout);
    apps_shutdown();
    OPENSSL_EXIT(ret);
}


#define RSA_SIGN 	1
#define RSA_VERIFY 	2
#define RSA_ENCRYPT 	3
#define RSA_DECRYPT 	4

#define KEY_PRIVKEY	1
#define KEY_PUBKEY	2
#define KEY_CERT	3

////////////////////////////////////////////////////////////////
// Generates public key from private key. Taken from openssl 1.0.1c's
// apps/rsautl.c
// See arguments accpted by doing `$ openssl rsautl help`
// Additional options to pass data as buffers and not files:
//  -instring
//  -outstring
////////////////////////////////////////////////////////////////
int rsautl(int argc, char **argv, struct rsautl_args *rsautlargs)
{
	ENGINE *e = NULL;
	BIO *in = NULL, *out = NULL;
	char *infile = NULL, *outfile = NULL;
#ifndef OPENSSL_NO_ENGINE
	char *engine = NULL;
#endif
	char *keyfile = NULL;
	char rsa_mode = RSA_VERIFY, key_type = KEY_PRIVKEY;
	int keyform = FORMAT_PEM;
	char need_priv = 0, badarg = 0, rev = 0;
	char hexdump = 0, asn1parse = 0;
	X509 *x;
	EVP_PKEY *pkey = NULL;
	RSA *rsa = NULL;
	unsigned char *rsa_in = NULL, *rsa_out = NULL, pad;
	char *passargin = NULL, *passin = NULL;
	int rsa_inlen, rsa_outlen = 0;
	int keysize;
    struct rsautl_args *ycargs = NULL;
    
	int ret = 1;
    
	argc--;
	argv++;
    
	if(!bio_err) bio_err = BIO_new_fp(stderr, BIO_NOCLOSE);
    
	//if (!load_config(bio_err, NULL))
    //goto end;
    
	ERR_load_crypto_strings();
	OpenSSL_add_all_algorithms();
	pad = RSA_PKCS1_PADDING;
	
	while(argc >= 1)
	{
		if (!strcmp(*argv,"-in")) {
			if (--argc < 1)
				badarg = 1;
			else
                infile= *(++argv);
		}
        // Added by avr for Youcrypt
        else if (!strcmp(*argv,"-inbuf")) {
                ycargs = rsautlargs;
		} else if (!strcmp(*argv,"-out")) {
			if (--argc < 1)
				badarg = 1;
			else
				outfile= *(++argv);
		} else if(!strcmp(*argv, "-inkey")) {
			if (--argc < 1)
				badarg = 1;
			else
				keyfile = *(++argv);
		} else if (!strcmp(*argv,"-passin")) {
			if (--argc < 1)
				badarg = 1;
			else
				passargin= *(++argv);
		} else if (strcmp(*argv,"-keyform") == 0) {
			if (--argc < 1)
				badarg = 1;
			else
				keyform=str2fmt(*(++argv));
#ifndef OPENSSL_NO_ENGINE
		} else if(!strcmp(*argv, "-engine")) {
			if (--argc < 1)
				badarg = 1;
			else
				engine = *(++argv);
#endif
		} else if(!strcmp(*argv, "-pubin")) {
			key_type = KEY_PUBKEY;
		} else if(!strcmp(*argv, "-certin")) {
			key_type = KEY_CERT;
		} 
		else if(!strcmp(*argv, "-asn1parse")) asn1parse = 1;
		else if(!strcmp(*argv, "-hexdump")) hexdump = 1;
		else if(!strcmp(*argv, "-raw")) pad = RSA_NO_PADDING;
		else if(!strcmp(*argv, "-oaep")) pad = RSA_PKCS1_OAEP_PADDING;
		else if(!strcmp(*argv, "-ssl")) pad = RSA_SSLV23_PADDING;
		else if(!strcmp(*argv, "-pkcs")) pad = RSA_PKCS1_PADDING;
		else if(!strcmp(*argv, "-x931")) pad = RSA_X931_PADDING;
		else if(!strcmp(*argv, "-sign")) {
			rsa_mode = RSA_SIGN;
			need_priv = 1;
		} else if(!strcmp(*argv, "-verify")) rsa_mode = RSA_VERIFY;
		else if(!strcmp(*argv, "-rev")) rev = 1;
		else if(!strcmp(*argv, "-encrypt")) rsa_mode = RSA_ENCRYPT;
		else if(!strcmp(*argv, "-decrypt")) {
			rsa_mode = RSA_DECRYPT;
			need_priv = 1;
		} else badarg = 1;
        if(badarg) {
            BIO_printf(bio_err, "Usage: rsautl [options]\n");
            BIO_printf(bio_err, "-in file        input file\n");
            BIO_printf(bio_err, "-out file       output file\n");
            BIO_printf(bio_err, "-inkey file     input key\n");
            BIO_printf(bio_err, "-keyform arg    private key format - default PEM\n");
            BIO_printf(bio_err, "-pubin          input is an RSA public\n");
            BIO_printf(bio_err, "-certin         input is a certificate carrying an RSA public key\n");
            BIO_printf(bio_err, "-ssl            use SSL v2 padding\n");
            BIO_printf(bio_err, "-raw            use no padding\n");
            BIO_printf(bio_err, "-pkcs           use PKCS#1 v1.5 padding (default)\n");
            BIO_printf(bio_err, "-oaep           use PKCS#1 OAEP\n");
            BIO_printf(bio_err, "-sign           sign with private key\n");
            BIO_printf(bio_err, "-verify         verify with public key\n");
            BIO_printf(bio_err, "-encrypt        encrypt with public key\n");
            BIO_printf(bio_err, "-decrypt        decrypt with private key\n");
            BIO_printf(bio_err, "-hexdump        hex dump output\n");
#ifndef OPENSSL_NO_ENGINE
            BIO_printf(bio_err, "-engine e       use engine e, possibly a hardware device.\n");
            BIO_printf (bio_err, "-passin arg    pass phrase source\n");
#endif
            goto end;
        }
		argc--;
		argv++;
	}
    
	if(need_priv && (key_type != KEY_PRIVKEY)) {
		BIO_printf(bio_err, "A private key is needed for this operation\n");
		goto end;
	}
    
#ifndef OPENSSL_NO_ENGINE
    e = setup_engine(bio_err, engine, 0);
#endif
	if(!app_passwd(bio_err, passargin, NULL, &passin, NULL)) {
		BIO_printf(bio_err, "Error getting password\n");
		goto end;
	}
    
    /* FIXME: seed PRNG only if needed */
	app_RAND_load_file(NULL, bio_err, 0);
	
	switch(key_type) {
		case KEY_PRIVKEY:
            pkey = load_key(bio_err, keyfile, keyform, 0,
                            passin, e, "Private Key");
            break;
            
		case KEY_PUBKEY:
            pkey = load_pubkey(bio_err, keyfile, keyform, 0,
                               NULL, e, "Public Key");
            break;
            
		case KEY_CERT:
            x = load_cert(bio_err, keyfile, keyform,
                          NULL, e, "Certificate");
            if(x) {
                pkey = X509_get_pubkey(x);
                X509_free(x);
            }
            break;
	}
    
	if(!pkey) {
		return 1;
	}
    
	rsa = EVP_PKEY_get1_RSA(pkey);
	EVP_PKEY_free(pkey);
    
	if(!rsa) {
		BIO_printf(bio_err, "Error getting RSA key\n");
		ERR_print_errors(bio_err);
		goto end;
	}
    
    
	if(infile) {
		if(!(in = BIO_new_file(infile, "rb"))) {
			BIO_printf(bio_err, "Error Reading Input File\n");
			ERR_print_errors(bio_err);	
			goto end;
		}
	} else if (ycargs) { // avr
        in = BIO_new_mem_buf(ycargs->inbuf, ycargs->insize);
    } else in = BIO_new_fp(stdin, BIO_NOCLOSE);
    
	if(outfile) {
		if(!(out = BIO_new_file(outfile, "wb"))) {
			BIO_printf(bio_err, "Error Reading Output File\n");
			ERR_print_errors(bio_err);	
			goto end;
		}
	} else if (ycargs) { // avr
        out = BIO_new(BIO_s_mem());
    } else {
		out = BIO_new_fp(stdout, BIO_NOCLOSE);
#ifdef OPENSSL_SYS_VMS
		{
		    BIO *tmpbio = BIO_new(BIO_f_linebuffer());
		    out = BIO_push(tmpbio, out);
		}
#endif
	}
    
	keysize = RSA_size(rsa);
    
	rsa_in = OPENSSL_malloc(keysize * 2);
	rsa_out = OPENSSL_malloc(keysize);
    
	/* Read the input data */
	rsa_inlen = BIO_read(in, rsa_in, keysize * 2);
	if(rsa_inlen <= 0) {
		BIO_printf(bio_err, "Error reading input Data\n");
		exit(1);
	}
	if(rev) {
		int i;
		unsigned char ctmp;
		for(i = 0; i < rsa_inlen/2; i++) {
			ctmp = rsa_in[i];
			rsa_in[i] = rsa_in[rsa_inlen - 1 - i];
			rsa_in[rsa_inlen - 1 - i] = ctmp;
		}
	}
	switch(rsa_mode) {
            
		case RSA_VERIFY:
			rsa_outlen  = RSA_public_decrypt(rsa_inlen, rsa_in, rsa_out, rsa, pad);
            break;
            
		case RSA_SIGN:
			rsa_outlen  = RSA_private_encrypt(rsa_inlen, rsa_in, rsa_out, rsa, pad);
            break;
            
		case RSA_ENCRYPT:
			rsa_outlen  = RSA_public_encrypt(rsa_inlen, rsa_in, rsa_out, rsa, pad);
            break;
            
		case RSA_DECRYPT:
			rsa_outlen  = RSA_private_decrypt(rsa_inlen, rsa_in, rsa_out, rsa, pad);
            break;
            
	}
    
	if(rsa_outlen <= 0) {
		BIO_printf(bio_err, "RSA operation error\n");
		ERR_print_errors(bio_err);
		goto end;
	}
	ret = 0;
	if(asn1parse) {
		if(!ASN1_parse_dump(out, rsa_out, rsa_outlen, 1, -1)) {
			ERR_print_errors(bio_err);
		}
	} else if(hexdump) {
        BIO_dump(out, (char *)rsa_out, rsa_outlen);
    } else if (ycargs) {
//        ycargs->outsize = BIO_get_mem_data(rsa_out, &ycargs->outbuf);
//        ycargs->outsize = bio_to_mem(ycargs->outbuf, rsa_outlen, (char*)rsa_out);
        ycargs->outsize = rsa_outlen;
        *ycargs->outbuf = (unsigned char*)malloc(rsa_outlen);
        if (*ycargs->outbuf) {
            memcpy(*ycargs->outbuf, rsa_out, rsa_outlen);
        }
    } else
        BIO_write(out, rsa_out, rsa_outlen);
    
        
end:
	RSA_free(rsa);
	BIO_free(in);
	BIO_free_all(out);
	if(rsa_in) OPENSSL_free(rsa_in);
	if(rsa_out) OPENSSL_free(rsa_out);
	if(passin) OPENSSL_free(passin);
	return ret;
}

int str2fmt(char *s)
{
    if (s == NULL)
        return FORMAT_UNDEF;
    if 	((*s == 'D') || (*s == 'd'))
        return(FORMAT_ASN1);
    else if ((*s == 'T') || (*s == 't'))
        return(FORMAT_TEXT);
    else if ((*s == 'N') || (*s == 'n'))
        return(FORMAT_NETSCAPE);
    else if ((*s == 'S') || (*s == 's'))
        return(FORMAT_SMIME);
    else if ((*s == 'M') || (*s == 'm'))
        return(FORMAT_MSBLOB);
    else if ((*s == '1')
            || (strcmp(s,"PKCS12") == 0) || (strcmp(s,"pkcs12") == 0)
            || (strcmp(s,"P12") == 0) || (strcmp(s,"p12") == 0))
        return(FORMAT_PKCS12);
    else if ((*s == 'E') || (*s == 'e'))
        return(FORMAT_ENGINE);
    else if ((*s == 'P') || (*s == 'p'))
    {
        if (s[1] == 'V' || s[1] == 'v')
            return FORMAT_PVK;
        else
            return(FORMAT_PEM);
    }
    else
        return(FORMAT_UNDEF);
}


int pkey_ctrl_string(EVP_PKEY_CTX *ctx, char *value)
{
    int rv;
    char *stmp, *vtmp = NULL;
    stmp = BUF_strdup(value);
    if (!stmp)
        return -1;
    vtmp = strchr(stmp, ':');
    if (vtmp)
    {
        *vtmp = 0;
        vtmp++;
    }
    rv = EVP_PKEY_CTX_ctrl_str(ctx, stmp, vtmp);
    OPENSSL_free(stmp);
    return rv;
}
int app_passwd(BIO *err, char *arg1, char *arg2, char **pass1, char **pass2)
{
	int same;
	if(!arg2 || !arg1 || strcmp(arg1, arg2)) same = 0;
	else same = 1;
	if(arg1) {
		*pass1 = app_get_pass(err, arg1, same);
		if(!*pass1) return 0;
	} else if(pass1) *pass1 = NULL;
	if(arg2) {
		*pass2 = app_get_pass(err, arg2, same ? 2 : 0);
		if(!*pass2) return 0;
	} else if(pass2) *pass2 = NULL;
	return 1;
}

static char *app_get_pass(BIO *err, char *arg, int keepbio)
{
    char *tmp, tpass[APP_PASS_LEN];
    static BIO *pwdbio = NULL;
    int i;
    if(!strncmp(arg, "pass:", 5)) return BUF_strdup(arg + 5);
    if(!strncmp(arg, "env:", 4)) {
        tmp = getenv(arg + 4);
        if(!tmp) {
            BIO_printf(err, "Can't read environment variable %s\n", arg + 4);
            return NULL;
        }
        return BUF_strdup(tmp);
    }
    if(!keepbio || !pwdbio) {
        if(!strncmp(arg, "file:", 5)) {
            pwdbio = BIO_new_file(arg + 5, "r");
            if(!pwdbio) {
                BIO_printf(err, "Can't open file %s\n", arg + 5);
                return NULL;
            }
#if !defined(_WIN32)
            /*
             * Under _WIN32, which covers even Win64 and CE, file
             * descriptors referenced by BIO_s_fd are not inherited
             * by child process and therefore below is not an option.
             * It could have been an option if bss_fd.c was operating
             * on real Windows descriptors, such as those obtained
             * with CreateFile.
             */
        } else if(!strncmp(arg, "fd:", 3)) {
            BIO *btmp;
            i = atoi(arg + 3);
            if(i >= 0) pwdbio = BIO_new_fd(i, BIO_NOCLOSE);
            if((i < 0) || !pwdbio) {
                BIO_printf(err, "Can't access file descriptor %s\n", arg + 3);
                return NULL;
            }
            /* Can't do BIO_gets on an fd BIO so add a buffering BIO */
            btmp = BIO_new(BIO_f_buffer());
            pwdbio = BIO_push(btmp, pwdbio);
#endif
        } else if(!strcmp(arg, "stdin")) {
            pwdbio = BIO_new_fp(stdin, BIO_NOCLOSE);
            if(!pwdbio) {
                BIO_printf(err, "Can't open BIO for stdin\n");
                return NULL;
            }
        } else {
            BIO_printf(err, "Invalid password argument \"%s\"\n", arg);
            return NULL;
        }
    }
    i = BIO_gets(pwdbio, tpass, APP_PASS_LEN);
    if(keepbio != 1) {
        BIO_free_all(pwdbio);
        pwdbio = NULL;
    }
    if(i <= 0) {
        BIO_printf(err, "Error reading password from BIO\n");
        return NULL;
    }
    tmp = strchr(tpass, '\n');
    if(tmp) *tmp = 0;
    return BUF_strdup(tpass);
}

EVP_PKEY *load_pubkey(BIO *err, const char *file, int format, int maybe_stdin,
	const char *pass, ENGINE *e, const char *key_descrip)
{
    BIO *key=NULL;
    EVP_PKEY *pkey=NULL;
    PW_CB_DATA cb_data;

    cb_data.password = pass;
    cb_data.prompt_info = file;

    if (file == NULL && (!maybe_stdin || format == FORMAT_ENGINE))
    {
        BIO_printf(err,"no keyfile specified\n");
        goto end;
    }
#ifndef OPENSSL_NO_ENGINE
    if (format == FORMAT_ENGINE)
    {
        if (!e)
            BIO_printf(bio_err,"no engine specified\n");
        else
            pkey = ENGINE_load_public_key(e, file,
                    ui_method, &cb_data);
        goto end;
    }
#endif
    key=BIO_new(BIO_s_file());
    if (key == NULL)
    {
        ERR_print_errors(err);
        goto end;
    }
    if (file == NULL && maybe_stdin)
    {
#ifdef _IONBF
# ifndef OPENSSL_NO_SETVBUF_IONBF
        setvbuf(stdin, NULL, _IONBF, 0);
# endif /* ndef OPENSSL_NO_SETVBUF_IONBF */
#endif
        BIO_set_fp(key,stdin,BIO_NOCLOSE);
    }
    else
        if (BIO_read_filename(key,file) <= 0)
        {
            BIO_printf(err, "Error opening %s %s\n",
                    key_descrip, file);
            ERR_print_errors(err);
            goto end;
        }
    if (format == FORMAT_ASN1)
    {
        pkey=d2i_PUBKEY_bio(key, NULL);
    }
#ifndef OPENSSL_NO_RSA
    else if (format == FORMAT_ASN1RSA)
    {
        RSA *rsa;
        rsa = d2i_RSAPublicKey_bio(key, NULL);
        if (rsa)
        {
            pkey = EVP_PKEY_new();
            if (pkey)
                EVP_PKEY_set1_RSA(pkey, rsa);
            RSA_free(rsa);
        }
        else
            pkey = NULL;
    }
    else if (format == FORMAT_PEMRSA)
    {
        RSA *rsa;
        rsa = PEM_read_bio_RSAPublicKey(key, NULL, 
                (pem_password_cb *)password_callback, &cb_data);
        if (rsa)
        {
            pkey = EVP_PKEY_new();
            if (pkey)
                EVP_PKEY_set1_RSA(pkey, rsa);
            RSA_free(rsa);
        }
        else
            pkey = NULL;
    }
#endif
    else if (format == FORMAT_PEM)
    {
        pkey=PEM_read_bio_PUBKEY(key,NULL,
                (pem_password_cb *)password_callback, &cb_data);
    }
#if !defined(OPENSSL_NO_RSA) && !defined(OPENSSL_NO_DSA)
    else if (format == FORMAT_MSBLOB)
        pkey = b2i_PublicKey_bio(key);
#endif
    else
    {
        BIO_printf(err,"bad input format specified for key file\n");
        goto end;
    }
end:
    if (key != NULL) BIO_free(key);
    if (pkey == NULL)
        BIO_printf(err,"unable to load %s\n", key_descrip);
    return(pkey);
}

EVP_PKEY *load_key(BIO *err, const char *file, int format, int maybe_stdin,
	const char *pass, ENGINE *e, const char *key_descrip)
{
    BIO *key=NULL;
    EVP_PKEY *pkey=NULL;
    PW_CB_DATA cb_data;

    cb_data.password = pass;
    cb_data.prompt_info = file;

    if (file == NULL && (!maybe_stdin || format == FORMAT_ENGINE))
    {
        BIO_printf(err,"no keyfile specified\n");
        goto end;
    }
#ifndef OPENSSL_NO_ENGINE
    if (format == FORMAT_ENGINE)
    {
        if (!e)
            BIO_printf(err,"no engine specified\n");
        else
        {
            pkey = ENGINE_load_private_key(e, file,
                    ui_method, &cb_data);
            if (!pkey) 
            {
                BIO_printf(err,"cannot load %s from engine\n",key_descrip);
                ERR_print_errors(err);
            }	
        }
        goto end;
    }
#endif
    key=BIO_new(BIO_s_file());
    if (key == NULL)
    {
        ERR_print_errors(err);
        goto end;
    }
    if (file == NULL && maybe_stdin)
    {
#ifdef _IONBF
# ifndef OPENSSL_NO_SETVBUF_IONBF
        setvbuf(stdin, NULL, _IONBF, 0);
# endif /* ndef OPENSSL_NO_SETVBUF_IONBF */
#endif
        BIO_set_fp(key,stdin,BIO_NOCLOSE);
    }
    else
        if (BIO_read_filename(key,file) <= 0)
        {
            BIO_printf(err, "Error opening %s %s\n",
                    key_descrip, file);
            ERR_print_errors(err);
            goto end;
        }
    if (format == FORMAT_ASN1)
    {
        pkey=d2i_PrivateKey_bio(key, NULL);
    }
    else if (format == FORMAT_PEM)
    {
        //pkey=PEM_read_bio_PrivateKey(key,NULL,
                //(pem_password_cb *)password_callback, &cb_data);
        pkey=PEM_read_bio_PrivateKey(key,NULL,
                NULL, "asdfgh");
    }
#if !defined(OPENSSL_NO_RC4) && !defined(OPENSSL_NO_RSA)
    //else if (format == FORMAT_NETSCAPE || format == FORMAT_IISSGC)
        //pkey = load_netscape_key(err, key, file, key_descrip, format);
#endif
    //else if (format == FORMAT_PKCS12)
    //{
        //if (!load_pkcs12(err, key, key_descrip,
                    //(pem_password_cb *)password_callback, &cb_data,
                    //&pkey, NULL, NULL))
            //goto end;
    //}
#if !defined(OPENSSL_NO_RSA) && !defined(OPENSSL_NO_DSA) && !defined (OPENSSL_NO_RC4)
    else if (format == FORMAT_MSBLOB)
        pkey = b2i_PrivateKey_bio(key);
    else if (format == FORMAT_PVK)
        pkey = b2i_PVK_bio(key, (pem_password_cb *)password_callback,
                &cb_data);
#endif
    else
    {
        BIO_printf(err,"bad input format specified for key file\n");
        goto end;
    }
end:
    if (key != NULL) BIO_free(key);
    if (pkey == NULL) 
    {
        BIO_printf(err,"unable to load %s\n", key_descrip);
        ERR_print_errors(err);
    }	
    return(pkey);
}

int password_callback(char *buf, int bufsiz, int verify,
	PW_CB_DATA *cb_tmp)
{
    UI *ui = NULL;
    int res = 0;
    const char *prompt_info = NULL;
    const char *password = NULL;
    PW_CB_DATA *cb_data = (PW_CB_DATA *)cb_tmp;

    if (cb_data)
    {
        if (cb_data->password)
            password = cb_data->password;
        if (cb_data->prompt_info)
            prompt_info = cb_data->prompt_info;
    }

    if (password)
    {
        res = strlen(password);
        if (res > bufsiz)
            res = bufsiz;
        memcpy(buf, password, res);
        return res;
    }

    ui = UI_new_method(ui_method);
    if (ui)
    {
        int ok = 0;
        char *buff = NULL;
        int ui_flags = 0;
        char *prompt = NULL;

        prompt = UI_construct_prompt(ui, "pass phrase",
                prompt_info);

        ui_flags |= UI_INPUT_FLAG_DEFAULT_PWD;
        UI_ctrl(ui, UI_CTRL_PRINT_ERRORS, 1, 0, 0);

        if (ok >= 0)
            ok = UI_add_input_string(ui,prompt,ui_flags,buf,
                    PW_MIN_LENGTH,BUFSIZ-1);
        if (ok >= 0 && verify)
        {
            buff = (char *)OPENSSL_malloc(bufsiz);
            ok = UI_add_verify_string(ui,prompt,ui_flags,buff,
                    PW_MIN_LENGTH,BUFSIZ-1, buf);
        }
        if (ok >= 0)
            do
            {
                ok = UI_process(ui);
            }
            while (ok < 0 && UI_ctrl(ui, UI_CTRL_IS_REDOABLE, 0, 0, 0));

        if (buff)
        {
            OPENSSL_cleanse(buff,(unsigned int)bufsiz);
            OPENSSL_free(buff);
        }

        if (ok >= 0)
            res = strlen(buf);
        if (ok == -1)
        {
            BIO_printf(bio_err, "User interface error\n");
            ERR_print_errors(bio_err);
            OPENSSL_cleanse(buf,(unsigned int)bufsiz);
            res = 0;
        }
        if (ok == -2)
        {
            BIO_printf(bio_err,"aborted!\n");
            OPENSSL_cleanse(buf,(unsigned int)bufsiz);
            res = 0;
        }
        UI_free(ui);
        OPENSSL_free(prompt);
    }
    return res;
}

static int load_pkcs12(BIO *err, BIO *in, const char *desc,
		pem_password_cb *pem_cb,  void *cb_data,
		EVP_PKEY **pkey, X509 **cert, STACK_OF(X509) **ca)
{
    const char *pass;
    char tpass[PEM_BUFSIZE];
    int len, ret = 0;
    PKCS12 *p12;
    p12 = d2i_PKCS12_bio(in, NULL);
    if (p12 == NULL)
    {
        BIO_printf(err, "Error loading PKCS12 file for %s\n", desc);	
        goto die;
    }
    /* See if an empty password will do */
    if (PKCS12_verify_mac(p12, "", 0) || PKCS12_verify_mac(p12, NULL, 0))
        pass = "";
    else
    {
        if (!pem_cb)
            pem_cb = (pem_password_cb *)password_callback;
        len = pem_cb(tpass, PEM_BUFSIZE, 0, cb_data);
        if (len < 0) 
        {
            BIO_printf(err, "Passpharse callback error for %s\n",
                    desc);
            goto die;
        }
        if (len < PEM_BUFSIZE)
            tpass[len] = 0;
        if (!PKCS12_verify_mac(p12, tpass, len))
        {
            BIO_printf(err,
                    "Mac verify error (wrong password?) in PKCS12 file for %s\n", desc);	
            goto die;
        }
        pass = tpass;
    }
    ret = PKCS12_parse(p12, pass, pkey, cert, ca);
die:
    if (p12)
        PKCS12_free(p12);
    return ret;
}

X509 *load_cert(BIO *err, const char *file, int format,
	const char *pass, ENGINE *e, const char *cert_descrip)
{
    X509 *x=NULL;
    BIO *cert;

    if ((cert=BIO_new(BIO_s_file())) == NULL)
    {
        ERR_print_errors(err);
        goto end;
    }

    if (file == NULL)
    {
#ifdef _IONBF
# ifndef OPENSSL_NO_SETVBUF_IONBF
        setvbuf(stdin, NULL, _IONBF, 0);
# endif /* ndef OPENSSL_NO_SETVBUF_IONBF */
#endif
        BIO_set_fp(cert,stdin,BIO_NOCLOSE);
    }
    else
    {
        if (BIO_read_filename(cert,file) <= 0)
        {
            BIO_printf(err, "Error opening %s %s\n",
                    cert_descrip, file);
            ERR_print_errors(err);
            goto end;
        }
    }

    if 	(format == FORMAT_ASN1)
        x=d2i_X509_bio(cert,NULL);
    else if (format == FORMAT_NETSCAPE)
    {
        NETSCAPE_X509 *nx;
        nx=ASN1_item_d2i_bio(ASN1_ITEM_rptr(NETSCAPE_X509),cert,NULL);
        if (nx == NULL)
            goto end;

        if ((strncmp(NETSCAPE_CERT_HDR,(char *)nx->header->data,
                        nx->header->length) != 0))
        {
            NETSCAPE_X509_free(nx);
            BIO_printf(err,"Error reading header on certificate\n");
            goto end;
        }
        x=nx->cert;
        nx->cert = NULL;
        NETSCAPE_X509_free(nx);
    }
    else if (format == FORMAT_PEM)
        x=PEM_read_bio_X509_AUX(cert,NULL,
                (pem_password_cb *)password_callback, NULL);
    else if (format == FORMAT_PKCS12)
    {
        if (!load_pkcs12(err, cert,cert_descrip, NULL, NULL,
                    NULL, &x, NULL))
            goto end;
    }
    else	{
        BIO_printf(err,"bad input format specified for %s\n",
                cert_descrip);
        goto end;
    }
end:
    if (x == NULL)
    {
        BIO_printf(err,"unable to load certificate\n");
        ERR_print_errors(err);
    }
    if (cert != NULL) BIO_free(cert);
    return(x);
}


/////////////////////////////////////////////////////////////
// Copied from apps/app_rand.c
/////////////////////////////////////////////////////////////
static int egdsocket = 0;
static int seeded = 0;
int app_RAND_load_file(const char *file, BIO *bio_e, int dont_warn)
{
    int consider_randfile = (file == NULL);
    char buffer[200];

#ifdef OPENSSL_SYS_WINDOWS
    BIO_printf(bio_e,"Loading 'screen' into random state -");
    BIO_flush(bio_e);
    RAND_screen();
    BIO_printf(bio_e," done\n");
#endif

    if (file == NULL)
        file = RAND_file_name(buffer, sizeof buffer);
    else if (RAND_egd(file) > 0)
    {
        /* we try if the given filename is an EGD socket.
           if it is, we don't write anything back to the file. */
        egdsocket = 1;
        return 1;
    }
    if (file == NULL || !RAND_load_file(file, -1))
    {
        if (RAND_status() == 0)
        {
            if (!dont_warn)
            {
                BIO_printf(bio_e,"unable to load 'random state'\n");
                BIO_printf(bio_e,"This means that the random number generator has not been seeded\n");
                BIO_printf(bio_e,"with much random data.\n");
                if (consider_randfile) /* explanation does not apply when a file is explicitly named */
                {
                    BIO_printf(bio_e,"Consider setting the RANDFILE environment variable to point at a file that\n");
                    BIO_printf(bio_e,"'random' data can be kept in (the file will be overwritten).\n");
                }
            }
            return 0;
        }
    }
    seeded = 1;
    return 1;
}

int bio_to_mem(unsigned char **out, int maxlen, BIO *in)
{
    BIO *mem;
    int len, ret;
    unsigned char tbuf[1024];
    mem = BIO_new(BIO_s_mem());
    if (!mem)
        return -1;
    for(;;)
    {
        if ((maxlen != -1) && maxlen < 1024)
            len = maxlen;
        else
            len = 1024;
        len = BIO_read(in, tbuf, len);
        if (len <= 0)
            break;
        if (BIO_write(mem, tbuf, len) != len)
        {
            BIO_free(mem);
            return -1;
        }
        maxlen -= len;
        
        if (maxlen == 0)
            break;
    }
    ret = BIO_get_mem_data(mem, (char **)out);
    BIO_set_flags(mem, BIO_FLAGS_MEM_RDONLY);
    BIO_free(mem);
    return ret;
}

