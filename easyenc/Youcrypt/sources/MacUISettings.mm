//
//  MacUISettings.m
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 9/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "MacUISettings.h"
#import "MixpanelAPI.h"
#import "AppDelegate.h"
#import "libFunctions.h"
#import "CompressingLogFileManager.h"
#import "YoucryptService.h"
#import "core/DirectoryMap.h"
#import <string>

using namespace youcrypt;
using std::string;
namespace bf = boost::filesystem;

namespace youcrypt {
    // Initializing Mac-specific const members
    const string MacUISettings::MacPreferenceKeys::yc_gmailusername          = "yc.gmailusername";
    const string MacUISettings::MacPreferenceKeys::yc_boxstatus              = "yc.boxstatus";
    const string MacUISettings::MacPreferenceKeys::yc_dropboxlocation        = "yc.dropboxfolderlocation";
    const string MacUISettings::MacPreferenceKeys::yc_boxlocation            = "yc.boxfolderlocation";
    const string MacUISettings::MacPreferenceKeys::yc_anonymousstatistics    = "yc.anonymousstatistics";
    const string MacUISettings::MacPreferenceKeys::yc_savepassphraseinkeychain  = "yc.saveppinkeychain";
    
    // Methods
    MacUISettings::MacUISettings(string base): YCSettings(base)
    {
        if (appFirstRun)
            firstRun();
    }
    
    void MacUISettings::firstRun()
    {
        // Insert code here to initialize stuff the first time.
        
        bf::create_directories(baseDirectory);
        bf::create_directories(volumeDirectory);
        bf::create_directories(tmpDirectory);
        bf::create_directories(logDirectory);
        bf::create_directories(keyDirectory);
        YCSettings::firstRun();
        {
            ofstream uout(userUUIDFile);
            uout << cppString(
                              [[NSProcessInfo processInfo] globallyUniqueString]);
        }
        
        setDefaultPreferences();
        
    }
    
    void MacUISettings::setDefaultPreferences()
    {
        YCSettings::setDefaultPreferences();
        (*this)[MacPreferenceKeys::yc_gmailusername] = "";
        (*this)[MacPreferenceKeys::yc_boxstatus] = "";
        (*this)[MacPreferenceKeys::yc_dropboxlocation] = "";
        (*this)[MacPreferenceKeys::yc_boxlocation] = "";
        (*this)[MacPreferenceKeys::yc_anonymousstatistics] = "";
        (*this)[MacPreferenceKeys::yc_savepassphraseinkeychain] = "";
    }
    
    void MacUISettings::loadSettings()
    {
        // Add new steps here before adding the code.
        // -1. Set default preferences
        // 0. Read config file from disk if it exists, else create the file (done in Settings::loadSettings)
        // 1. Enable logging.
        // 2. Setup MixPanel API with the UUID
        // 3. Initialize directory list
        // 4. Setup resign notification (to sync dir. list)
        // 5. Setup youcrypt service and register pb services
        
        // (step -1) Set default preferences for Mac-specific preferences,
        // which will call superclass's setDefaultPreferences as well
        setDefaultPreferences();
        
        // (step 0):  Done by the base class.
        YCSettings::loadSettings();
        
        
        // (step 1):  Enable logging.
        logFileManager = [[CompressingLogFileManager alloc]
                          initWithLogsDirectory:nsstrFromCpp(logDirectory.string())];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];
        
        // (step 2):  Setup MixPanel API with the UUID from UUID file
        mixpanel = [MixpanelAPI sharedAPIWithToken:MIXPANEL_TOKEN];
        NSError *error = nil;
        NSString *mpUUID = [NSString stringWithContentsOfFile:nsstrFromCpp
                            (userUUIDFile.string())
                                                     encoding:NSASCIIStringEncoding
                                                        error:&error];
        [mpUUID stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        mixPanelUUID = cppString(mpUUID);
        
        // XXX FIXME Change for Release
#ifdef DEBUG
        mixpanel.dontLog = YES;
#elif RELEASE
        mixpanel.dontLog = NO;
#endif
        
    }
    
}

