//
//  Key.h
//  cppnetlib
//
//  Created by Hardik Ruparel on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef cppnetlib_Key_h
#define cppnetlib_Key_h

struct Key
{
    int id;
    std::string name;
    std::string description;
    enum {
        PRIV,
        FRIENDS,
        PUB
    } privacy_level;
};


#endif
