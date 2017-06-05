//
//  OMMTaskService.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskService.h"

@implementation OMMTaskService

+ (void)addTask:(OMMTask *)task toTaskList:(OMMTaskList *)taskList {
    [taskList.tasksArray addObject:task];
}

+ (OMMTask *)createTaskWithName:(NSString *)name finishDate:(NSDate *)date notes:(NSString *)notes {
    
    OMMTask *task = [[OMMTask alloc] init];
    task.name = name;
    task.finishDate = date;
    task.note = notes;
    task.closed = NO;
    
    return task;
}

@end
