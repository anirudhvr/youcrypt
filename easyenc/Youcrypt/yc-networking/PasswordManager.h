//
//  PasswordManager.h
//  Youcrypt
//
//  Created by avr on 7/29/12.
//
//

#ifndef __Youcrypt__PasswordManager__
#define __Youcrypt__PasswordManager__

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

#endif /* defined(__Youcrypt__PasswordManager__) */
