//
//  Decrypt.h
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "core/YCFolder.h"

using namespace youcrypt;

@interface Decrypt : NSWindowController {
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *errorMessage;
    Folder dir;
    BOOL keychainHasPassphrase;
    NSString *passphraseFromKeychain;
    
    NSString *srcFolder, *destFolder;
}

- (IBAction)decrypt:(id)sender;

@property (atomic, copy) NSString *passphraseFromKeychain;
@property (atomic, assign) BOOL keychainHasPassphrase;
@property (nonatomic, assign) Folder dir;
@property (nonatomic, assign) NSString *mountPath;

@end
