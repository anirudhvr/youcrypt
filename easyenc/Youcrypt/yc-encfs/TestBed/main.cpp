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
#include <boost/scoped_ptr.hpp>

using namespace std;
using namespace youcrypt;


static boost::filesystem::path mountPath, encRoot, sourcePath;
static Credentials creds;
static YoucryptFolderOpts opts;
boost::scoped_ptr<YoucryptFolder> pFolder;

extern void openssl_init(bool);


int testMount ()
{
    cout << "Mounting folder(" << encRoot.string() << ") @ " <<
        mountPath.string() << "...";
    pFolder.reset(new YoucryptFolder(encRoot, opts, creds));
    if (pFolder->mount(mountPath))
    {
        cout << "success" << endl;
        return 0;
    }
    else
    {
        cout << "failed" << endl;
        return -1;
    }
}

int testMakeRSACreds() {
    boost::unordered_map<string,string> empty;
    cout << "Generating RSA creds from /tmp/{priv,pub}.pem...";
    string priv("/tmp/priv.pem"), pub("/tmp/pub.pem");
    CredentialStorage cs(new RSACredentialStorage(priv, pub, empty));
    creds.reset(new RSACredentials("yet_another", cs));
    if (creds == Credentials()) {
        cout << "failed\n";
        return -1;
    }
    else
    {
        cout << "success\n";
        return 0;
    }
}

int testPassphraseCreds() {
    cout << "Generating passphrase cred. for yabba...";
    creds.reset(new PassphraseCredentials("yabba"));
    if (creds == Credentials()) {
        cout << "failed\n";
        return -1;
    }
    else
    {
        cout << "success\n";
        return 0;
    }

}

int testImport ()
{
    // Write test program below

    cout << "Encrypted Folder is " << encRoot << endl;
    pFolder.reset(new YoucryptFolder(encRoot, opts, creds));
    if (pFolder->currStatus() != YoucryptFolder::initialized) {
        cout << "Error initializing folder.\n";
        return -1;
    }
    string destSuffix = sourcePath.filename().string();
    cout << "Encrypting contents of " << sourcePath <<   " into " << encRoot << endl
    << "at " << "/" << destSuffix << "...";
    if (pFolder->importContent(sourcePath, destSuffix)) {
        cout << "success" << endl;
        return 0;
    }
    else {
        cout << "failed" << endl;
        return -1;
    }
}

int main(int argc, char **argv) {
    openssl_init(true);

    mountPath  = path("/Users/rajsekar/tmp/test/mntpoint");
    encRoot    = path("/Users/rajsekar/tmp/test/encroot");
    sourcePath = path("/Users/rajsekar/tmp/test/data");
    
    testMakeRSACreds();
    testImport();
    testMount();
    cout << "Enter a number to exit...";
    int a;
    cin >> a;
    return a;
}
