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
    
    if (bf::exists(configFile)) {
        // Not first run.
        appFirstRun = false;
    } else {
        appFirstRun = true;
    }
}
    
std::string &YCSettings::operator[] (const std::string &prefKey) {
    return _appPreferences[prefKey];
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

void YCSettings::saveSettings() {
    bf::ofstream confout(configFile);
    boost::archive::xml_oarchive xo(confout);
    xo & make_nvp("Preferences", _appPreferences);
}
    
void YCSettings::loadSettings() {
    if (bf::exists(configFile)) {
        bf::ifstream confin(configFile);
        boost::archive::xml_iarchive xi(confin);
        xi & make_nvp("Preferences", _appPreferences);
    } else {
        // FIXME: Create one?
    }
}
    
void YCSettings::firstRun() {
    // Nothing much: create and save an empty map.
    saveSettings();
}
    
    
} // end namespace youcrypt

namespace boost{
    namespace serialization{
        template<class A>
        void save (A &ar, const std::map<std::string, std::string> &mp, const unsigned int) {
            int s = mp.size();
            ar & make_nvp("count", s);
            for (auto el: mp) {
                ar & make_nvp("Key", el.first);
                ar & make_nvp("Value", el.second);
            }
        }
        
        template<class A>
        void load (A &ar, std::map<std::string, std::string> &mp, const unsigned int) {
            int s;
            ar & make_nvp("count", s);
            for (int i=0; i<s; i++) {
                std::string key, value;
                ar & make_nvp("Key", key);
                ar & make_nvp("Value", value);
                mp[key] = value;
            }
        }
        
        template<class A>
        void serialize(A &ar, std::map<std::string, std::string> &mp, const unsigned int v) {
            split_free(ar, mp, v);
        }
        
    }
}

//if (bf::exists(configFile)) {
//    try {
//        bf::ifstream confin(configFile);
//        boost::archive::xml_iarchive xi(confin);
//        xi & BOOST_SERIALIZATION_NVP( _appPreferences);
//    } catch (...) {
//        std::cerr << "Could not read from config file"<< std::endl;
//        }
//        } else {
//            throw std::runtime_error("Not first run but cannot find config file");
//        }

            
