//
//  OMMTaskList.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMMTaskList : NSObject

@property (nonatomic, assign) NSInteger taskListID;
@property (nonatomic, strong) NSString *taskListName;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSMutableArray *tasksArray;

@end
