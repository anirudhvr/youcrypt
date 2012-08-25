//
//  KeyManager.h
//  cppnetlib
//
//  Created by avr on 7/29/12.
//
//

#ifndef __cppnetlib__KeyManager__
#define __cppnetlib__KeyManager__

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
    
};

}
#endif /* defined(__cppnetlib__KeyManager__) */
