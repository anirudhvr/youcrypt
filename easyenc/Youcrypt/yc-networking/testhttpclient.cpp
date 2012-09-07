//
//  testhttpclient.cpp
//  Youcrypt
//
//  Created by avr on 8/23/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "testhttpclient.h"
#include <string>
#include <fstream>
#include <iostream>
//#include "HttpLib.h"
#include "UserAccount.h"
//#include "KeyManager.h"
//#include "PasswordManager.h"
#include "Key.h"
#include "ServerConnection.h"

using namespace youcrypt;

//#define APP_URL "https://pacific-ridge-8141.herokuapp.com/"
#define APP_URL "http://localhost:3000/"

void
testjson()
{
    ServerConnection s(APP_URL, "/opt/local/share/curl/curl-ca-bundle.crt");
    UserAccount ua("hardik988@gmail.com", "Nouvou1");
    Key k = s.getPublicKey(ua);
    std::cout << k.value() << std::endl;
}

void
testcreateuser()
{
    ServerConnection s(APP_URL, "/opt/local/share/curl/curl-ca-bundle.crt");
    UserAccount ua("hardik988@gmail.com", "Nouvou1");
    s.createNewAccount(ua);
}

//int
//testServer(void) {
//    
//    std::string url(APP_URL);
//    url += "/keys/5.json";
//    UserAccount user("hardik988@gmail.com","Nouvou1");
//    try {
//        youcrypt::HttpClient client(url);
//        client.get();
//        std::string response = client.getResponse();
//        std::cout << "Response: "<<response<< std::endl;
//    }
//    catch (std::exception &e) {
//        std::cerr << e.what() << std::endl;
//        return 1;
//    }
//    std::cout<<user.getKey();
//    return 0;
//}



//          Copyright Dean Michael Berris 2008.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

//[ http_client_main
/*`
  This application takes a URL as a command line argument and prints
  the resource to the console.
*/
#include <boost/program_options.hpp>
#include <boost/network/protocol/http.hpp>
#include <string>
#include <utility>
#include <iostream>

namespace po = boost::program_options;

int test(void) {
    using namespace boost::network;
    po::options_description options("Allowed options");
    std::string output_filename, source;
    bool show_headers;
    options.add_options()
        ("help,h", "produce help message")
        ("headers,H", "print headers")
        ("source,s", po::value<std::string>(&source), "source URL")
        ;

    po::positional_options_description positional_options;
    positional_options.add("source", 1);
    po::variables_map vm;

    show_headers = vm.count("headers") ? true : false ;

    
    source = "https://www.google.com";
    
    typedef http::basic_client<http::tags::http_async_8bit_tcp_resolve, 1, 0>
        http_client;

    http_client::request request(source);
    http_client::string_type destination_ = host(request);

    request << ::boost::network::header("Connection", "close");
    http_client client(http::_follow_redirects=true);
    http_client::response response = client.get(request);

    if (show_headers) {
        headers_range<http_client::response>::type headers_ = response.headers();
        typedef std::pair<std::string, std::string> header_type;
        BOOST_FOREACH(header_type const & header, headers_) {
          std::cout << header.first << ": " << header.second << std::endl;
        }
        std::cout << std::endl;
    };

    body_range<http_client::response>::type body_ = body(response).range();
    boost::copy(body_, std::ostream_iterator<char_<http_client::request::tag>::type>(std::cout));
    return EXIT_SUCCESS;
}
