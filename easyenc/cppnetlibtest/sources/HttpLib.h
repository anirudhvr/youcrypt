//
//  HttpLib.h
//  cppnetlib
//
//  Created by avr on 7/29/12.
//
//

#ifndef __cppnetlib__HttpLib__
#define __cppnetlib__HttpLib__


#include <iostream>

// Include whatever boost and cpp-netlib headers here


class HttpClient
{
public:
    
    HttpClient(std::string &url);
    HttpClient(const HttpClient &c);
    ~HttpClient();

    int add_header(std::string &name, std::string &value);
    int get();
    int post();
    int put();
    int del();
    
private:
//    http::client client_;
//    http::client::request request_;
    
};

#endif /* defined(__cppnetlib__HttpLib__) */
