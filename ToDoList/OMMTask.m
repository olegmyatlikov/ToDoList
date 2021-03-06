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


- (id)init {
    self = [super init];
    if (self && !self.taskID) {
        self.taskID = arc4random_uniform(10000);
    }
    return self;
}


#pragma mark - localization

+ (NSString *)taskPriorityToString:(OMMTaskPriority)taskPriority {
    NSString *priorityInString = [[NSString alloc] init];
    switch (taskPriority) {
        case OMMTaskPriorityNone:
            priorityInString = NSLocalizedString(@"task_priority.string-NONE", nil);
            break;
        case OMMTaskPriorityLow:
            priorityInString = NSLocalizedString(@"task_priority.string-LOW", nil);
            break;
        case OMMTaskPriorityMedium:
            priorityInString = NSLocalizedString(@"task_priority.string-MEDIUM", nil);
            break;
        case OMMTaskPriorityHigh:
            priorityInString = NSLocalizedString(@"task_priority.string-HIGH", nil);
            break;
            
        default:
            break;
    }
    
    return priorityInString;
}


#pragma mark - NSCoding method 

- (OMMTask *)initWithCoder:(NSCoder *)aDecoder {
    self = [super self];
    if (!self) {
        return nil;
    }
    
    self.taskID = [[aDecoder decodeObjectForKey:@"taskID"] integerValue];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
    self.finishDate = [aDecoder decodeObjectForKey:@"finishDate"];
    self.priority = [[aDecoder decodeObjectForKey:@"priority"] integerValue];
    self.note = [aDecoder decodeObjectForKey:@"note"];
    self.closed = [[aDecoder decodeObjectForKey:@"closed"] boolValue];
    self.enableRemainder = [[aDecoder decodeObjectForKey:@"enableRemainder"] boolValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:self.taskID] forKey:@"taskID"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.finishDate forKey:@"finishDate"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.priority] forKey:@"priority"];
    [aCoder encodeObject:self.note forKey:@"note"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.closed] forKey:@"closed"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.enableRemainder] forKey:@"enableRemainder"];
}

@end
