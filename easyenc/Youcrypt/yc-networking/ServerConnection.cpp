//
//  ServerConnection.cpp
//  Youcrypt
//
//  Created by avr on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include <string>
#include <utility>
#include <boost/network/protocol/http.hpp>
#include <boost/network/protocol/http/client.hpp>
#include <boost/network/uri.hpp>
#include <boost/assert.hpp>
#include "ServerConnection.h"
#include "UserAccount.h"
#include "Key.h"

#include "contrib/rapidjson/rapidjson.h"
#include "contrib/rapidjson/document.h"

namespace yc = youcrypt;
namespace bn = boost::network;
using std::string;

yc::ServerConnection::ServerConnection(string api_base_uri) :
_status(yc::ServerConnection::NotConnected),
_base_uri(api_base_uri),
_client(bn::http::_follow_redirects=true, bn::http::_cache_resolved=true, bn::http::_openssl_verify_path="/opt/local/share/curl/curl-ca-bundle.crt")
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
    
//    std::cout << find_by_email_uri.scheme() << " , " <<
//    find_by_email_uri.host() << ", " << find_by_email_uri.path() <<
//    ", " << find_by_email_uri.query() << std::endl;
    
    http_client::response resp = _client.get(req);
    
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
    return k;
}


yc::ServerConnection::OperationStatus
yc::ServerConnection::addPublicKey(yc::Key &key, yc::UserAccount &account)
{
    OperationStatus s = yc::ServerConnection::UnknownError;
    
    // Todo
    // 1. Get salt using a query such as "http://localhost:3000/users/findsalt.json?email=anirudhvr@gmail.com"
    // 2. bcrypt salt and password
    // 3. Post request to /keys/ with params hash as follows:
    // { "user" : { "email" : email,  "password" : password },
    //   "key" : { "key" : keyval , "privacy_level" : 0 }}
    
    return s;
    
}


yc::ServerConnection::OperationStatus
yc::ServerConnection::createNewAccount(yc::UserAccount &account)
{
    return yc::ServerConnection::UnknownError;
    
}
