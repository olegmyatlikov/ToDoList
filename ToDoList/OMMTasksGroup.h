//
//  OMMTasksGroup.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OMMTask;


@interface OMMTasksGroup : NSManagedObject

+ (NSFetchRequest<OMMTasksGroup *> *_Nonnull)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *groupID;
@property (nullable, nonatomic, copy) NSString *groupName;
@property (nullable, nonatomic, copy) NSDate *groupStartDate;
@property (nullable, nonatomic, retain) NSSet<OMMTask *> *tasks;
@property (nonatomic, retain) NSArray *tasksArray; // DELETE!!!

@end

@interface OMMTasksGroup (CoreDataGeneratedAccessors)

- (void)addTasksObject:(OMMTask *_Nonnull)value;
- (void)removeTasksObject:(OMMTask *_Nonnull)value;
- (void)addTasks:(NSSet<OMMTask *> *_Nonnull)values;
- (void)removeTasks:(NSSet<OMMTask *> *_Nonnull)values;

@end
