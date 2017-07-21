//
//  OMMTasksGroup.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTasksGroup.h"

@implementation OMMTasksGroup

+ (NSFetchRequest<OMMTasksGroup *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"TasksGroup"];
}

@dynamic groupID;
@dynamic groupName;
@dynamic groupStartDate;
@dynamic tasks;

- (void)printSomething {
    NSLog(@"print");
}

@end
