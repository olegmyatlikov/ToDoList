//
//  OMMTaskService.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h> // for UILocalNotification
#import "OMMTaskService.h"
#import "NSDate+OMMDateConverter.h"

@interface OMMTaskService()

@property (nonatomic, strong) NSMutableArray *privateTaskGroupsArray;
@property (nonatomic, strong, readwrite) NSString *appDataFilePath;

@end


@implementation OMMTaskService

static NSString *OMMTaskServiceNameTaskGroupInbox;

+ (void)initialize {
    OMMTaskServiceNameTaskGroupInbox = NSLocalizedString(@"inbox_group_property_name-INBOX", nil);
}

NSString * const OMMTaskServiceTaskWasModifyNotification = @"TaskListWasModify";
static NSString * const OMMTaskServiceDataFilePath = @"appData";


#pragma mark - init service

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _appDataFilePath = [path stringByAppendingPathComponent:OMMTaskServiceDataFilePath];
        
        _inboxTasksGroup = [[OMMTasksGroup alloc] init];
        _inboxTasksGroup.groupName = OMMTaskServiceNameTaskGroupInbox;
        _inboxTasksGroup.tasksArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - coding protocol methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.privateTaskGroupsArray = [aDecoder decodeObjectForKey:@"taskGroupArray"];
    self.inboxTasksGroup = [aDecoder decodeObjectForKey:@"inboxTasksGroup"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.privateTaskGroupsArray forKey:@"taskGroupArray"];
    [aCoder encodeObject:self.inboxTasksGroup forKey:@"inboxTasksGroup"];
}

+ (instancetype)sharedInstance {
    static OMMTaskService *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}


#pragma mark - general methods

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
    [self saveData];
}

- (void)insertTaskGroup:(OMMTasksGroup *)taskGroup atIndex:(NSInteger)index {
    [self.privateTaskGroupsArray insertObject:taskGroup atIndex:index];
    [self saveData];
}

- (void)addTask:(OMMTask *)task {
    [self.inboxTasksGroup.tasksArray addObject:task];
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
    [self saveData];
}

- (void)addTask:(OMMTask *)task toTaskGroup:(OMMTasksGroup *)taskGroup {
    if (!taskGroup.tasksArray) {
        taskGroup.tasksArray = [[NSMutableArray alloc] init];
    }
    if (![taskGroup isEqual:self.inboxTasksGroup]) {
        [self.inboxTasksGroup.tasksArray addObject:task];
    }
    [taskGroup.tasksArray addObject:task];
    
    // add local notification
    if (task.enableRemainder) {
        [self addLocalNotificationForTask:task];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
    [self saveData];
}

- (void)removeTask:(OMMTask *)task {
    [self.inboxTasksGroup.tasksArray removeObject:task];
    for (NSMutableArray *array in [self.tasksGroupsArray valueForKeyPath:@"@unionOfObjects.tasksArray"]) {
        [array removeObject:task];
    }
    
    [self cancelLocalNotificationForTask:task]; // delete notification if task was removed
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
    [self saveData];
}

- (void)closeTask:(OMMTask *)task {
    task.closed = YES;
    task.enableRemainder = NO;
    
    [self cancelLocalNotificationForTask:task]; // delete notification if task was removed
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
    [self saveData];
}

- (void)updateTask:(OMMTask *)task  name:(NSString *)changedName taskStartDate:(NSDate *)changedDate taskNotes:(NSString *)changedTaskNotes taskPriority:(OMMTaskPriority)changedPriority enableRemainder:(BOOL)changedRemainder {
    task.name = changedName;
    task.startDate = changedDate;
    task.note = changedTaskNotes;
    task.priority = changedPriority;
    task.enableRemainder = changedRemainder;
    
    
    if (task.enableRemainder) { // if remainder on - close old notification and open new
        [self cancelLocalNotificationForTask:task];
        [self addLocalNotificationForTask:task];
    } else {
        [self cancelLocalNotificationForTask:task]; 
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
    [self saveData];
}

- (void)removeTasksGroup:(OMMTasksGroup *)tasksGroup {
    for (OMMTask *task in tasksGroup.tasksArray) {
        [self.inboxTasksGroup.tasksArray removeObject:task];
    }
    [self.privateTaskGroupsArray removeObject:tasksGroup];
    [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
    [self saveData];
}

- (void)renameTasksGroup:(OMMTasksGroup *)taskGroup to:(NSString *)newName{
    taskGroup.groupName = newName;
    [self saveData];
}

- (void)updateDataFromFile:(OMMTaskService *)data {
    self.privateTaskGroupsArray = [data.tasksGroupsArray mutableCopy];
    self.inboxTasksGroup = data.inboxTasksGroup;
}

- (void)saveData {
    [NSKeyedArchiver archiveRootObject:self toFile:self.appDataFilePath];
}

- (void)addLocalNotificationForTask:(OMMTask *)task {
    NSDictionary *taskUserInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  task.name, @"notificationInfo",
                                  [task.startDate convertDateToLongDateString], @"notificationDate",
                                  [NSString stringWithFormat:@"%ld", task.taskID], @"taskID",
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
        if ([[userInfoNotificationDictionary objectForKey:@"taskID"] isEqualToString:[NSString stringWithFormat:@"%ld", task.taskID]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
     }
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
