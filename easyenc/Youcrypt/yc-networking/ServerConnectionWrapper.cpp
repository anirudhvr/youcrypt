//
//  SharingManager.cpp
//  Youcrypt
//
//  Created by avr on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "ServerConnectionWrapper.h"
#include "ServerConnection.h"

using namespace youcrypt;

ServerConnectionWrapper::ServerConnectionWrapper(string api_base_url, string certs_bundle_path) :
_sc(new ServerConnection(api_base_url, certs_bundle_path))
{ }


Key
ServerConnectionWrapper::getPublicKey(UserAccount &account)
{
    return _sc->getPublicKey(account);
}


ServerConnectionWrapper::OperationStatus
ServerConnectionWrapper::createNewAccount(UserAccount &account)
{
    return (ServerConnectionWrapper::OperationStatus)_sc->createNewAccount(account);
}


ServerConnectionWrapper::OperationStatus
ServerConnectionWrapper::addPublicKey(Key &key, UserAccount &account)
{
    return (ServerConnectionWrapper::OperationStatus)_sc->addPublicKey(key, account);
}

ServerConnectionWrapper::OperationStatus
ServerConnectionWrapper::addFolderInfo(FolderInfo &fi, UserAccount &ua)
{
    return (ServerConnectionWrapper::OperationStatus)_sc->addFolderInfo(fi, ua);
}

int
ServerConnectionWrapper::getFolderSharingStatus(FolderInfo &fi, UserAccount &ua)
{
    return _sc->getFolderSharingStatus(fi, ua);
}