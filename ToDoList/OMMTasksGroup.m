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
@dynamic allTasksArray;

- (NSArray *)allTasksArray {
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"positionInTasksArray" ascending:YES];
    NSArray *sortedArray = [self.tasks sortedArrayUsingDescriptors:@[nameDescriptor]];
    return sortedArray;
}

@end
