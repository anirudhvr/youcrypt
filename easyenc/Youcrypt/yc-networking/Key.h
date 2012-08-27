//
//  Key.h
//  Youcrypt
//
//  Created by Hardik Ruparel on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Youcrypt_Key_h
#define Youcrypt_Key_h
using std::string;

struct Key
{
    int id;
    int type;
    
    string name;
    string description;
    
    int unlock_privatekey();
    
    enum {
        PRIV = 0,
        FRIENDS,
        PUB
    } privacy_level;
    
private:
    string privkeyfile;
    string pubkeyfile;
};


#endif
