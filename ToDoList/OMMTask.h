//
//  OMMTask.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMMTask : NSObject

typedef enum TaskPriority{
    none,
    low,
    medium,
    high
} TaskPriority;

@property (nonatomic, assign) NSInteger taskID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *finishDate;
@property (nonatomic, assign) TaskPriority priority;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, assign, getter=isClosed) BOOL closed;
@property (nonatomic, assign) BOOL enableRemainder;

- (NSString*)taskPriotityToString:(TaskPriority)taskPriority;

@end
