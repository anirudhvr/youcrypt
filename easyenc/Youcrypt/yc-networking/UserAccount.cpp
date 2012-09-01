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
_email(e), _password(p)
{
}

string
UserAccount::getBcryptedPassword(string salt)
{
    char *output = bcrypt_hashpw((char*)salt.c_str(), (char*)_password.c_str());
    return output ? string(output) : string();
}


