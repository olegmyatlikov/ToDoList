//
//  OMMTaskService.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMMTask.h"
#import "OMMTasksGroup.h"

@interface OMMTaskService : NSObject

@property (nonatomic, strong, readonly) NSArray *tasksGroupsArray;
@property (nonatomic, strong, readonly) NSArray *allTasksArray;
@property (nonatomic, strong) OMMTasksGroup *inboxTasksGroup;

+ (instancetype)sharedInstance;

- (OMMTask *)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(TaskPriority)priority enableRemainder:(BOOL)remainder;
- (OMMTasksGroup *)createTasksGroup:(NSString *)groupName;

- (void)addTaskGroup:(OMMTasksGroup *)taskGroup;
- (void)addTask:(OMMTask *)task;
- (void)addTask:(OMMTask *)task toTaskGroup:(OMMTasksGroup *)taskGroup;
- (void)removeTasksGroup:(OMMTasksGroup *)tasksGroup;
- (void)removeTask:(OMMTask *)task;

//- (void)replaceEditedTask:(OMMTask*)editedTask inTasksGroup:(OMMTasksGroup *)tasksGroup;

@end
