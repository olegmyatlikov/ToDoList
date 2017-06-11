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

+ (OMMTask *)createTaskWithName:(NSString *)name finishDate:(NSDate *)date notes:(NSString *)notes {
    OMMTask *task = [[OMMTask alloc] init];
    task.name = name;
    task.finishDate = date;
    task.note = notes;
    task.closed = NO;
    return task;
}

+ (void)addTask:(OMMTask *)task toTasksGroup:(OMMTasksGroup *)tasksGroup {
    [tasksGroup.tasksArray addObject:task];
}

@end
