//
//  DirectoryMap.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "DirectoryMap.h"
#import "YoucryptDirectory.h"

using boost::filesystem::path;
using boost::filesystem::ofstream;
using boost::filesystem::ifstream;
using boost::archive::xml_oarchive;
using boost::archive::xml_iarchive;
using boost::serialization::make_nvp;
using std::string;
using std::map;


std::ostream &operator<< (std::ostream &st, const DirectoryMap &dirs) {
    xml_oarchive xmloutput(st);
    xmloutput << make_nvp("YCDirectories", dirs);
    return st;
}


std::istream &operator>> (std::istream &st, DirectoryMap &dirs) {
    xml_iarchive xmlinput(st);
    xmlinput >> make_nvp("YCDirectories", dirs);
    return st;
}

typedef std::map<std::string, boost::shared_ptr<cppObjcWrapper<YoucryptDirectory> > > DirectoryMap;


namespace boost{ namespace serialization {
    template<class A>
    void save(A &ar, const DirectoryMap &d, const unsigned int) {
        unsigned int sz = d.size();
        ar & make_nvp("count", sz);
        for (auto item: d) {
            if (item.second) {
                YoucryptDirectory *dir = item.second.get()->Object;
                if (dir != nil) {
                    [dir saveToArchive:ar];
                }
            }
        }
    }
    
    template<class A>
    void load(A &ar, DirectoryMap &d, const unsigned int) {
        unsigned int sz;
        ar & make_nvp("count", sz);
        for (int i=0; i<sz; i++) {
            YoucryptDirectory *dir = [[YoucryptDirectory alloc] initWithArchive:ar];
            string strPath([[dir path] cStringUsingEncoding:NSASCIIStringEncoding]);
            d[strPath].reset(new cppObjcWrapper<YoucryptDirectory>(dir));
        }
    }
    
    template<class A>
    void serialize(A &ar, DirectoryMap &d, const unsigned int fv) {
        split_free(ar, d, fv);
    }
}}



