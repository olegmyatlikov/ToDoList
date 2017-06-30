//
//  OMMTask.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const OMMTaskPriorityString[];

@interface OMMTask : NSObject

typedef NS_ENUM(NSInteger, OMMTaskPriority) {
    OMMTaskPriorityNone = 0,
    OMMTaskPriorityLow = 1,
    OMMTaskPriorityMedium = 2,
    OMMTaskPriorityHigh = 3,
};

@property (nonatomic, assign, readonly) NSInteger taskID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *finishDate;
@property (nonatomic, assign) OMMTaskPriority priority;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, assign, getter=isClosed) BOOL closed;
@property (nonatomic, assign) BOOL enableRemainder;

@end
