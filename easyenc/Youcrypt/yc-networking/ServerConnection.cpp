//
//  ServerConnection.cpp
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "ServerConnection.h"
using namespace youcrypt;

namespace http = boost::network::http;

ServerConnection::ServerConnection(string server_api_url)
: _url(server_api_url), _status(ServerConnection::NotConnected)
{
    
}

Key
ServerConnection::getPublicKey(const UserAccount &account)
{
    return Key();
}