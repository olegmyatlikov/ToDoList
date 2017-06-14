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

+ (void)addTask:(OMMTask *)task toTasksGroup:(OMMTasksGroup *)tasksGroup;
+ (OMMTask *)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(TaskPriority)priority enableRemainder:(BOOL)remainder;
+ (OMMTasksGroup *)createTasksGroup:(NSInteger)groupID groupName:(NSString *)groupName;


@end
