//
//  FolderInfo.h
//  Youcrypt
//
//  Created by avr on 10/31/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef Youcrypt_FolderInfo_h
#define Youcrypt_FolderInfo_h

#include <string>

namespace youcrypt {
    struct FolderInfo {
        enum SharingStatus {
            FolderInfo_Private = 0,
            FolderInfo_Shared
        };
        
        std::string uuid;
        SharingStatus sharing_status;
    };
    
}

#endif
