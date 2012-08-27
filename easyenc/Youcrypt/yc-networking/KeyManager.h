//
//  KeyManager.h
//  Youcrypt
//
//  Created by avr on 7/29/12.
//
//

#ifndef __Youcrypt__KeyManager__
#define __Youcrypt__KeyManager__

#include <iostream>
#include "Key.h"

namespace youcrypt {

class KeyManager
{
public:
    KeyManager();
    ~KeyManager();
    Key getKey();
    
private:
    Key key;
    
    // map<pair<id,Credential> > keys
    
};

}
#endif /* defined(__Youcrypt__KeyManager__) */
