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
    UserAccount(string email, string password, string name);
    
    string email() { return _email; }
    string name() { return _name; }
    
    string generateBcryptSalt(int log_rounds=10);
    string bcryptedPassword(string salt);
    
private:
    std::string _name;
    std::string _email;
    std::string _password;
    
};
    
}

#endif /* defined(__Youcrypt__UserAccount__) */
