//
//  SharingManager.cpp
//  Youcrypt
//
//  Created by avr on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "ServerConnectionWrapper.h"
#include "ServerConnection.h"

youcrypt::ServerConnectionWrapper::
ServerConnectionWrapper(string api_base_url, string certs_bundle_path) :
_sc(new ServerConnection(api_base_url, certs_bundle_path))
{ }


youcrypt::Key
youcrypt::ServerConnectionWrapper::getPublicKey(youcrypt::UserAccount &account)
{
    return _sc->getPublicKey(account);
}

