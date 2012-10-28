//
//  SharingController.h
//  Youcrypt
//
//  Created by avr on 10/27/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SharingGetEmailsView;

@interface SharingController : NSWindowController

@property (nonatomic, strong) IBOutlet SharingGetEmailsView *sharingView;

- (void) setWindowAttributes:(NSString*)title
                  folderPath:(NSString*)dirPath;

@end
