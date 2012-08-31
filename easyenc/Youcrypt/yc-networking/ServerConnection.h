//
//  ServerConnection.h
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__ServerConnection__
#define __Youcrypt__ServerConnection__

#include "ServerConnection.h"
#include "UserAccount.h"
#include "Key.h"

#include <boost/network/protocol/http/client.hpp>
#include <boost/network/uri.hpp>
#include <string>

using std::string;

namespace youcrypt {
class ServerConnection {
public:
    
    enum ConnectionStatus {
        NotConnected = 0,
        Connected,
    };
    
    enum OperationStatus {
        UnknownError = 0,
        CredentialsInvalid,
        AccountExists
    };
    
    ServerConnection(string server_api_url);
    
    // Gets key of provided account using search key (if it is public)
    Key getPublicKey(const UserAccount &account);
    
    // Create a new user account using supplied account credentials. Returns status
    OperationStatus createNewAccount(UserAccount &account);
    
    // Push new public key for supplied account to server
    bool addPublicKey(Key &key, UserAccount &account);
    
    ConnectionStatus status() { return _status; } 
    
private:
    string _url;
    ConnectionStatus _status;
    boost::network::http::client _client;
    
};

};

#endif /* defined(__Youcrypt__ServerConnection__) */
