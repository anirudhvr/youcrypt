//
//  MyNSMenu.m
//  Youcrypt
//
//  Created by avr on 10/22/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "MyNSMenu.h"

@implementation MyNSMenu

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return [menuItem isEnabled];
}

@end
