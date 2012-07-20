#ifndef _YCNameIO_incl_
#define _YCNameIO_incl_

#include "NameIO.h"


class YCNameIO : public NameIO
{
public:
    static rel::Interface CurrentInterface();

    YCNameIO();
    virtual ~YCNameIO();

    virtual rel::Interface interface() const;

    virtual int maxEncodedNameLen( int plaintextNameLen ) const;
    virtual int maxDecodedNameLen( int encodedNameLen ) const;

    // hack to help with static builds
    static bool Enabled();
protected:
    virtual int encodeName( const char *plaintextName, int length,
	                    uint64_t *iv, char *encodedName ) const;
    virtual int decodeName( const char *encodedName, int length,
	                    uint64_t *iv, char *plaintextName ) const;

private:
};

#endif
