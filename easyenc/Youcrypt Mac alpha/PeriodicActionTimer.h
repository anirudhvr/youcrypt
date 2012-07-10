//
//  PeriodicActionTimer.h
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 7/7/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeriodicActionTimer : NSObject

@property (nonatomic, strong) NSDate *lastRefreshDate;
@property (nonatomic, assign) int minRefreshTime;

- (id) initWithMinRefreshTime:(int)mintime;
- (BOOL) timerElapsed;

@end
