//
//  ServerConnection.cpp
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include <string>
#include <sstream>
#include <cstring>
#include <utility>
#include <boost/network/protocol/http.hpp>
#include <boost/network/protocol/http/client.hpp>
#include <boost/network/uri.hpp>
#include <boost/assert.hpp>
#include <boost/exception/exception.hpp>
#include "ServerConnection.h"
#include "UserAccount.h"
#include "Key.h"
#include "constants.h"
#include "ycencode.hpp"

#include "contrib/rapidjson/rapidjson.h"
#include "contrib/rapidjson/document.h"

#include "contrib/bcrypt/bcrypt_wrapper.h"

namespace yc = youcrypt;
namespace bn = boost::network;
using std::string;
using std::stringstream;

yc::ServerConnection::ServerConnection(string api_base_uri, string certs_bundle_path) :
_status(yc::ServerConnection::NotConnected),
_base_uri(api_base_uri),
_client(bn::http::_follow_redirects=true,
        bn::http::_cache_resolved=true,
        bn::http::_openssl_certificate=certs_bundle_path) // FIXME
{}

yc::Key
yc::ServerConnection::getPublicKey(yc::UserAccount &account)
{
    using namespace rapidjson;
    
    Key k;
    
    string params("email="), e = account.email();
    params += e;
    
    bn::uri::uri find_by_email_uri(_base_uri);
    find_by_email_uri << bn::uri::path("users/findbyemail/") << bn::uri::query(params);
    http_client::request req(find_by_email_uri);
    req << bn::header("User-Agent", string(YC_USER_AGENT));
    
//    std::cout << find_by_email_uri.scheme() << " , " <<
//    find_by_email_uri.host() << ", " << find_by_email_uri.path() <<
//    ", " << find_by_email_uri.query() << std::endl;
    
    try {
        http_client::response resp = _client.get(req);
        
        if (resp.status() == 200) {
            Document d;
            const char *tmp = resp.body().c_str();
            if (!d.Parse<0>(tmp).HasParseError()) {
                const Value &r = d["response"];
                string s = r.GetString();
                if (s == "OK") {
                    const Value &keys = d["keys"];
                    if (keys.IsArray()) {
                        SizeType j = 0;
                        k.setValue(keys[j]["key"].GetString());
                    } else {
                        k.setValue(keys["key"].GetString());
                    }
                    k.id = 0;
                    k.name = k.description = e;
                }
            }
        }
    } catch (std::exception &ex) {
        std::cerr << "Server Error searching for email " << e << ":" <<
        ex.what() << std::endl;
    }
    return k;
}

yc::ServerConnection::OperationStatus
yc::ServerConnection::createNewAccount(yc::UserAccount &account)
{
    OperationStatus stat = yc::ServerConnection::UnknownError;
    string salt = account.generateBcryptSalt();
    string bcrypted_pw = account.bcryptedPassword(salt);
    
    stringstream ss;
    ss << "user[name]=" << account.name() << "&" <<
    "user[email]=" << account.email() << "&" <<
    "user[password]=" << bcrypted_pw << "&" <<
    "user[password_confirmation]=" << bcrypted_pw << "&" <<
    "user[salt]=" << salt;
    
    string params = ss.str();
    char paramlen[10];
    sprintf(paramlen, "%u", params.length());
    
    bn::uri::uri create_user_uri(_base_uri);
    create_user_uri << bn::uri::path("users/") << bn::uri::query(yc::encoded(params));
    http_client::request req(create_user_uri);
    req << bn::header("User-Agent", string(YC_USER_AGENT));
    //    req << bn::header("Content-Type", "application/json");
//    req << bn::header("Content-Type", "x-www-form-urlencoded");
//    req << bn::header("Content-Length", paramlen);
//    req << bn::body(params);
    
    try {
        http_client::response resp = _client.get(req);
        if (resp.status() == 200u) {
            stat = yc::ServerConnection::Success;
        } else if (resp.status() == 500) {
            stat = yc::ServerConnection::Success;
            std::cerr << "Server returned 500 but things may have worked" << std::endl;
        } else if (resp.status() == 400u) {
            stat = yc::ServerConnection::AccountExists;
        }
//        std::cout << resp.status_message() << "," << resp.status() << "\n" <<resp.body() << std::endl;
    } catch (std::exception &ex) {
        std::cerr << "Server error creating user" << ex.what() << std::endl;
    }
    
    return stat;
}

yc::ServerConnection::OperationStatus
yc::ServerConnection::addPublicKey(yc::Key &key, yc::UserAccount &account)
{
    OperationStatus stat = yc::ServerConnection::UnknownError;
    string salt, bcrypted_pw;
    
    // Todo
    // 1. Get salt from server
    salt = retrieveSalt(account);
    if (salt.length() <= 0)
        return yc::ServerConnection::CredentialsInvalid;
    
    bcrypted_pw = account.bcryptedPassword(salt);
    if (bcrypted_pw.length() <= 0)
        return yc::ServerConnection::CredentialsInvalid;
    
    // 2. Construct query to post key to server (currently as a public key)
    
    stringstream ss;
    ss << "user[email]=" << account.email() << "&" <<
    "user[password]=" << bcrypted_pw << "&" <<
    "key[key]=" << key.value() << "&" <<
    "key[privacy_level]=" << key.type << "&";
    
    string params = ss.str();
    char paramlen[10];
    sprintf(paramlen, "%u", params.length());
    
    bn::uri::uri add_key_uri(_base_uri);
    add_key_uri << bn::uri::path("keys/") << bn::uri::query(yc::encoded(params));
    http_client::request req(add_key_uri);
    req << bn::header("User-Agent", string(YC_USER_AGENT));
    
    try {
        http_client::response resp = _client.get(req);
        if (resp.status() == 200u) {
            stat = yc::ServerConnection::Success;
        } else {
            stat = yc::ServerConnection::CredentialsInvalid;
        }
    } catch (std::exception &ex) {
        std::cerr << "Server Error searching for email " << ex.what() << ":" <<
        ex.what() << std::endl;
    }
    
    return stat;
    
}

