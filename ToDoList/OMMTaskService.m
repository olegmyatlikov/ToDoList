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

NSString * const OMMTaskServiceTaskWasModifyNotification = @"TaskListWasModify";
static NSString * const OMMTaskServiceNameTaskGroupInbox = @"Inbox";


#pragma mark - init service

- (instancetype)init {
    self = [super init];
    if (self) {
        OMMTasksGroup *taskGroup1 = [self createTasksGroup:@"General"];
        OMMTask *task1 = [self createTaskWithName:@"task1"
                                                  startDate:[NSDate convertStringToDate:@"22-07-2017 10:30"]
                                                      notes:@"some task1 notes"
                                                   priority:OMMTaskPriorityNone
                                            enableRemainder:YES];
        [self addTask:task1 toTaskGroup:taskGroup1];
        
        OMMTask *task2 = [self createTaskWithName:@"task2"
                                                  startDate:[NSDate convertStringToDate:@"10-07-2017 10:30"]
                                                      notes:@"some task2 notes"
                                                   priority:OMMTaskPriorityNone
                                            enableRemainder:YES];
        task2.closed = YES;
        [self addTask:task2 toTaskGroup:taskGroup1];
        
        OMMTask *task3 = [self createTaskWithName:@"task3"
                                                  startDate:[NSDate date]
                                                      notes:@"some task3 notes"
                                                   priority:OMMTaskPriorityNone
                                            enableRemainder:YES];
        [self addTask:task3 toTaskGroup:taskGroup1];
        
        
        OMMTasksGroup *taskGroup2 = [self createTasksGroup:@"Another"];
        OMMTask *task4 = [self createTaskWithName:@"task4"
                                                  startDate:[NSDate date]
                                                      notes:@"some task4 notes"
                                                   priority:OMMTaskPriorityNone
                                            enableRemainder:YES];
        task4.closed = YES;
        [self addTask:task4 toTaskGroup:taskGroup2];
        
        OMMTask *task5 = [self createTaskWithName:@"task5"
                                                  startDate:[NSDate date]
                                                      notes:@"some task5 notes"
                                                   priority:OMMTaskPriorityNone
                                            enableRemainder:YES];
        [self addTask:task5 toTaskGroup:taskGroup2];
        
        [self addTaskGroup:taskGroup1];
        [self addTaskGroup:taskGroup2];
        
        _inboxTasksGroup = [[OMMTasksGroup alloc] init];
        _inboxTasksGroup.groupName = OMMTaskServiceNameTaskGroupInbox;
        _inboxTasksGroup.tasksArray = [[NSMutableArray alloc] init];
        [_inboxTasksGroup.tasksArray addObjectsFromArray:taskGroup1.tasksArray];
        [_inboxTasksGroup.tasksArray addObjectsFromArray:taskGroup2.tasksArray];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static OMMTaskService *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}


// general methods

- (OMMTasksGroup *)createTasksGroup:(NSString *)groupName {
    OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
    taskGroup.groupName = groupName;
    return taskGroup;
}

- (OMMTask *)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(OMMTaskPriority)priority enableRemainder:(BOOL)remainder {
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

- (void)insertTaskGroup:(OMMTasksGroup *)taskGroup atIndex:(NSInteger)index {
    [self.privateTaskGroupsArray insertObject:taskGroup atIndex:index];
}

- (void)addTask:(OMMTask *)task {
    [self.inboxTasksGroup.tasksArray addObject:task];
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
}

- (void)addTask:(OMMTask *)task toTaskGroup:(OMMTasksGroup *)taskGroup {
    if (!taskGroup.tasksArray) {
        taskGroup.tasksArray = [[NSMutableArray alloc] init];
    }
    if (![taskGroup isEqual:self.inboxTasksGroup]) {
        [self.inboxTasksGroup.tasksArray addObject:task];
    }
    [taskGroup.tasksArray addObject:task];
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
}

- (void)removeTasksGroup:(OMMTasksGroup *)tasksGroup {
    for (OMMTask *task in tasksGroup.tasksArray) {
        [self.inboxTasksGroup.tasksArray removeObject:task];
    }
    [self.privateTaskGroupsArray removeObject:tasksGroup];
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
}

- (void)removeTask:(OMMTask *)task {
    [self.inboxTasksGroup.tasksArray removeObject:task];
    for (NSMutableArray *array in [self.tasksGroupsArray valueForKeyPath:@"@unionOfObjects.tasksArray"]) {
        [array removeObject:task];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
}


#pragma mark - help methods

- (NSArray *)tasksGroupsArray {
    return [self.privateTaskGroupsArray copy];
}

- (NSArray *)allTasksArray {
    return self.inboxTasksGroup.tasksArray; // Inbox tasks array = all tasks
}

- (NSMutableArray *)privateTaskGroupsArray {
    if (!_privateTaskGroupsArray) {
        _privateTaskGroupsArray = [[NSMutableArray alloc] init];
    }
    
    return _privateTaskGroupsArray;
}


@end
