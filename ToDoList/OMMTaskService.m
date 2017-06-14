//
//  OMMTaskService.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskService.h"

@implementation OMMTaskService


+ (OMMTasksGroup *)createTasksGroup:(NSInteger)groupID groupName:(NSString *)groupName {
    OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
    taskGroup.groupID = groupID;
    taskGroup.groupName = groupName;
    return taskGroup;
}

+ (OMMTask *)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(TaskPriority)priority enableRemainder:(BOOL)remainder {
    OMMTask *task = [[OMMTask alloc] init];
    task.taskID = arc4random_uniform(1000);
    task.name = name;
    task.startDate = date;
    task.note = notes;
    task.closed = NO;
    task.priority = priority;
    task.enableRemainder = remainder;
    return task;
}

+ (void)addTask:(OMMTask *)task toTasksGroup:(OMMTasksGroup *)tasksGroup {
    [tasksGroup.tasksArray addObject:task];
}

@end
