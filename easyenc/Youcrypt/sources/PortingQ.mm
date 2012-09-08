//
//  PortingQ.mm
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 8/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "PortingQ.h"
#import "AppDelegate.h"

using namespace youcrypt;

namespace youcrypt {
    void EncryptQ::doJob(const string &s) {
        NSString *ns;
        ns = [NSString stringWithCString:s.c_str()
                                encoding:NSASCIIStringEncoding];
        [theApp doEncrypt:ns];
    }
    
    void DecryptQ::doJob(const tuple<string, string> &decryptData) {
        string path = boost::get<0>(decryptData);
        string mountPath = boost::get<1>(decryptData);
        NSString *pt = [NSString stringWithCString:path.c_str()
                                          encoding:NSASCIIStringEncoding];
        NSString *mpt = [NSString stringWithCString:mountPath.c_str()
                                           encoding:NSASCIIStringEncoding];
        [theApp doDecrypt:pt mountedPath:mpt];
   }
    
    void RestoreQ::doJob(const string &s) {
        NSString *ns;
        ns = [NSString stringWithCString:s.c_str()
                                encoding:NSASCIIStringEncoding];
        [theApp doRestore:ns];
    }
    
    void OpenFileQ::doJob(const string &s) {
        NSString *ns;
        ns = [NSString stringWithCString:s.c_str()
                                 encoding:NSASCIIStringEncoding];
        [theApp openEncryptedFolder:ns];
    }
}