//
//  YoucryptDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoucryptDirectory.h"
#import "ConfigDirectory.h"
#import "libFunctions.h"
#import "PeriodicActionTimer.h"
#import "AppDelegate.h"
#import "PassphraseManager.h"

#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp>
#include "core/DirectoryMap.h"
#include <string>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>

using boost::filesystem::path;
using boost::filesystem::ofstream;
using boost::filesystem::ifstream;
using boost::archive::xml_oarchive;
using boost::archive::xml_iarchive;
using boost::serialization::make_nvp;
using std::string;
#include <map>
using boost::shared_ptr;
using boost::unordered_map;
using std::cout;
using std::string;
using std::endl;
using std::map;
using namespace youcrypt;


@implementation YoucryptDirectory

@synthesize path;
@synthesize mountedPath;
@synthesize alias;
@synthesize mountedDateAsString;
//@synthesize status;

static BOOL globalsAllocated = NO;
static NSMutableArray *mountedFuseVolumes;
//static int minRefreshTime = 5; // at most every 30 seconds

- (id) initWithArchive:(boost::archive::xml_iarchive &)ar {
    self = [super init];

    if (self != nil) {
        NSString *pp = [theApp.passphraseManager getPassphrase];
        
        string strPath;
        ar >> boost::serialization::make_nvp("path", strPath);
        path = [NSString stringWithCString:strPath.c_str() encoding:NSASCIIStringEncoding];
        ar >> boost::serialization::make_nvp("mountedPath", strPath);
        mountedPath = [NSString stringWithCString:strPath.c_str() encoding:NSASCIIStringEncoding];
        ar >> boost::serialization::make_nvp("alias", strPath);
        alias = [NSString stringWithCString:strPath.c_str() encoding:NSASCIIStringEncoding];
        ar >> boost::serialization::make_nvp("mountedDateAsString", strPath);
        mountedDateAsString = [NSString stringWithCString:strPath.c_str() encoding:NSASCIIStringEncoding];

        boost::filesystem::path ph([path cStringUsingEncoding:NSASCIIStringEncoding]);
        if (pp != nil) {
            YoucryptFolderOpts opts;
            Credentials creds(new PassphraseCredentials([pp cStringUsingEncoding:NSASCIIStringEncoding]));
            folder.reset(new YoucryptFolder(ph, opts, creds));
        } else {
            folder.reset(new YoucryptFolder(ph));
        }
        
        if (!alias)
            alias = [[NSString alloc] init];
        
        if ([alias isEqualToString:@""]) {
            alias = [path lastPathComponent];
        }
        
        //        @synchronized(self) {
        //            if (globalsAllocated == NO) {
        //                mountedFuseVolumes = [[NSMutableArray alloc] init];
        //                [YoucryptDirectory refreshMountedFuseVolumes];
        //                globalsAllocated = YES;
        //            }
        //        }
    }
    return self;

}

- (void) saveToArchive:(boost::archive::xml_oarchive &)ar {
    string strPath, strMPath, strAlias, strMDate;
    strPath = string([path cStringUsingEncoding:NSASCIIStringEncoding]);
    if (mountedPath != nil)
        strMPath = string([mountedPath cStringUsingEncoding:NSASCIIStringEncoding]);
    else
        strMPath = string("");
    if (alias != nil)
        strAlias = string([alias cStringUsingEncoding:NSASCIIStringEncoding]);
    else
        strAlias = "";
    if (mountedDateAsString != nil)
        strMDate = string([mountedDateAsString cStringUsingEncoding:NSASCIIStringEncoding]);
    else
        strMDate = "";
    
    
    ar << make_nvp("path", strPath);
    ar << make_nvp("mountedPath", strMPath);
    ar << make_nvp("alias", strAlias);
    ar << make_nvp("mountedDateAsString", strMDate);
}

- (id) initWithPath:(NSString*)p
{
    self = [super init];
    if (self != nil)
    {
        path = [NSString stringWithString:p];
        boost::filesystem::path ph([path cStringUsingEncoding:NSASCIIStringEncoding]);
        folder.reset(new YoucryptFolder(ph));
    }
    return self;
}

- (BOOL)encryptFolderInPlaceWithPassphrase:(NSString*)pp
                          encryptFilenames:(BOOL)encfnames
{
}

