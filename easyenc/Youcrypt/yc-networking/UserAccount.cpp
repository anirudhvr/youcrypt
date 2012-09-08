//
//  UserAccount.cpp
//  cppnetlib
//
//  Created by avr on 7/29/12.
//
//

#include "UserAccount.h"
#include "contrib/bcrypt/bcrypt_wrapper.h"

using namespace youcrypt;

UserAccount::UserAccount(std::string e, std::string p) :
_email(e), _password(p), _name("")
{
}

UserAccount::UserAccount(std::string e, std::string p, std::string name) :
_email(e), _password(p), _name(name)
{
}


string
UserAccount::generateBcryptSalt(int log_rounds)
{
    return string(gensalt(log_rounds));
}

string
UserAccount::bcryptedPassword(string salt)
{
    char *output = bcrypt_hashpw((char*)_password.c_str(), (char*)salt.c_str());
    return output ? string(output) : string();
}
