//
//  PasswordManager.h
//  cppnetlib
//
//  Created by avr on 7/29/12.
//
//

#ifndef __cppnetlib__PasswordManager__
#define __cppnetlib__PasswordManager__

#include <iostream>

namespace youcrypt {

class PasswordManager
{
public:
    PasswordManager(std::string plaintextpassword);
    ~PasswordManager();

private:
    std::string salt;
    std::string password;
        
};
    
};

#endif /* defined(__cppnetlib__PasswordManager__) */