- (BOOL) openEncryptedFolderAtMountPoint:(NSString*)destFolder
                          withPassphrase:(NSString*)pp
                                idleTime:(int)idletime
                                fuseOpts:(NSDictionary*)fuseOpts
{
    BOOL ret = YES;
    const char *srcfolder = [[path stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *destfolder = [destFolder cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    std::vector<std::string> fuse_opts;
    boost::filesystem::path src(srcfolder);
    boost::filesystem::path dst(destfolder);
    
    if (folder == NULL ||
        (folder->currStatus() != YoucryptFolder::initialized))
        // ensure that this is a legit Youcrypt folder
        return NO;
    
    create_directories(dst);
    
    YoucryptFolderOpts opts;
//    unordered_map<string,string> empty;
    map<string,string> empty;
    string priv([theApp.configDir.youCryptPrivKeyFile cStringUsingEncoding:NSASCIIStringEncoding]);
    string pub([theApp.configDir.youCryptPubKeyFile cStringUsingEncoding:NSASCIIStringEncoding]);
//    CredentialStorage cs(new RSACredentialStorage(priv, pub, empty));
    CredentialStorage cs([theApp.configDir getCredStorage]);
    //    Credentials creds(new PassphraseCredentials(pass));
    Credentials creds(new RSACredentials(pass, cs));
    
    if (idletime < 0)
        idletime = 0;
    for (NSString *key in [fuseOpts allKeys]) {
        NSString *opt;
        if ([key isEqualToString:@"volicon"]) {
            opt = [NSString stringWithFormat:@"-ovolicon=%@/Contents/Resources/%@", [libFunctions appBundlePath], [fuseOpts objectForKey:key]];
        } else {
            opt = [NSString stringWithFormat:@"-o%@=%@", key, [fuseOpts objectForKey:key]];
        }
        fuse_opts.push_back(std::string([opt cStringUsingEncoding:NSASCIIStringEncoding]));
    }
    fuse_opts.push_back(std::string("-ofsname=YoucryptFS"));
    bool m = folder->loadConfigAtPath(src, creds);
    if (m) {
        if (folder->currStatus() == YoucryptFolder::initialized) {
            m = folder->mount(dst, fuse_opts, idletime);
        }
        else {
            m = false;
        }
    }
    if (!m || (folder->currStatus() != YoucryptFolder::mounted)) {
        DDLogInfo(@"Mounting %@ at %@ failed!", path, destFolder);
        ret = NO;
    }
    
    return ret;
}

- (BOOL)decryptFolderInPlaceWithPassphrase:(NSString *)pp
{
    const char *srcfolder = [[path stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    BOOL ret = YES;
    
    boost::filesystem::path ph = boost::filesystem::temp_directory_path() / boost::filesystem::unique_path();
    create_directories(ph);
    NSString *tempFolder = [NSString stringWithFormat:@"%s",ph.string().c_str()];
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials(pass));
    
    if (folder->currStatus() == YoucryptFolder::mounted)
        if (!folder->unmount()) {
            ret = NO;
            goto getout;
        }
    
    // Nobody else should be using this
    assert(folder.use_count() == 1);
    
    // Export decrypted contents to temp dir
    if (folder->exportContent(ph)) {
        // success
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:path error:nil];
        NSError *err;
        // Remove everything in the source folder
        for (NSString *file in files) {
            if (!([file isEqualToString:@"."] || [file isEqualToString:@".."])) {
                if (![fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err]) {
                    DDLogInfo(@"Error removing dir: %@", [err localizedDescription]);
                    ret = NO;
                }
            }
        }
        
        // Move everything from the decrypted folder back to the source folder
        files = [fm contentsOfDirectoryAtPath:tempFolder error:nil];
        for (NSString *file in files) {
            if (![fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file]
                             toPath:[path stringByAppendingPathComponent:file] error:&err]) {
                DDLogInfo(@"Error moving contents: %@", [err localizedDescription]);
                ret = NO;
            }
        }
    } else {
        DDLogInfo(@"decrypt: could not export content of %@ to temp folder /%@", path, ENCRYPTION_TEMPORARY_FOLDER);
        ret = NO;
    }
    
getout:
    return ret;
}

- (BOOL) closeEncryptedFolder
{
    if (folder) {
        if (folder->currStatus() == YoucryptFolder::mounted)
            folder->unmount();
        folder.reset();
    }
}

- (int) status
{
    // A folder object should have been created for sure, with
    // status set to YoucryptFolder::statusUnkown
    assert(folder.get() != NULL);
    
    return folder->currStatus();
}

- (NSString*) getStatus
{
    // A folder object should have been created for sure, with
    // status set to YoucryptFolder::statusUnkown
    assert(folder.get() != NULL);
    return [NSString stringWithFormat:@""];
}


@end

