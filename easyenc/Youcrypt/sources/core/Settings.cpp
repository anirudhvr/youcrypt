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
#include <boost/filesystem/fstream.hpp>
#import <boost/serialization/map.hpp>
#import <boost/archive/xml_iarchive.hpp>
#import <boost/archive/xml_oarchive.hpp>

namespace youcrypt{
    
namespace bf = boost::filesystem;
using std::string;
using boost::shared_ptr;
using boost::serialization::make_nvp;
    
    
static Settings _theAppSettings;
    
Settings appSettings() {
    if (!_theAppSettings ||
        !_theAppSettings->isSetup)
        throw std::runtime_error("App settings uninitialized.");
    return _theAppSettings;
}
    
YCSettings::YCSettings(string b) {
    isSetup = false;
    baseDirectory = b;
    initializeSettings();
    if (_theAppSettings) 
        throw std::runtime_error(
                                 "Application already has a settings object.");
    else
        _theAppSettings.reset(this);
    
    
    if (bf::exists(baseDirectory)) {
        // Not first run.
        appFirstRun = false;
        if (bf::exists(configFile)) {
            try {
                bf::ifstream confin(configFile);
                boost::archive::xml_iarchive xi(confin);
                xi & BOOST_SERIALIZATION_NVP( _appPreferences);
            } catch (...) {
                std::cerr << "Could not read from config file"<< std::endl;
            }
        } else {
            throw std::runtime_error("Not first run but cannot find config file");
        }
    } else {
        appFirstRun = true;
    }
}
    

void YCSettings::initializeSettings() {
    configFile = baseDirectory / bf::path("config.xml");
    volumeDirectory = baseDirectory / bf::path("volumes");
    tmpDirectory = baseDirectory / bf::path("tmp");
    logDirectory = baseDirectory / bf::path("logs");
    keyDirectory = baseDirectory / bf::path("keys");
    privKeyFile = keyDirectory / bf::path("priv.pem");
    pubKeyFile = keyDirectory / bf::path("pub.pem");
    listFile =  baseDirectory / bf::path("folders.xml");
    userUUIDFile = baseDirectory / bf::path("uuid.txt");
    
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

YCSettings::~YCSettings() {
    bf::ofstream confout(configFile);
    boost::archive::xml_oarchive xo(confout);
    xo & BOOST_SERIALIZATION_NVP(_appPreferences);
}
    
    
} // end namespace youcrypt
            
            
namespace boost { namespace serialization {
    template<class Archive>
    void serialize(Archive &ar, std::map<std::string, std::string> &m, const unsigned int)
    {
        for (auto el: m) {
            ar & make_nvp("Key", el.first);
            ar & make_nvp("Value", el.second);
        }
    }
}}
