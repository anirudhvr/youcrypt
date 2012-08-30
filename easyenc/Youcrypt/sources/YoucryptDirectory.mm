//
//  YoucryptDirectory.m
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoucryptDirectory.h"
#import "libFunctions.h"
#import "PeriodicActionTimer.h"
#import "AppDelegate.h"
#import "PassphraseManager.h"

#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp>
#include "DirectoryMap.h"
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
using boost::shared_ptr;
using std::cout;
using std::string;
using std::endl;
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
    
- (id)initWithCoder:(NSCoder *)decoder {
    // THIS FUNCTION IS DEPRECATED
    // See above initWithArchive
    self = [super init];
    return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder {
    // THIS FUNCTION IS DEPRECATED
    // See above saveToArchive
//    [encoder encodeInteger:status forKey:@"status"];
}


- (BOOL)encryptFolderInPlaceWithPassphrase:(NSString*)pp
                          encryptFilenames:(BOOL)encfnames
{
    const char *srcfolder = [[path stringByAppendingString:@"/"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pass = [pp cStringUsingEncoding:NSASCIIStringEncoding];
    BOOL ret = YES;
    
    boost::filesystem::path ph = boost::filesystem::temp_directory_path() / boost::filesystem::unique_path();
    boost::filesystem::create_directories(ph);
    NSString *tempFolder = [NSString stringWithFormat:@"%s", ph.string().c_str()];
    
    YoucryptFolderOpts opts;
    Credentials creds(new PassphraseCredentials(pass));
    
    if (encfnames)
        opts.filenameEncryption = YoucryptFolderOpts::filenameEncrypt;
    
    YoucryptFolder tmpFolder(ph, opts, creds);
    
   // folder.reset(new YoucryptFolder(ph, opts, creds));
    
    if (tmpFolder.importContent(boost::filesystem::path(srcfolder))) {
        // encrypting content to temporary folder succeeded
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:path error:nil];
        NSError *err;
        // Remove everything in the source folder
        for (NSString *file in files) {
            if (!([file isEqualToString:@"."] || [file isEqualToString:@".."])) {
                if (![fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err]) {
                    DDLogInfo(@"Error removing dir: %@", [err localizedDescription]);
                    return NO;
                }
            }
        }
        
        
        // Move everything from the tmp encrypted folder back to the source folder
        files = [fm contentsOfDirectoryAtPath:tempFolder error:nil];
        for (NSString *file in files) {
            if (![fm moveItemAtPath:[tempFolder stringByAppendingPathComponent:file]
                             toPath:[path stringByAppendingPathComponent:file] error:&err]) {
                DDLogInfo(@"Error moving contents: %@", [err localizedDescription]);
                return NO;
            }
        }
        
    } else {
        DDLogInfo(@"Encrypt: could not import content of %@ to temp folder /%@", path, ENCRYPTION_TEMPORARY_FOLDER);
        folder.reset();
        ret = NO;
    }
    
    // Things seem to have worked. Now we reset the instance variable folder with the original source folder
    folder.reset(new YoucryptFolder(boost::filesystem::path(srcfolder), opts, creds));
    if (folder->currStatus() != YoucryptFolder::initialized) {
        // Something went wrong during the whole process
        DDLogInfo(@"Error resetting instance variable 'folder' to newly encrypted folder");
        folder.reset(new YoucryptFolder(boost::filesystem::path(srcfolder)));
        return NO;
    }
    
    return ret;
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
    Credentials creds(new PassphraseCredentials(pass));
    
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
    
    return [NSString stringWithFormat:@"%s", folder->statusAsString()];
}


@end

