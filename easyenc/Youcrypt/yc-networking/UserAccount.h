//
//  UserAccount.h
//  Youcrypt
//
//  Created by avr on 7/29/12.
//
//

#ifndef __Youcrypt__UserAccount__
#define __Youcrypt__UserAccount__

#include <iostream>
#include "KeyManager.h"
#include "PasswordManager.h"
#include "HttpLib.h"

using std::string;
using std::vector;

namespace youcrypt {

class UserAccount
{
public:
    UserAccount(string email, string password);
    ~UserAccount();
    
    int authenticate();
    std::string getKey();
  
private:
    std::string _email;
    std::string _password;
    
};
    
};

#endif /* defined(__Youcrypt__UserAccount__) */
