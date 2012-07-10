//
//  PeriodicActionTimer.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 7/7/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "PeriodicActionTimer.h"

@implementation PeriodicActionTimer

@synthesize lastRefreshDate;
@synthesize minRefreshTime;


- (id) init
{
    minRefreshTime = 5; // Every 5 seconds
    return [self initWithMinRefreshTime:minRefreshTime];
}


- (id) initWithMinRefreshTime:(int)mintime
{
    self =[super init];
    if (!self) 
        return nil;
    
    minRefreshTime = mintime;
    lastRefreshDate = [[NSDate alloc] init];
    return self;
}

- (BOOL) timerElapsed
{
    NSUInteger secs_now = [[NSDate date] timeIntervalSince1970];
    NSUInteger lastrefresh = [lastRefreshDate timeIntervalSince1970];
    
    if ((secs_now - lastrefresh) >= minRefreshTime) {
        // creates new object, but i have no fucking clue how to "refresh" teh old object to current time
        lastRefreshDate = [NSDate date]; 
        return YES;
    } else {
        return NO;
    }
}

@end
