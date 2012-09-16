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
#import <map>

@class YoucryptService;

using std::string;

namespace youcrypt {
    class MacUISettings : public YCSettings {
    private:
        //! Application preferences that are editable by the user
        std::map <std::string, boost::any> _appPreferences;
        
    public:
        MacUISettings(string);
    protected:
        virtual void firstRun();
        virtual void loadSettings();
        
        virtual bool setPreference(std::string &prefname, boost::any &value);
        virtual boost::any& getPreference(std::string &prefname);
        
        DDFileLogger *fileLogger;
    };
    
}

