//
//  Key.h
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Youcrypt_Key_h
#define Youcrypt_Key_h
#include <string>

using std::string;

namespace youcrypt {
struct Key
{
    // Per-account key ID on the local machine and on the server
    int id;

    enum KeyType {
        Private = 0,
        Public,
        Other
    };
    KeyType type;

    enum KeyAlgType {
        RSA = 0,
        DSA,
        ECDSA
    };
    KeyAlgType algtype;

    // A name assigned to this key
    string name; 

    // Additional info for this key
    string description;

    Key();

    string value() { return _value; }
    bool setValue(string value) { _value = value; }
    bool setValueFromFile(string filename);
    bool writeValueToFile(string filename);

private:
    // The actual data for the key in ASCII
    string _value; 

};

};

#endif
