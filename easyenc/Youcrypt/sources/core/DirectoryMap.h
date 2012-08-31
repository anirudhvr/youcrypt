//
//  DirectoryMap.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/30/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__DirectoryMap__
#define __Youcrypt__DirectoryMap__

#include "YCFolder.h"
#include <map>
#include <string>
#include <boost/filesystem/fstream.hpp>

using std::map;
using std::string;
using boost::filesystem::ifstream;
using boost::filesystem::ofstream;
using namespace youcrypt;

typedef map<string, Folder> DirectoryMap;

ofstream& operator<< (ofstream &, const DirectoryMap &);
ifstream& operator>> (ifstream &, DirectoryMap &);

#endif /* defined(__Youcrypt__DirectoryMap__) */
