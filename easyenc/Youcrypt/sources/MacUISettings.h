//
//  MacUISettings.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 9/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "core/Settings.h"
#import "CompressingLogFileManager.h"
#import <string>

@class YoucryptService;

using std::string;

namespace youcrypt {
    class MacUISettings : public YCSettings {
    private:
        
    public:
        MacUISettings(string);
    protected:
        virtual void firstRun();
        virtual void loadSettings();
        DDFileLogger *fileLogger;
    };
    
}

