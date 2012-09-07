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
using boost::filesystem::path;
using boost::filesystem::ifstream;
using boost::filesystem::ofstream;
using namespace youcrypt;

namespace youcrypt {
    class DirectoryMap : public map<string, Folder> {
        friend ofstream& operator<< (ofstream &, const DirectoryMap &);
        friend ifstream& operator>> (ifstream &, DirectoryMap &);
        map<string, Folder> &getMap();
        map<string, Folder>::iterator getIterAtRow(int index);
    public:
        Folder operator[](int index);
        Folder &operator[](const string &str);
        void erase(int index);
        void erase(const string &);
        void archiveToFile(path file);
        static void unarchiveFromFile(path file);
};

DirectoryMap &getDirectories();
void setDirectories(const shared_ptr<DirectoryMap> &);
}


#endif /* defined(__Youcrypt__DirectoryMap__) */
