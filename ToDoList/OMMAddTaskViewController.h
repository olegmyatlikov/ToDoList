//
//  OMMAddTaskViewController.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMDatepickerViewController.h"

@protocol addNewTaskDelegate <NSObject>

- (void)addNewTaskInTaskArray:(id)task;

@end


@interface OMMAddTaskViewController : UIViewController <DateSetDelegate>

@property (weak, nonatomic) id <addNewTaskDelegate> delegate;

@end

