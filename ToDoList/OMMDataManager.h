//
//  OMMDataManager.h
//  ToDoList
//
//  Created by Oleg Myatlikov on 7/19/17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OMMTask.h"
#import "OMMTasksGroup.h"

@class TasksGroup;

extern NSString * const OMMTaskServiceTaskWasModifyNotification;

@interface OMMDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) OMMTasksGroup *inboxTasksGroup;

+ (instancetype)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(OMMTaskPriority)priority enableRemainder:(BOOL)remainder inTasksGroup:(OMMTasksGroup *)taskGroup;
- (void)updateTaskWichID:(NSNumber *)taskID  changedName:(NSString *)changedName changedDate:(NSDate *)changedDate changedTaskNotes:(NSString *)changedTaskNotes changedPriority:(OMMTaskPriority)changedPriority changedRemainder:(NSNumber *)changedRemainder;
- (void)deleteTaskByID:(NSNumber *)taskID;
- (void)closeTaskByID:(NSNumber *)taskID;

- (OMMTasksGroup *)createTasksGroupWithName:(NSString *)name;
- (void)deleteTasksGroupByID:(NSNumber *)tasksGroupID;
- (void)renameTasksGroupWithID:(NSNumber *)tasksGroupID to:(NSString *)newName;

- (NSArray *)getAllTaskArray;
- (NSArray *)getAllTasksGroups;

@end
