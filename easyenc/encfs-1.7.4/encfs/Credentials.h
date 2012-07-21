/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#ifndef _Youcrypt_Credentials_incl_
#define _Youcrypt_Credentials_incl_

using std::string;

namespace youcrypt {

    class Credentials {
    public:
        string decryptVolumeKey(string) = 0;
    };

}

#endif

