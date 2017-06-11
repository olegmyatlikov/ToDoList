//
//  OMMTask.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMMTask : NSObject

@property (nonatomic, assign) NSInteger taskID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *finishDate;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, assign, getter=isClosed) BOOL closed;
@property (nonatomic, assign) BOOL enableRemainder;

@end
