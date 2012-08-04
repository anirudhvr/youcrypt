//
//  PassphraseManager.h
//  Youcrypt
//
//  Created by avr on 8/1/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PreferenceController;

@interface PassphraseManager : NSWindowController <NSWindowDelegate> {
    BOOL saveInKeychain;
    NSString *serviceName;
    NSString *passPhrase;
    IBOutlet NSTextField *email;
    IBOutlet NSSecureTextField *pass;
    IBOutlet NSTextField *message;
    IBOutlet NSButton *closeButton; 
 
    PreferenceController *prefC;
}

- (id)initWithPrefController:(PreferenceController*)pref
              saveInKeychain:(BOOL)save;

- (NSString*)getPassphrase;
- (BOOL)changePassphrase:(NSString*)newPassphrase
                 oldPass:(NSString*)oldPassphrase;
- (BOOL)setPassphrase:(NSString*) passphrase;
- (BOOL)savePassphraseToKeychain;
- (BOOL)deletePassphraseFromKeychain;

-(IBAction)goClicked:(id) sender;
-(IBAction)closeButtonClicked:(id) sender;

@property (nonatomic, strong) NSString *passPhrase;
@property (nonatomic, strong) NSString *serviceName;
@property (atomic, assign) BOOL saveInKeychain;

@property (nonatomic, strong) NSTextField *email;
@property (nonatomic, strong) NSTextField *message;
@property (nonatomic, strong) NSSecureTextField *pass;
@property (nonatomic, strong) NSButton *closeButton;


@end
