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
    
//    std::cout << find_by_email_uri.scheme() << " , " <<
//    find_by_email_uri.host() << ", " << find_by_email_uri.path() <<
//    ", " << find_by_email_uri.query() << std::endl;
    
    try {
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
        
    } catch (std::exception &ex) {
        std::cerr << "Server Error searching for email " << e << ":" <<
        ex.what() << std::endl;
    }
    return k;
}

yc::ServerConnection::OperationStatus
yc::ServerConnection::createNewAccount(yc::UserAccount &account)
{
    const char *prm = "user[name]=Anirudh5&user[email]=avr2@nouvou.com&"
    "user[password]=$2a$10$kUqAoBJGnff1B/GxP8jjUueqEgE2ElE9/yLTtptnOIKKzVb15YZcK&"
    "user[password_confirmation]=$2a$10$kUqAoBJGnff1B/GxP8jjUueqEgE2ElE9/yLTtptnOIKKzVb15YZcK&"
    "user[salt]=$2a$10$kUqAoBJGnff1B/GxP8jjUu";
    
//    const char *prm = "user%5Bname%5D%3DAnirudh5%26user%5Bemail%5D%3Davr%40nouvou.com%26user%5Bpassword%5D%3D%242a%2410%24kUqAoBJGnff1B/GxP8jjUueqEgE2ElE9/yLTtptnOIKKzVb15YZcK%26user%5Bpassword_confirmation%5D%3D%242a%2410%24kUqAoBJGnff1B/GxP8jjUueqEgE2ElE9/yLTtptnOIKKzVb15YZcK%26user%5Bsalt%5D%3D%242a%2410%24kUqAoBJGnff1B/GxP8jjUu";
    
//    const char *prm = "user%5Bname%5D=Anirudhcpp1&user%5Bemail%5D=avr3%40gmail.com&user%5Bpassword%5D=%242a"
//    "%2410%24HXkULmR0LZkFiww9LChZNOR7Y%2F%2FVvRoySEoANHuY9w7PNF6UJmQK6&user%5Bpassword_confirmation%5D=%242a"
//    "%2410%24HXkULmR0LZkFiww9LChZNOR7Y%2F%2FVvRoySEoANHuY9w7PNF6UJmQK6&user%5Bsalt%5D=%242a%2410%24HXkULmR0LZkFiww9LChZNO";
    
    string params(prm);
    char paramlen[10];
    sprintf(paramlen, "%u", params.length());
    
    bn::uri::uri create_user_uri(_base_uri);
    create_user_uri << bn::uri::path("users/") << bn::uri::query(yc::encoded(params));
    http_client::request req(create_user_uri);
//    req << bn::header("Content-Type", "application/json");
//    req << bn::header("Content-Type", "x-www-form-urlencoded");
//    req << bn::header("Content-Length", paramlen);
//    req << bn::body(params);
    
    try {
        http_client::response resp = _client.get(req);
    } catch (std::exception &ex) {
        std::cerr << "Server error creating user" << ex.what() << std::endl;
    }
    
    return yc::ServerConnection::UnknownError;
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

