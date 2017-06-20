//
//  OMMTaskService.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskService.h"
#import "NSDate+OMMDateConverter.h"

@interface OMMTaskService()

@property (nonatomic, strong) NSMutableArray *privateTaskGroupsArray;

@end

@implementation OMMTaskService

- (instancetype)init {
    self = [super init];
    if (self) {
        OMMTasksGroup *taskGroup1 = [self createTasksGroup:@"General"];
        OMMTask *task1 = [self createTaskWithName:@"task1"
                                                  startDate:[NSDate convertStringToDate:@"10-07-2017 10:30"]
                                                      notes:@"some task1 notes"
                                                   priority:none
                                            enableRemainder:YES];
        [self addTask:task1 toTaskGroup:taskGroup1];
        
        OMMTask *task2 = [self createTaskWithName:@"task2"
                                                  startDate:[NSDate convertStringToDate:@"10-07-2017 10:30"]
                                                      notes:@"some task2 notes"
                                                   priority:none
                                            enableRemainder:YES];
        [self addTask:task2 toTaskGroup:taskGroup1];
        
        OMMTask *task3 = [self createTaskWithName:@"task3"
                                                  startDate:[NSDate convertStringToDate:@"10-07-2017 10:30"]
                                                      notes:@"some task3 notes"
                                                   priority:none
                                            enableRemainder:YES];
        [self addTask:task3 toTaskGroup:taskGroup1];
        
        
        OMMTasksGroup *taskGroup2 = [self createTasksGroup:@"Another"];
        OMMTask *task4 = [self createTaskWithName:@"task4"
                                                  startDate:[NSDate convertStringToDate:@"10-07-2017 10:30"]
                                                      notes:@"some task4 notes"
                                                   priority:none
                                            enableRemainder:YES];
        [self addTask:task4 toTaskGroup:taskGroup2];
        
        OMMTask *task5 = [self createTaskWithName:@"task5"
                                                  startDate:[NSDate convertStringToDate:@"10-07-2017 10:30"]
                                                      notes:@"some task5 notes"
                                                   priority:none
                                            enableRemainder:YES];
        [self addTask:task5 toTaskGroup:taskGroup2];
        
        
        [self addTaskGroup:taskGroup1];
        [self addTaskGroup:taskGroup2];
    }
    return self;
}


- (OMMTasksGroup *)createTasksGroup:(NSString *)groupName {
    OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
    taskGroup.groupName = groupName;
    return taskGroup;
}

- (OMMTask *)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(TaskPriority)priority enableRemainder:(BOOL)remainder {
    OMMTask *task = [[OMMTask alloc] init];
    task.name = name;
    task.startDate = date;
    task.note = notes;
    task.closed = NO;
    task.priority = priority;
    task.enableRemainder = remainder;
    return task;
}


- (void)addTaskGroup:(OMMTasksGroup *)taskGroup {
    [self.privateTaskGroupsArray addObject:taskGroup];
}

- (void)addTask:(OMMTask *)task toTaskGroup:(OMMTasksGroup *)taskGroup {
    if (!taskGroup.tasksArray) {
        taskGroup.tasksArray = [[NSMutableArray alloc] init];
    }
    [taskGroup.tasksArray addObject:task];
}

- (NSArray *)tasksGroupArray {
    return [self.privateTaskGroupsArray copy];
}

- (NSMutableArray *)privateTaskGroupsArray {
    if (!_privateTaskGroupsArray) {
        _privateTaskGroupsArray = [[NSMutableArray alloc] init];
    }
    
    return _privateTaskGroupsArray;
}

@end
