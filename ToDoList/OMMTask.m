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

NSString * const OMMTaskPriorityNone = @"none";
NSString * const OMMTaskPriorityLow = @"low";
NSString * const OMMTaskPriorityMedium = @"medium";
NSString * const OMMTaskPriorityHigh = @"high";


- (NSString*)taskPriotityToString:(TaskPriority)taskPriority {
    NSString *result = nil;
    
    switch(taskPriority) {
        case none:
            result = OMMTaskPriorityNone;
            break;
        case low:
            result = OMMTaskPriorityLow;
            break;
        case medium:
            result = OMMTaskPriorityMedium;
            break;
        case high:
            result = OMMTaskPriorityHigh;
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected taskPriority"];
    }
    
    return result;
}


- (id)init {
    self = [super init];
    if (self && !self.taskID) {
        self.taskID = arc4random_uniform(10000);
    }
    return self;
}

@end
