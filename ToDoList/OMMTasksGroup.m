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

@end
