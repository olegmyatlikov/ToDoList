//
//  OMMTaskDetailViewController.m
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskDetailViewController.h"

@interface OMMTaskDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *taskName;

@end

@implementation OMMTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.taskName.text = self.task.name;
    NSLog(@"%@", self.task.name);
}


@end
