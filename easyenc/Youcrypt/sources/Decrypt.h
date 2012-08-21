//
//  Decrypt.h
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class YoucryptDirectory;

@interface Decrypt : NSWindowController {
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *errorMessage;
    YoucryptDirectory *dir;
    BOOL keychainHasPassphrase;
    NSString *passphraseFromKeychain;
    
    NSString *srcFolder, *destFolder;
}

- (IBAction)decrypt:(id)sender;

@property (atomic, strong) YoucryptDirectory *dir;
@property (atomic, copy) NSString *passphraseFromKeychain;
@property (atomic, assign) BOOL keychainHasPassphrase;

@end
