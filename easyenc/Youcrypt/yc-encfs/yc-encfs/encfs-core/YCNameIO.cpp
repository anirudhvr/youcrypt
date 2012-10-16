/*****************************************************************************
 * Author:   Valient Gough <vgough@pobox.com>
 *           Anirudh Ramachandran (for Nouvou/Youcrypt)
 *
 *****************************************************************************
 * Copyright (c) 2004, Valient Gough
 *
 * This library is free software; you can distribute it and/or modify it under
 * the terms of the GNU General Public License (GPL), as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GPL in the file COPYING for more
 * details.
 */

#include "YCNameIO.h"

#include "Cipher.h"
#include "base64.h"

#include <cstring>
#include <rlog/rlog.h>
#include <rlog/Error.h>
#include <rlog/RLogChannel.h>

#include "i18n.h"

using namespace rlog;
using namespace rel;
using namespace boost;

static RLogChannel * Info = DEF_CHANNEL( "info/nameio", Log_Info );


static shared_ptr<NameIO> NewYCNameIO(const Interface &,
				      const shared_ptr<Cipher> &, 
				      const CipherKey&)
{

    return shared_ptr<NameIO>( new YCNameIO());
}

static Interface YCNameIOIface ("nameio/youcrypt", 1, 0, 0);

static bool YCNameIO_registered = NameIO::Register("Youcrypt",
	// description of block name encoding algorithm..
	// xgroup(setup)
	gettext_noop("Youcrypt the filename: just adds .yc at the end"), 	
	YCNameIOIface,
	NewYCNameIO);

Interface YCNameIO::CurrentInterface()
{
    // implement major version 3 and 2
    return YCNameIOIface;
}

Interface YCNameIO::interface() const
{
    return YCNameIOIface;
}

YCNameIO::YCNameIO()
{
}

YCNameIO::~YCNameIO()
{
}

int YCNameIO::maxEncodedNameLen( int plaintextNameLen ) const
{
    return plaintextNameLen + 5;
}

int YCNameIO::maxDecodedNameLen( int encodedNameLen ) const
{
    return encodedNameLen + 5; // Yea, why not.
}

int YCNameIO::encodeName( const char *plaintextName, int length,
	uint64_t *iv, char *encodedName ) const
{
    memcpy (encodedName, plaintextName, length);
    encodedName += length;
    memcpy (encodedName, ".yc", 3);
    length += 3;
    return length;
}

int YCNameIO::decodeName( const char *encodedName, int length,
	uint64_t *iv, char *plaintextName ) const
{
    memcpy ( plaintextName, encodedName, length - 3);
    return length - 3;
}

bool YCNameIO::Enabled()
{
    return true;
}

