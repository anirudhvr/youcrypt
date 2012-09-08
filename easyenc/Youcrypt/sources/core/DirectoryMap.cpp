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
static shared_ptr<DirectoryMap> theDMap;

namespace youcrypt {
    
    DirectoryMap &getDirectories() {
        if (theDMap)
            return *theDMap;
        throw std::runtime_error("directories list unitialized");
    }
    
    void setDirectories(const shared_ptr<DirectoryMap> &cm)
    {
        theDMap = cm;
    }

    
    map<string, Folder> &DirectoryMap::getMap() {
        return *static_cast<map<string, Folder> *>(this);
    }
    map<string, Folder>::iterator DirectoryMap::getIterAtRow(int index) {
        if (index < 0 || index >= getMap().size())
            return getMap().end();
        else {
            auto beg = getMap().begin(), en = getMap().end();
            for (int i=0; i<index; ++i, ++beg);
            return beg;
        }
            
    }
    
    Folder DirectoryMap::operator[](int index) {
        auto beg = getIterAtRow(index);
        if (beg == getMap().end())
            return Folder();
        else {
            return beg->second;
        }
    }
    
    void DirectoryMap::erase(int index) {
        getMap().erase(getIterAtRow(index));
    }
    Folder &DirectoryMap::operator[](const string &str) {
        return  getMap()[str];
    }
    
    ofstream &operator<< (ofstream &ar, const DirectoryMap & d) {
        boost::archive::xml_oarchive xo(ar);
        xo & make_nvp("Directories", d);
    }
    
    ifstream &operator>> (ifstream &ar, DirectoryMap &d) {
        boost::archive::xml_iarchive xi(ar);
        xi & make_nvp("Directories", d);
    }

    void DirectoryMap::erase(const string &str) {
        getMap().erase(str);
    }

    void DirectoryMap::archiveToFile(path file) {
        boost::filesystem::ofstream ofile(file);
        if (ofile.is_open()) {
            ofile << (*this);
        }
    }
    
    void DirectoryMap::unarchiveFromFile(path file) {
        boost::shared_ptr<DirectoryMap> dirs(new DirectoryMap);
        boost::filesystem::ifstream ifile(file);
        if (ifile.is_open()) {
            ifile >> (*dirs);
            setDirectories(dirs);
        }
        else
            throw std::runtime_error("Unable to open directory list");
    }
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
