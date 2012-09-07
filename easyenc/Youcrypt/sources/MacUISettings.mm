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
#import "CompressingLogFileManager.h"
#import "YoucryptService.h"
#import "core/DirectoryMap.h"
#import <string>

using namespace youcrypt;
using std::string;

namespace youcrypt {
    MacUISettings::MacUISettings(string base): YCSettings(base)
    {
        
        folderExtension = ".yc";

        if (appFirstRun)
            firstRun();
    }
        
    void MacUISettings::firstRun()
    {
        // Insert code here to initialize stuff the first time.
        
        namespace fs = boost::filesystem;
        fs::create_directories(baseDirectory);
        fs::create_directories(volumeDirectory);
        fs::create_directories(tmpDirectory);
        fs::create_directories(logDirectory);
        fs::create_directories(keyDirectory);
        {
            ofstream uout(userUUIDFile);
            uout << cppString(
                [[NSProcessInfo processInfo] globallyUniqueString]);
        }

    }

    void MacUISettings::loadSettings()
    {
        // Insert code here to initialize your application
        
        // Add new steps here before adding the code.
        // 1. Enable logging.
        // 2. Setup MixPanel API with the UUID
        // 3. Initialize directory list
        // 4. Setup resign notification (to sync dir. list)
        // 5. Setup youcrypt service and register pb services
        
        
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
};
