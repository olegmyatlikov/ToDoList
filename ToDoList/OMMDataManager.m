//
//  OMMDataManager.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 7/19/17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMDataManager.h"
#import "NSDate+OMMDateConverter.h"
#import <UIKit/UIKit.h> // for UILocalNotification

@implementation OMMDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString *OMMTaskServiceNameTaskGroupInbox;
NSString * const OMMTaskServiceTaskWasModifyNotification = @"TaskListWasModify";

+ (void)initialize {
    OMMTaskServiceNameTaskGroupInbox = NSLocalizedString(@"inbox_group_property_name-INBOX", nil);
}


#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self && self.inboxTasksGroup == nil) {
        
        if (![self getTasksGroupByID:@1]) { // if inbox doesh't exist, create it
            OMMTasksGroup *inboxTasksGroup = [self createTasksGroupWithName:OMMTaskServiceNameTaskGroupInbox]; // localize
            inboxTasksGroup.groupID = @1;
        }
        _inboxTasksGroup = [self getTasksGroupByID:@1];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static OMMDataManager *shared;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}


#pragma mark - manage task

- (void)createTaskWithName:(NSString *)name startDate:(NSDate *)date notes:(NSString *)notes priority:(OMMTaskPriority)priority enableRemainder:(BOOL)remainder inTasksGroup:(OMMTasksGroup *)taskGroup {
    OMMTask *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    task.taskID = [NSNumber numberWithInteger:arc4random_uniform(10000)];
    task.name = name;
    task.startDate = date;
    task.note = notes;
    task.closed = [NSNumber numberWithBool:NO];
    task.priority = [NSNumber numberWithInteger:priority];
    task.enableRemainder = [NSNumber numberWithBool:remainder];
    
    if (taskGroup) {
        task.tasksGroup = taskGroup;
    } else {
        task.tasksGroup = self.inboxTasksGroup;
    }
    //[self.inboxTasksGroup addTasksObject:task];
    
    if ([task.enableRemainder boolValue]) {
        [self addLocalNotificationForTask:task];
    }
    [self saveContext];
}

- (void)updateTaskWichID:(NSNumber *)taskID  changedName:(NSString *)changedName changedDate:(NSDate *)changedDate changedTaskNotes:(NSString *)changedTaskNotes changedPriority:(OMMTaskPriority)changedPriority changedRemainder:(NSNumber *)changedRemainder {
    OMMTask *task = [self getTaskByID:taskID];
    
    task.name = changedName;
    task.startDate = changedDate;
    task.note = changedTaskNotes;
    task.priority = [NSNumber numberWithInteger:changedPriority];
    task.enableRemainder = changedRemainder;

    if ([task.enableRemainder boolValue]) { // if remainder on - close old notification and open new
        [self cancelLocalNotificationForTask:task];
        [self addLocalNotificationForTask:task];
    } else {
        [self cancelLocalNotificationForTask:task];
    }
    [self saveContext];
}

- (void)deleteTaskByID:(NSNumber *)taskID {
    OMMTask *task = [self getTaskByID:taskID];
    [self.managedObjectContext deleteObject:task];
    
    [self cancelLocalNotificationForTask:task]; // delete notification if task was removed
    [self saveContext];
}

- (void)closeTaskByID:(NSNumber *)taskID {
    OMMTask *task = [self getTaskByID:taskID];
    task.closed = [NSNumber numberWithBool:YES];
    
    [self cancelLocalNotificationForTask:task]; // delete notification if task was removed
    [self saveContext];
}

- (OMMTask *)getTaskByID:(NSNumber *)taskID {
    NSFetchRequest *request = [OMMTask fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    return [result firstObject];
}


#pragma mark - manage tasksGroup

- (OMMTasksGroup *)createTasksGroupWithName:(NSString *)name {
    OMMTasksGroup *tasksGroup = [NSEntityDescription insertNewObjectForEntityForName:@"TasksGroup" inManagedObjectContext:self.managedObjectContext];
    tasksGroup.groupID = [NSNumber numberWithInteger:arc4random_uniform(10000)];
    tasksGroup.groupName = name;
    tasksGroup.groupStartDate = [NSDate date];
    [self saveContext];
    
    return tasksGroup;
}

- (void)deleteTasksGroupByID:(NSNumber *)tasksGroupID {
    OMMTasksGroup *tasksGroup = [self getTasksGroupByID:tasksGroupID];
    [self.managedObjectContext deleteObject:tasksGroup];
    [self saveContext];
}

- (void)renameTasksGroupWithID:(NSNumber *)tasksGroupID to:(NSString *)newName {
    OMMTasksGroup *tasksGroup = [self getTasksGroupByID:tasksGroupID];
    tasksGroup.groupName = newName;
    [self saveContext];
}

- (OMMTasksGroup *)getTasksGroupByID:(NSNumber *)tasksGroupID {
    NSFetchRequest *request = [OMMTasksGroup fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"groupID = %@", tasksGroupID];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    return [result firstObject];
}

#pragma mark - get data

- (NSArray *)getAllTaskArray {
    NSFetchRequest *request = [OMMTask fetchRequest];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    request.sortDescriptors = @[nameDescriptor];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    return result;
}

- (NSArray *)getAllTasksGroups { // Whithout inbox
    NSFetchRequest *request = [OMMTasksGroup fetchRequest];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"groupName" ascending:NO];
    request.sortDescriptors = @[nameDescriptor];
    NSMutableArray *result = [[self.managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
    [result removeObject:[self getTasksGroupByID:@1]];
    return result;
}


#pragma mark - manage local notification

- (void)addLocalNotificationForTask:(OMMTask *)task {
    NSDictionary *taskUserInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  task.name, @"notificationInfo",
                                  [task.startDate convertDateToLongDateString], @"notificationDate",
                                  [NSString stringWithFormat:@"%ld", [task.taskID integerValue]], @"taskID",
                                  nil];
    UILocalNotification *notificaion = [[UILocalNotification alloc] init];
    notificaion.userInfo = taskUserInfo;
    notificaion.timeZone = [NSTimeZone defaultTimeZone];
    notificaion.fireDate = task.startDate;
    notificaion.alertTitle = task.name;
    notificaion.alertBody = task.note;
    notificaion.applicationIconBadgeNumber = 1;
    notificaion.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notificaion];
}

- (void)cancelLocalNotificationForTask:(OMMTask *)task {
    NSArray *notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in notificationsArray) {
        NSDictionary *userInfoNotificationDictionary = notification.userInfo;
        if ([[userInfoNotificationDictionary objectForKey:@"taskID"] isEqualToString:[NSString stringWithFormat:@"%ld", [task.taskID integerValue]]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}


#pragma mark - Core Data

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ToDoList.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
