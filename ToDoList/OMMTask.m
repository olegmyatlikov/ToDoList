//
//  OMMTask.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTask.h"

@interface OMMTask()

@property (nonatomic, assign, readwrite) NSInteger taskID;

@end


@implementation OMMTask

NSString * const OMMTaskPriorityString[] = {
    [OMMTaskPriorityNone] = @"none",
    [OMMTaskPriorityLow] = @"low",
    [OMMTaskPriorityMedium] = @"medium",
    [OMMTaskPriorityHigh] = @"high"
};

- (id)init {
    self = [super init];
    if (self && !self.taskID) {
        self.taskID = arc4random_uniform(10000);
    }
    return self;
}

@end
