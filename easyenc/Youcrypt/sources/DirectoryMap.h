//
//  DirectoryMap.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/29/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__DirectoryMap__
#define __Youcrypt__DirectoryMap__

#include <iostream>
#include <string>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/shared_ptr.hpp>
#include <map>

@class YoucryptDirectory;

template<typename T>
class cppObjcWrapper
{
public:
    T *Object;
    
    cppObjcWrapper(): Object(nil) {}
    cppObjcWrapper(T *object): Object(object) {}
    cppObjcWrapper(cppObjcWrapper& other): Object(other.Object) {}
    ~cppObjcWrapper() { Object = nil; }
public:
};

typedef std::map<std::string, boost::shared_ptr<cppObjcWrapper<YoucryptDirectory> > > DirectoryMap;

std::ostream &operator<< (std::ostream &st, const DirectoryMap &dirs);
std::istream &operator>> (std::istream &st, DirectoryMap &dirs);




#endif /* defined(__Youcrypt__DirectoryMap__) */
