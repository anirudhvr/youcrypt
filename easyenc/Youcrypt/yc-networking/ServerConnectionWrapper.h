//
//  ServerConnectionWrapper.h
//  Youcrypt
//
//  Created by avr on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

// XXX FIXME this is a dumb wrapper for ServerConnection because I can't
// seem to include ServerConnection.h in an objective C++ file without compile errors

#ifndef __Youcrypt__SharingManager__
#define __Youcrypt__SharingManager__

#include <iostream>
#include <string>
#include <boost/shared_ptr.hpp>
#include "UserAccount.h"
#include "Key.h"

namespace youcrypt {
    
class ServerConnection;

class ServerConnectionWrapper {
private:
    boost::shared_ptr<ServerConnection> _sc;
    
public:
    ServerConnectionWrapper(std::string server_api_base_url);
    
    // Gets key of provided account using search key (if it is public) from sc
    Key getPublicKey(UserAccount &account);
    
};
}

#endif /* defined(__Youcrypt__SharingManager__) */
