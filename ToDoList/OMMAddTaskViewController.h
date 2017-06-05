//
//  OMMAddTaskViewController.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMDatepickerViewController.h"
#import "OMMTask.h"

@protocol addNewTaskDelegate <NSObject>

- (void)addNewTaskInTaskArray:(OMMTask *)task;
- (void)saveChangesInTaskArray:(OMMTask *)editingTask;

@end


@interface OMMAddTaskViewController : UIViewController <DateSetDelegate>

@property (weak, nonatomic) id <addNewTaskDelegate> delegate;
@property (strong, nonatomic) OMMTask *editTask;

@end

