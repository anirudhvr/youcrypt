//
//  HttpLib.h
//  Youcrypt
//
//  Created by avr on 7/29/12.
//
//

#ifndef __Youcrypt__HttpLib__
#define __Youcrypt__HttpLib__

// Include whatever boost and cpp-netlib headers here

#include <boost/network/protocol/http/client.hpp>
#include <boost/network/uri.hpp>


const std::string APP_URL = "https://pacific-ridge-8141.herokuapp.com/";

namespace youcrypt {
    
class HttpClient
{
public:
    
    HttpClient(std::string url);
    HttpClient(const HttpClient &c);
    ~HttpClient();

    int get();
    std::string getResponse();
    
//    int add_header(std::string &name, std::string &value);
//    int post();
//    int put();
//    int del();
    
private:
    boost::network::http::client client_;
    boost::network::http::client::request request_;
    boost::network::http::client::response response_;
    
};
    
};

#endif /* defined(__Youcrypt__HttpLib__) */
