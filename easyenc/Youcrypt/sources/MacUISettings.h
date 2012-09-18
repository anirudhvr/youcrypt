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
        
        struct MacPreferenceKeys : public YCSettings::PreferenceKeys {
            // Additional preferencs
            static const string yc_gmailusername;
            static const string yc_boxstatus;
            static const string yc_dropboxlocation;
            static const string yc_boxlocation;
            static const string yc_anonymousstatistics;
            static const string yc_savepassphraseinkeychain;
        };
        
        
        MacUISettings(string);
    protected:
        virtual void firstRun();
        virtual void loadSettings();
        virtual void setDefaultPreferences();
        DDFileLogger *fileLogger;
    };
    
}

