//
//  OMMTasksGroup.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMMTasksGroup : NSObject

@property (nonatomic, assign) NSInteger groupID;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSDate *groupStartDate;
@property (nonatomic, strong) NSMutableArray *tasksArray;

@end
