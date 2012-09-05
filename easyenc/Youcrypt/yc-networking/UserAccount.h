//
//  UserAccount.h
//  Youcrypt
//
//  Created by avr on 7/29/12.
//
//

#ifndef __Youcrypt__UserAccount__
#define __Youcrypt__UserAccount__

#include <string>

using std::string;

namespace youcrypt {

class UserAccount
{
public:
    UserAccount(string email, string password);
    string getBcryptedPassword(string salt);
    
    string email() { return _email; }
    string password() { return _password; }
    
private:
    std::string _email;
    std::string _password;
    
};
    
}

#endif /* defined(__Youcrypt__UserAccount__) */
