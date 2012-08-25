//
//  HttpLib.cpp
//  cppnetlib
//
//  Created by avr on 7/29/12.
//
//

#include "HttpLib.h"
using namespace youcrypt;

HttpClient::HttpClient(std::string url) : request_(url)
{
    
}


HttpClient::HttpClient(const HttpClient &c) : client_(c.client_), request_(c.request_)
{
    client_ = c.client_;
    request_ = c.request_;
}

HttpClient::~HttpClient()
{

}

int HttpClient::get()
{
    response_ = client_.get(request_);
    return 0;
}

std::string HttpClient::getResponse()
{
    return static_cast<std::string>(body(response_));
}