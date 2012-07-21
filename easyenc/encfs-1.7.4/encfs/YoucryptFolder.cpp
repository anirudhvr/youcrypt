/************************************************************
 * Author: Rajsekar Manokaran (for Nouvou)
 ************************************************************
 * Copyright (c) 2012
 */

#include "YoucryptFolder.h"

#include <boost/filesystem.hpp>

using boost::filesystem::path;

using youcrypt::YoucryptFolder;

//! Some more documentation.
YoucryptFolder::YoucryptFolder(const path &_rootPath, Credentials *authCred) {
}

//! Import content at the path specified into the folder (<blah> goes to /<blah> in the folder).
bool YoucryptFolder::importContent(const path&) {}

//! Import content at the path specified into the folder at the path specified.
bool YoucryptFolder::importContent(const path&, const path&) {}

//! Same as import, except not!
bool exportContent(const path&, const path&) {}
