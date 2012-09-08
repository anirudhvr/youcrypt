#include "Key.h"

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
//#include <boost/algorithm/string.hpp>
//using namespace boost::algorithm;

using namespace std;
using namespace youcrypt;

Key::Key()
{
    // FIXME - change this with a bette constructor
    type = Key::Public;
    algtype = Key::RSA;
    name = "";
    description = "";
    empty = true;
}

Key::Key(string val) : _value(val)
{
    type = Key::Public;
    algtype = Key::RSA;
    name = "";
    description = "";
    if (val.length() > 0)
        empty = false;
}
    
bool
Key::setValueFromFile(string filename)
{
    bool ret = false;
    ifstream in;
    in.exceptions(ifstream::failbit | ifstream::badbit);
    try {
        in.open(filename.c_str(), ios::in);
        if (in.is_open()) {
            string line;
            stringstream ss;
            while (in.good()) {
                getline(in, line);
                //trim(line);
                ss << line;
            }
            string output = ss.str(); 
            if (output.length() > 0) 
                _value = output;
            in.close();
            ret = true;
        }
    } catch (ifstream::failure e) {
        std::cerr << "Key::setValueFromFile failed: " << e.what() << std::endl;
    }
    empty = false;
    return ret;
}

bool
Key::writeValueToFile(string filename)
{
    bool ret = false;
    ofstream out;
    out.exceptions(ofstream::failbit | ofstream::badbit);
    try {
        out.open(filename.c_str(), ios::out);
        if (out.is_open()) {
            out << _value;
            out.close();
            ret = true;
        }
    } catch (ofstream::failure e) {
        std::cerr << "Key::writeValueToFile failed: " << e.what() << std::endl;
    }
    return ret;
}
