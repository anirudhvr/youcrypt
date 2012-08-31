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
}