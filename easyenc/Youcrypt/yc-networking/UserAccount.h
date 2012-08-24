//
//  UserAccount.h
//  cppnetlib
//
//  Created by avr on 7/29/12.
//
//

#ifndef __cppnetlib__UserAccount__
#define __cppnetlib__UserAccount__

#include <iostream>
#include "KeyManager.h"
#include "PasswordManager.h"
#include "HttpLib.h"

namespace youcrypt {

class UserAccount
{
public:
    UserAccount(std::string email, std::string password, std::string youcryptdir);
    ~UserAccount();
    
    int authenticate();
    std::string getKey();
  
private:
    std::string email;
    KeyManager keymgr;
    PasswordManager pwdmgr;
    std::string youcryptdir;
    
    
    
};
    
};

#endif /* defined(__cppnetlib__UserAccount__) */
