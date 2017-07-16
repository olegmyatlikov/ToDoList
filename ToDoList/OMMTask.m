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

@end
