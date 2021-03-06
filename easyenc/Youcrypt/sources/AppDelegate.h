//
//  AppDelegate.h
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Subclasses/MyNSMenu.h"
#import "RestoreController.h"
#import <boost/shared_ptr.hpp>
#import "DirectoryMap.h"
#import "RSACredentialManager.h"
#import "PortingQ.h"
#import "MacUISettings.h"
#import <map>
#import "yc-networking/UserAccount.h"
#import "yc-networking/ServerConnectionWrapper.h"

using namespace youcrypt;

@class SharingController;
@class PreferenceController;
@class FileSystemsController;
@class Decrypt;
@class Encrypt;
@class ConfigDirectory;
@class YoucryptService;
@class FeedbackSheetController;
@class keyDownView;
@class DDFileLogger;
@class CompressingLogFileManager;
@class TourWizard;
@class MixpanelAPI;
@class AboutController;
@class PassphraseManager;
@class SharingGetEmailsView;

class youcrypt::MacUISettings;

@interface AppDelegate : NSObject <NSApplicationDelegate> { // changed from NSApplicationDelegate
    
    // Status Bar for Agent
    IBOutlet MyNSMenu *statusMenu;
    MyNSMenu *folderListMenu;
    IBOutlet NSMenuItem *folderListMainMenuItem;
    NSStatusItem *statusItem;
    
    SharingController *sharingController;
    
    // Controllers for various windows
    PreferenceController *preferenceController;
    Decrypt *decryptController;
    Encrypt  *encryptController;
    RestoreController *restoreController;
    TourWizard *tourWizard;
    AboutController *aboutController;

    PassphraseManager *passphraseManager;
    
    // This user's account
    boost::shared_ptr<UserAccount> userAccount;
    
    // For server connection
    boost::shared_ptr<youcrypt::ServerConnectionWrapper> serverConnectionWrapper;
    
    
    FeedbackSheetController *feedbackSheetController;
    keyDownView *keyDown;

    // List of directories maintained by us.
    // Objects added should be (Folder)
//    NSMutableArray *directories;    
    
    DDFileLogger *fileLogger;
    
    BOOL callFinderScript;
    
    EncryptQ encQ;
    DecryptQ decQ;
    RestoreQ resQ;
    OpenFileQ openFilesQ;
    long enQIndex, deQIndex, reQIndex;
    
    MacUISettings *macSettings;
    YoucryptService *youcryptService;
    BOOL appIsUp;
    

}
// Built in methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)awakeFromNib;
- (IBAction)windowShouldClose:(id)sender;
- (void) refreshFolderListMenu;
- (IBAction) shareFolderFromMenu:(id) sender;
- (IBAction) decryptFolderFromMenu:(id) sender;

// Window Related Stuff:  show / close app, etc.
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)terminateApp:(id)sender;

- (IBAction)openFeedbackPage:(id)sender;


// Enc and Dec
- (IBAction)openFeedbackPage:(id)sender;
- (IBAction)openHelpPage:(id)sender;
- (IBAction)showAboutWindow:(id)sender;

- (BOOL)openEncryptedFolderFromMenu:(id)sender;
-(BOOL)openEncryptedFolder:(NSString *)path;
-(BOOL)doDecrypt:(NSString *)path mountedPath:(NSString *)mPath;
-(void)didDecrypt:(Folder)dir;
-(void)cancelDecrypt:(Folder)dir;

-(BOOL)encryptFolder:(NSString *)path;
-(BOOL)doEncrypt:(NSString *)path;
-(void)didEncrypt:(Folder)dir;
-(void)cancelEncrypt:(NSString *)path;

-(void)removeFSAtPath:(NSString*) path;
-(void)didRestore:(NSString *)path;
-(void)cancelRestore:(NSString *)path;
-(BOOL)doRestore:(NSString *)path;


- (BOOL)close:(Folder)dir;
    
- (void) showTour;


-(BOOL)performShare:(NSString*)email
            message:(NSString*)msg
            dirPath:(NSString*)path;

-(id) passphraseReceivedFromUser:(id) sender;
- (BOOL) setupCM:(NSString*)pass
createIfNotFound:(BOOL)val
   createAccount:(BOOL)createacct
        pushKeys:(BOOL)pushkeys;

-(boost::shared_ptr<UserAccount>) getUserAccount;
-(boost::shared_ptr<ServerConnectionWrapper>) getServerConnection;

- (NSString*)sendEmail:(NSString*)emailaddr
                  from:(NSString*)fromemail
               subject:(NSString*)subj
               message:(NSString*)msg;

-(BOOL)pushFolderInfo:(string)uuid
        sharingStatus:(int)sharingstatus;

- (BOOL) ensureFolderCanBeDecrypted:(Folder)dir;

// Setters and getters
//@property (readonly) NSMutableArray *directories;
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) FeedbackSheetController *feedbackSheetController;
@property (nonatomic, strong) keyDownView *keyDown;
@property (nonatomic, strong) PreferenceController *preferenceController;
@property (nonatomic, strong) SharingController *sharingController;
@property (nonatomic, strong) NSMutableSet *dropboxEncryptedFolders;
@property (nonatomic, strong) TourWizard *tourWizard;
@property (nonatomic, strong) AboutController *aboutController;
@property (nonatomic, strong) PassphraseManager *passphraseManager;

@end

extern AppDelegate *theApp;
extern NSWindow *_window;
extern CompressingLogFileManager *logFileManager;
extern MixpanelAPI *mixpanel;
