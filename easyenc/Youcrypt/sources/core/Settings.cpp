//
//  Settings.cpp
//  Youcrypt
//
//  Created by Rajsekar Manokaran on 9/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#include "Settings.h"
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/shared_ptr.hpp>
#include <string>

namespace fs = boost::filesystem;
using boost::filesystem::path;
using std::string;
using boost::shared_ptr;



namespace youcrypt{
    static Settings _theAppSettings;

    YCSettings::YCSettings(string b) {
        isSetup = false;
        baseDirectory = b;
        initializeSettings();
        if (_theAppSettings) 
            throw std::runtime_error(
                "Application already has a settings object.");
        else
            _theAppSettings.reset(this);


        if (fs::exists(baseDirectory)) {
            // Not first run.
            appFirstRun = false;            
        } else {
            appFirstRun = true;
        }
    }

    Settings appSettings() {
        if (!_theAppSettings ||
            !_theAppSettings->isSetup)
            throw std::runtime_error("App settings uninitialized.");
        return _theAppSettings;
    }
        

    void YCSettings::initializeSettings() {
        volumeDirectory = baseDirectory / path("volumes");
        tmpDirectory = baseDirectory / path("tmp");
        logDirectory = baseDirectory / path("logs");
        keyDirectory = baseDirectory / path("keys");
        privKeyFile = keyDirectory / path("priv.pem");
        pubKeyFile = keyDirectory / path("pub.pem");
        listFile =  baseDirectory / path("folders.xml");
        userUUIDFile = baseDirectory / path("uuid.txt");
        
        folderExtension = ".yc";

    }
    
    void YCSettings::settingsUp() {
        if (!_theAppSettings)
            throw std::runtime_error("App settings uninitialized.");
        if (_theAppSettings->isSetup)
            throw std::runtime_error("App settings already setup.");
        if (_theAppSettings->appFirstRun)
            _theAppSettings->firstRun();
        _theAppSettings->loadSettings();
        _theAppSettings->appFirstRun = false;
        _theAppSettings->isSetup = true;
    }
}
