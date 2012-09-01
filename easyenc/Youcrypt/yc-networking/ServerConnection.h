//
//  ServerConnection.h
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__ServerConnection__
#define __Youcrypt__ServerConnection__

#include <string>
#include <boost/network/protocol/http/client.hpp>
#include <boost/network/uri.hpp>
#include "Key.h"
#include "UserAccount.h"

using std::string;

namespace youcrypt {

class ServerConnection {
    public:
    
        typedef boost::network::http::basic_client<
        boost::network::http::tags::http_default_8bit_udp_resolve,
        1 ,1 > http_client;
    
        enum ConnectionStatus {
            NotConnected = 0,
            Connected,
            ConnectionError
        };

        enum OperationStatus {
            UnknownError = 0,
            CredentialsInvalid,
            AccountExists
        };

        ServerConnection(string api_base_uri);

        // Gets key of provided account using search key (if it is public)
        Key getPublicKey(UserAccount &account);

        // Create a new user account on server using supplied account credentials. Returns status
        OperationStatus createNewAccount(UserAccount &account);

        // Push new public key for supplied account to server
        OperationStatus addPublicKey(Key &key, UserAccount &account);

        ConnectionStatus status() { return _status; } 

    private:
        ConnectionStatus _status;
        boost::network::uri::uri _base_uri;
        http_client _client;

};

};

#endif /* defined(__Youcrypt__ServerConnection__) */
