//
//  OMMDetailsOfTaskViewController.h
//  ToDoList
//
//  Created by Oleg Myatlikov on 05/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMTask.h"

@protocol addNewTaskDelegate;

@interface OMMDetailsOfTaskViewController : UIViewController

@property (strong, nonatomic) OMMTask *task;
@property (weak, nonatomic) id <addNewTaskDelegate> delegate;

@end
