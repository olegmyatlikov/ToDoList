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

#pragma mark - localization

static NSString *OMMTaskPriorityStringNone;
static NSString *OMMTaskPriorityStringLow;
static NSString *OMMTaskPriorityStringMedium;
static NSString *OMMTaskPriorityStringHigh;

+ (void)initialize {
    OMMTaskPriorityStringNone = NSLocalizedString(@"", nil);
    OMMTaskPriorityStringLow = NSLocalizedString(@"", nil);
    OMMTaskPriorityStringMedium = NSLocalizedString(@"", nil);
    OMMTaskPriorityStringHigh = NSLocalizedString(@"", nil);
}


// enum options in string

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
