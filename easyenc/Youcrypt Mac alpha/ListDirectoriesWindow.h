//
//  ListDirectoriesWindow.h
//  Youcrypt Mac alpha
//
//  Created by Rajsekar Manokaran on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoucryptDirectory.h"

@interface ListDirectoriesWindow : NSWindowController <NSTableViewDataSource> {
    NSMutableArray *directories;
    
    IBOutlet NSTableView *table;
}

@property (nonatomic, strong) NSString *directoriesListFile;

- (id)initWithListFile:(NSString *)dList;




@end
