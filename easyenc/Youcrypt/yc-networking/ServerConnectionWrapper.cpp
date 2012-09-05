//
//  SharingManager.cpp
//  Youcrypt
//
//  Created by avr on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "ServerConnectionWrapper.h"
#include "ServerConnection.h"

youcrypt::ServerConnectionWrapper::ServerConnectionWrapper(string api_base_url) :
_sc(new ServerConnection(api_base_url))
{ }


youcrypt::Key
youcrypt::ServerConnectionWrapper::getPublicKey(youcrypt::UserAccount &account)
{
    return _sc->getPublicKey(account);
}