string
yc::ServerConnection::retrieveSalt(yc::UserAccount &account)
{
    using namespace rapidjson;
    OperationStatus stat = yc::ServerConnection::UnknownError;
    string params("email="), e = account.email(), salt;
    params += e;
    
    bn::uri::uri find_salt_uri(_base_uri);
    find_salt_uri << bn::uri::path("users/findsalt/") << bn::uri::query(params);
    http_client::request req(find_salt_uri);
    req << bn::header("User-Agent", string(YC_USER_AGENT));
    
    try {
        http_client::response resp = _client.get(req);
        
        if (resp.status() == 200u) {
            Document d;
            const char *tmp = resp.body().c_str();
            if (!d.Parse<0>(tmp).HasParseError()) {
                const Value &slt = d["salt"];
                salt = slt.GetString();
                stat = yc::ServerConnection::Success;
            }
        } else {
            stat = yc::ServerConnection::CredentialsInvalid;
        }
    } catch (std::exception &ex) {
        std::cerr << "Server Error searching for email " << e << ":" <<
        ex.what() << std::endl;
    }
    return salt;
}

// XXX TODO
yc::ServerConnection::OperationStatus
yc::ServerConnection::addFolderInfo(yc::FolderInfo &folderInfo,
                                    yc::UserAccount &account)
{
    OperationStatus stat = yc::ServerConnection::UnknownError;
    string salt, bcrypted_pw;
    
    // Todo
    // 1. Get salt from server
    salt = retrieveSalt(account);
    if (salt.length() <= 0)
        return yc::ServerConnection::CredentialsInvalid;
    
    bcrypted_pw = account.bcryptedPassword(salt);
    if (bcrypted_pw.length() <= 0)
        return yc::ServerConnection::CredentialsInvalid;
    
    // 2. Construct query to post key to server (currently as a public key)
    
    stringstream ss;
    ss << "user[email]=" << account.email() << "&" <<
    "user[password]=" << bcrypted_pw << "&" <<
    "folder[uuid]=" << folderInfo.uuid << "&" <<
    "folder[sharing_status]=" << folderInfo.sharing_status << "&";
    
    string params = ss.str();
    char paramlen[10];
    sprintf(paramlen, "%u", params.length());
    
    bn::uri::uri add_folderinfo_uri(_base_uri);
    add_folderinfo_uri << bn::uri::path("folders/") << bn::uri::query(yc::encoded(params));
    http_client::request req(add_folderinfo_uri);
    req << bn::header("User-Agent", string(YC_USER_AGENT));
    
    try {
        http_client::response resp = _client.get(req);
        if (resp.status() == 200u) {
            stat = yc::ServerConnection::Success;
        } else {
            stat = yc::ServerConnection::CredentialsInvalid;
        }
    } catch (std::exception &ex) {
        std::cerr << "Server Error searching for email " << ex.what() << ":" <<
        ex.what() << std::endl;
    }
    
    return stat;
    
}


// XXX TODO
int
yc::ServerConnection::getFolderSharingStatus(yc::FolderInfo &folderToCheck,
                                             yc::UserAccount &account)
{
    using namespace rapidjson;
    
    string params("email="), e = account.email();
    params += e;
    
    bn::uri::uri find_by_email_uri(_base_uri);
    find_by_email_uri << bn::uri::path("users/findbyemail/") << bn::uri::query(params);
    http_client::request req(find_by_email_uri);
    req << bn::header("User-Agent", string(YC_USER_AGENT));
    
//    std::cout << find_by_email_uri.scheme() << " , " <<
//    find_by_email_uri.host() << ", " << find_by_email_uri.path() <<
//    ", " << find_by_email_uri.query() << std::endl;
    
    try {
        http_client::response resp = _client.get(req);
        
        if (resp.status() == 200) {
            Document d;
            const char *tmp = resp.body().c_str();
            std::cerr << "Got response:[" << tmp << "]" << std::endl;
            if (!d.Parse<0>(tmp).HasParseError()) {
                const Value &r = d["response"];
                string s = r.GetString();
                if (s == "OK") {
                    const Value &folders = d["folders"];
                    
                    if (folders.IsArray()) {
                        for (SizeType j = 0; j < folders.Size(); ++j) {
                            const Value &f = folders[j];
                            if (folderToCheck.uuid == f["uuid"].GetString()) {
                                return f["sharing_status"].GetInt();
                            }
                        }
                    } else {
                        if (folders["uuid"].IsString()  &&
                            (folderToCheck.uuid ==
                             folders["uuid"].GetString()) )  {
                            return folders["sharing_status"].GetInt();
                        }
                        
                    }
                }
            }
        }
    } catch (std::exception &ex) {
        std::cerr << "Server Error searching for email " << e << ":" <<
        ex.what() << std::endl;
    }
    
    return -1;
}
