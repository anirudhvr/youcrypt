//
//  main.cpp
//  yc-encfs
//
//  Created by Rajsekar Manokaran on 8/25/12.
//  Copyright (c) 2012 avr. All rights reserved.
//

#include "main.h"
#include "YoucryptFolder.h"
#include "PassphraseCredentials.h"
#include <iostream>

using namespace std;
using namespace youcrypt;

int testMount (string encRoot, string mntPoint)
{
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials("yabba"));
    YoucryptFolder folder(path(encRoot), opts, creds);
    folder.mount(path(mntPoint));
    return 0;
}

int testImport (string encRoot, string dn)
{
    // Write test program below
    string srcFolder = dn;
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials("yet_another"));
    cout << "Encrypted Folder is " << encRoot << endl;
    //opts.filenameEncryption = YoucryptFolderOpts::filenameEncrypt;
    YoucryptFolder folder(path(encRoot), opts, creds);
    
    string destSuffix = path(srcFolder).filename().string();
    cout << "Encrypting contents of " << srcFolder << " into " << encRoot << endl
    << "at " << "/" << destSuffix << endl;
    folder.importContent(path(srcFolder), destSuffix);
    return 0;
}

int main(int argc, char **argv) {
    //testImport("/Users/rajsekar/tmp/test/5.yc", "/Users/rajsekar/tmp/test/data");
    testMount("/Users/rajsekar/tmp/test/2.yc", "/Users/rajsekar/tmp/test/mntpoint");
    cout << "Mounted at .../mntpoint\n";
    int a;
    cin >> a;
    return 0;
}