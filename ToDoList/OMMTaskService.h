//
//  OMMTaskService.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMMTask.h"
#import "OMMTaskList.h"

@interface OMMTaskService : NSObject

+ (void)addTask:(OMMTask *)task toTaskList:(OMMTaskList *)taskList;
+ (OMMTask *)createTaskWithName:(NSString *)name finishDate:(NSDate *)date notes:(NSString *)notes;


@end
