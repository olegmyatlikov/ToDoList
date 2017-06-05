//
//  OMMDetailsOfTaskViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 05/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMDetailsOfTaskViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "OMMAddTaskViewController.h"

@interface OMMDetailsOfTaskViewController ()
@property (weak, nonatomic) IBOutlet UILabel *startDateUILabel;
@property (weak, nonatomic) IBOutlet UILabel *finishDateUILabel;
@property (weak, nonatomic) IBOutlet UITextView *notesOfTaskUITextView;
@property (weak, nonatomic) IBOutlet UILabel *closeStatus;
@property (weak, nonatomic) IBOutlet UIButton *closeTaskButton;

@end

@implementation OMMDetailsOfTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.task.name;
    self.startDateUILabel.text = [self.task.startDate convertDateToString];
    self.finishDateUILabel.text = [self.task.finishDate convertDateToString];
    self.notesOfTaskUITextView.text = self.task.note;
    
    self.closeStatus.text = self.task.isClosed ? @"The task was closed" : @"Open";
    self.closeTaskButton.hidden = self.task.isClosed ? YES : NO;
    
    if (self.task.closed == NO) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTask)];
    }
}

- (void)editTask {
    OMMAddTaskViewController *editTaskViewController = [[OMMAddTaskViewController alloc] initWithNibName:@"OMMAddTaskViewController" bundle:nil];
    editTaskViewController.editTask = self.task;
    editTaskViewController.delegate = self.delegate;
    [self.navigationController pushViewController:editTaskViewController animated:YES];
    
}

- (IBAction)closeTaskButtonPressed:(UIButton *)sender {
    self.task.closed = YES;
    self.closeTaskButton.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.closeStatus.text = @"The task was closed";
}

@end
