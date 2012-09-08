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

using boost::filesystem::path;
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
        path baseDirectory;
        path volumeDirectory;
        path tmpDirectory;
        path logDirectory;
        path keyDirectory;
        path privKeyFile;
        path pubKeyFile;
        path listFile;
        path userUUIDFile;
        
        //! For mixpanel logging.
        string mixPanelUUID;

        //! ".yc"
        string folderExtension;

        bool isSetup, appFirstRun;

    public:
        YCSettings(string);
        static void settingsUp();

    protected:
        virtual void firstRun() = 0;
        virtual void initializeSettings();
        virtual void loadSettings() = 0;

    protected:
        
    };
    typedef shared_ptr<YCSettings> Settings;
    Settings appSettings();
};

#endif /* defined(__Youcrypt__Settings__) */
