//
//  Settings.h
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 9/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#ifndef __Youcrypt__Settings__
#define __Youcrypt__Settings__

#include <boost/filesystem/path.hpp>
#include <boost/shared_ptr.hpp>
#include <string>
#import <map>

namespace bf = boost::filesystem;
using std::string;
using boost::shared_ptr;


namespace youcrypt {

/*! Application Configuration Design:
  
 *  This application class should contain a settings object and
 *  construct with the base directory (say ~/.youcrypt)
 *  This class then checks if the
 *  volumeDirectory directory exists.  If it does not exist,
 *  first run is called
 *
 *
 *  Everywhere else in the application, appSettings() returns a
 *  shared_ptr to the settings object created when the app object
 *  is created.

 */
    
class YCSettings {
public:
    //! Each entry here should have a init. in loadSettings() and
    //! in firstRun().  
    bf::path baseDirectory;
    bf::path configFile;
    bf::path volumeDirectory;
    bf::path tmpDirectory;
    bf::path logDirectory;
    bf::path keyDirectory;
    bf::path privKeyFile;
    bf::path pubKeyFile;
    bf::path listFile;
    bf::path userUUIDFile;
    
    struct PreferenceKeys {
        // User information
        static const string yc_userrealname;
        static const string yc_useremail;
        
        // Application prefrences
        static const string yc_encryptfilenames;
        static const string yc_idletime;
        static const string yc_startonboot;
        static const string yc_folderextension;
        
    };
    
    //! For mixpanel logging.
    string mixPanelUUID;

    //! Application preferences that are editable by the user
    string &operator[] (const string &);

    //! Flags that maybe shouldn't be public? FIXME
    bool isSetup, appFirstRun;
    

    YCSettings(string);
    static void settingsUp();    
    virtual void saveSettings();
protected:
    void initializeSettings();
    virtual void loadSettings();
    virtual void firstRun();
    virtual void setDefaultPreferences();
    
    //! Stores application preferences
    std::map <string, string> _appPreferences;

        
}; // end class YCSettings
    
    
typedef shared_ptr<YCSettings> Settings;
Settings appSettings();
    
    
}; // end namespace youcrypt
 
#endif /* defined(__Youcrypt__Settings__) */
