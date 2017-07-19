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

extern NSString * const OMMTaskServiceTaskWasModifyNotification;

@interface OMMDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(OMMTaskPriority)priority enableRemainder:(BOOL)remainder;
- (void)updateTaskWichID:(NSNumber *)taskID  changedName:(NSString *)changedName changedDate:(NSDate *)changedDate changedTaskNotes:(NSString *)changedTaskNotes changedPriority:(OMMTaskPriority)changedPriority changedRemainder:(NSNumber *)changedRemainder;
- (void)deleteTaskByID:(NSNumber *)taskID;
- (void)closeTaskByID:(NSNumber *)taskID;

- (NSArray *)getAllTaskArray;

@end
