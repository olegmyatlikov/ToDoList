//
//  OMMTask.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class TasksGroup;

@interface OMMTask : NSManagedObject

typedef NS_ENUM(NSInteger, OMMTaskPriority) {
    OMMTaskPriorityNone = 0,
    OMMTaskPriorityLow = 1,
    OMMTaskPriorityMedium = 2,
    OMMTaskPriorityHigh = 3,
};

@property (nullable, nonatomic, copy) NSNumber *taskID;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *startDate;
@property (nullable, nonatomic, copy) NSDate *finishDate;
@property (nullable, nonatomic, copy) NSString *note;
@property (nullable, nonatomic, copy) NSNumber *priority;
@property (nullable, nonatomic, copy) NSNumber *closed;
@property (nullable, nonatomic, copy) NSNumber *enableRemainder;
@property (nullable, nonatomic, retain) TasksGroup *tasksGroup;

+ (NSFetchRequest<OMMTask *> *_Nonnull)fetchRequest;
+ (NSString *_Nonnull)taskPriorityToString:(OMMTaskPriority)taskPriority;

@end
