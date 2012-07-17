//
//  ListDirTable.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "ListDirTable.h"
#import "AppDelegate.h"
#import "ListDirectoriesWindow.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>


@implementation ListDirTable

@synthesize listDirObj;


- (void) setListDir:(ListDirectoriesWindow *)listDirObject
{
    listDirObj = listDirObject;
}

- (void) keyDown:(NSEvent *)theEvent;
{
    [super keyDown:theEvent];	
    
    //NSLog(@"keycode:%lu, modifierflags: %lu", theEvent.keyCode, theEvent.modifierFlags);

    switch (theEvent.keyCode) {
        case 125: // down
        case 126: // up
            [listDirObj setStatusToSelectedRow:[listDirObj.table selectedRow]];
            break;
        case 117: // delete
            [listDirObj removeFS:listDirObj.window];
            break;
        case 36: // enter
            [listDirObj doOpenProxy:[listDirObj.table selectedRow]];
            break;
        case 15: // Test for 'Cmd-R'
            if (theEvent.modifierFlags & NSCommandKeyMask) {
                [listDirObj doOpenProxy:[listDirObj.table selectedRow]];
            }
            break; 
        case 2: // Test for Cmd-D or decryot
            if (theEvent.modifierFlags & NSCommandKeyMask) {
                [listDirObj removeFS:listDirObj.window];
            }
            break;
        case 8:  // Test for Cmd-C or close
            if (theEvent.modifierFlags & NSCommandKeyMask) {
                [listDirObj close:listDirObj.window];
            }
            break;

        default:
            break;
        
	}    
}


- (void)awakeFromNib {
    
    [super awakeFromNib];
    [[self enclosingScrollView] setDrawsBackground: NO];
    defaultImage = [NSImage imageNamed:@"Grey_Add_Folder.png"];
    otherImage = [NSImage imageNamed:@"Grey_Open_Folder.png"];
    anim = [CABasicAnimation  animation];
    [anim setDelegate:listDirObj.backgroundImageView];
    [listDirObj.backgroundImageView setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"alphaValue"]];
    [listDirObj.backgroundImageView.animator setAlphaValue:0.65];
}


- (void)setUpTrackingArea {
    // find location of image under the table 

    NSRect imgview_bound = [self getBackgroundImageRect];
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:imgview_bound
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];

}

- (void)updateTrackingAreas {
    NSRect imgview_bounds = [self getBackgroundImageRect];
    [self removeTrackingArea:trackingArea];
    trackingArea = [[NSTrackingArea alloc] initWithRect:imgview_bounds
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}



- (void)mouseEntered:(NSEvent*)event
{
//    [listDirObj.backgroundImageView.animator alpha
    [listDirObj.backgroundImageView.animator setAlphaValue:1.0];
    [[NSCursor pointingHandCursor] set];
//    [self setToolTip:[NSString stringWithString:@"Open Finder"]];

}


- (void)mouseExited:(NSEvent*)event
{
    //    [listDirObj.backgroundImageView.animator alpha
    [listDirObj.backgroundImageView.animator setAlphaValue:0.65];
    [[NSCursor arrowCursor] set];
//    [self setToolTip:nil];
    
}


- (NSRect) getBackgroundImageRect
{
    NSRect imgbound = [self convertRectToBacking:[listDirObj.backgroundImageView bounds]];
    NSRect tblbound = [self bounds];

    // add tracking area for picture under the table
    NSRect imgview_bound = [listDirObj.backgroundImageView bounds];
    imgview_bound.origin.x = tblbound.size.width/2 - imgbound.size.width/2;
    imgview_bound.origin.y = tblbound.size.height - imgbound.size.height;

    if (imgview_bound.origin.x < 191) imgview_bound.origin.x = 191; // XXX FIXME HACK tableview's size isnt correct at the beginning but becomes okay after a resize 
    
    return imgview_bound;
}


- (void)drawBackgroundInClipRect:(NSRect)clipRect {
    
    // don't draw a background rect
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    NSDragOperation ret = [super draggingEntered:sender];

    NSPasteboard *pb = [sender draggingPasteboard];
    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            //   NSLog(@"Dragging entered");
            if (backgroundImageView != nil) {
                [backgroundImageView setImage:otherImage];
            }
            
        }
    }
    
    return ret;
}


- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    [super draggingExited:sender];

    NSPasteboard *pb = [sender draggingPasteboard];

    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            //NSLog(@"Dragging exited");
            if (backgroundImageView != nil) {
                [backgroundImageView setImage:defaultImage];
            }
            
        }
    }
}

- (void) setImageViewUnderTable:(NSImageView*)imgView
{
    backgroundImageView = imgView;
    
}

- (void) setDefaultImage
{
    [backgroundImageView setImage:defaultImage];
}

- (void) setOtherImage
{
    [backgroundImageView setImage:otherImage];
}


- (BOOL)isOpaque {
    
    return NO;
}


- (void)mouseDown:(NSEvent *)theEvent {
    // determine if I handle theEvent
    // if not...
    [super mouseDown:theEvent];
    
    NSPoint globalLocation = [ NSEvent mouseLocation ];
    NSPoint windowLocation = [ self.window convertScreenToBase:globalLocation];
    NSPoint viewLocation = [listDirObj.backgroundImageView convertPoint:windowLocation fromView: nil ];
    NSPoint tableviewLocation = [self convertPoint:viewLocation fromView: listDirObj.backgroundImageView ];

    
    if( NSPointInRect( viewLocation, [listDirObj.backgroundImageView bounds ] ) ) {
        [[NSWorkspace sharedWorkspace] openFile:NSHomeDirectory()];
    }
    
//    NSLog(@"mousedown: \timgviewloc:(%f,%f)\n\ttableviewloc: (%f, %f)\n\tclickloc(%f,%f)", viewLocation.x, viewLocation.y, 
//             tableviewLocation.x, tableviewLocation.y, windowLocation.x, windowLocation.y);
}
@end
