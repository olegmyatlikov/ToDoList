//
//  OMMTask.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTask.h"

@interface OMMTask()

@end


@implementation OMMTask


+ (NSFetchRequest<OMMTask *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"Task"];
}

@dynamic closed;
@dynamic enableRemainder;
@dynamic finishDate;
@dynamic name;
@dynamic note;
@dynamic priority;
@dynamic startDate;
@dynamic taskID;
@dynamic tasksGroup;
@dynamic positionInTasksArray;


#pragma mark - localization

+ (NSString *)taskPriorityToString:(NSInteger)taskPriority {
    NSString *priorityInString = [[NSString alloc] init];
    if (taskPriority == 0) {
        priorityInString = NSLocalizedString(@"task_priority.string-NONE", nil);
    } else if (taskPriority == 1) {
        priorityInString = NSLocalizedString(@"task_priority.string-LOW", nil);
    } else if (taskPriority == 2) {
        priorityInString = NSLocalizedString(@"task_priority.string-MEDIUM", nil);
    } else {
        priorityInString = NSLocalizedString(@"task_priority.string-HIGH", nil);
    }
    
    return priorityInString;
}

@end
