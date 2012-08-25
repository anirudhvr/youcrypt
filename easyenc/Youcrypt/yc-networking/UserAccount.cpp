//
//  UserAccount.cpp
//  cppnetlib
//
//  Created by avr on 7/29/12.
//
//

#include "UserAccount.h"

using namespace youcrypt;

UserAccount::UserAccount(std::string e, std::string password, std::string ydir) : 
email(e),  youcryptdir(ydir) , pwdmgr(PasswordManager(password))
{
    
    
}

UserAccount::~UserAccount()
{
    
}

std::string UserAccount::getKey()
{
    std::string url = APP_URL+"/keys/5.json";
    try {
        HttpClient client(url);
        client.get();
        std::string response = client.getResponse();
        return response;
    } catch (std::exception &e) {
        std::cerr << e.what() << std::endl;
        return "ERROR";
    }
}


