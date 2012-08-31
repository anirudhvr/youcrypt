//
//  DirectoryMap.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "DirectoryMap.h"
#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>

using boost::serialization::make_nvp;
ofstream &operator<< (ofstream &ar, const DirectoryMap & d) {
    boost::archive::xml_oarchive xo(ar);
    xo & make_nvp("Directories", d);
}

ifstream &operator>> (ifstream &ar, DirectoryMap &d) {
    boost::archive::xml_iarchive xi(ar);
    xi & make_nvp("Directories", d);
}

BOOST_SERIALIZATION_SPLIT_FREE(DirectoryMap)

namespace boost{namespace serialization{

    template<class A>
    void load(A &ar, DirectoryMap &d, const unsigned int) {
        unsigned int count;
        ar & make_nvp("count", count);
        Folder f;
        for (int i=0; i<count; i++) {
            ar & make_nvp("Folder", f);
            d[f->rootPath()] = f;
        }
    }
    
    template<class A>
    void save(A &ar, const DirectoryMap &d, const unsigned int) {
        unsigned int count;
        count = d.size();
        ar & make_nvp("count", count);
        for (auto el: d) {
            ar & make_nvp("Folder", el.second);
        }
    }

    
}}
