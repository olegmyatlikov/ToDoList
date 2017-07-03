//
//  OMMTasksGroup.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTasksGroup.h"

@implementation OMMTasksGroup

- (id)init {
    self = [super init];
    if (self) {
        self.groupID = arc4random_uniform(10000);
        self.groupStartDate = [NSDate date];
    }
    return self;
}

- (OMMTasksGroup *)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.groupID = [[aDecoder decodeObjectForKey:@"groupID"] integerValue];
    self.groupName = [aDecoder decodeObjectForKey:@"groupName"];
    self.groupStartDate = [aDecoder decodeObjectForKey:@"groupStartDate"];
    self.tasksArray = [aDecoder decodeObjectForKey:@"tasksArray"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:self.groupID] forKey:@"groupID"];
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeObject:self.groupStartDate forKey:@"groupStartDate"];
    [aCoder encodeObject:self.tasksArray forKey:@"tasksArray"];
}

@end
