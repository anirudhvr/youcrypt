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
#include "RSACredentials.h"
#include "Credentials.h"
#include <iostream>

#include <boost/unordered_map.hpp>

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

int testImportRSA (string encRoot, string dn)
{
    // Write test program below
    string srcFolder = dn;
    
    YoucryptFolderOpts opts;
        boost::unordered_map<string,string> empty;
    string priv("/tmp/priv.pem"), pub("/tmp/pub.pem");
    CredentialStorage cs(new RSACredentialStorage(priv, pub, empty));
    Credentials creds(new RSACredentials("yet_another", cs));
    
    cout << "Encrypted Folder is " << encRoot << endl;
    //opts.filenameEncryption = YoucryptFolderOpts::filenameEncrypt;
    YoucryptFolder folder(path(encRoot), opts, creds);
    
    string destSuffix = path(srcFolder).filename().string();
    cout << "Encrypting contents of " << srcFolder << " into " << encRoot << endl
    << "at " << "/" << destSuffix << endl;
    folder.importContent(path(srcFolder), destSuffix);
    folder.addCredential(Credentials(new PassphraseCredentials("asdf")));
    folder.loadConfigAtPath(path(encRoot), Credentials(new PassphraseCredentials("asdf")));
    folder.mount(path("/tmp/mountpt"));
    
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
    cout << "Encrypting contents of " << srcFolder <<   " into " << encRoot << endl
    << "at " << "/" << destSuffix << endl;
    folder.importContent(path(srcFolder), destSuffix);
    return 0;
}

int main(int argc, char **argv) {
    //testImport("/Users/rajsekar/tmp/test/5.yc", "/Users/rajsekar/tmp/test/data");
    testImportRSA("/tmp/test.yc", "/tmp/copy");
    int a;
    cin >> a;
    return 0;
}
