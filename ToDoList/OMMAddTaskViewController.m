//
//  OMMAddTaskViewController.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMAddTaskViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "OMMTaskService.h"


@interface OMMAddTaskViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dateUIButton;
@property (weak, nonatomic) IBOutlet UITextField *taskNameUITextField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesUITextView;

@end


@implementation OMMAddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.editTask) {
        [self.dateUIButton setTitle:[self.editTask.finishDate convertDateToString] forState:UIControlStateNormal];
        self.taskNameUITextField.text = self.editTask.name;
        self.taskNotesUITextView.text = self.editTask.note;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(saveChanges)];
    } else {
        [self.dateUIButton setTitle:[[NSDate date] convertDateToString] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStyleDone target:self action:@selector(addTask)];
    }
}


- (IBAction)dateButtonPressed:(UIButton *)sender {
    OMMDatepickerViewController *datePickerViewController = [[OMMDatepickerViewController alloc] initWithNibName:@"OMMDatepickerViewController" bundle:nil];
    datePickerViewController.delegate = self;
    datePickerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    datePickerViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:datePickerViewController animated:YES completion:nil];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)sendDateToTaskViewController:(NSString *)textForButtonTitle {
    [self.dateUIButton setTitle:textForButtonTitle forState:UIControlStateNormal];
}

- (void)showTabBar {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)addTask {
    if (self.taskNameUITextField.text.length > 0) {
        OMMTask *task = [OMMTaskService createTaskWithName:self.taskNameUITextField.text finishDate:[NSDate convertStringToDate:self.dateUIButton.titleLabel.text] notes:self.taskNotesUITextView.text];
        [self.delegate addNewTaskInTaskArray:task];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        UIAlertView *emptyNameAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please, enter name of task" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [emptyNameAlert show];
    }
}

- (void)saveChanges {
    self.editTask.name = self.taskNameUITextField.text;
    self.editTask.finishDate = [NSDate convertStringToDate:self.dateUIButton.titleLabel.text];
    self.editTask.note = self.taskNotesUITextView.text;
    [self.delegate saveChangesInTaskArray:self.editTask];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end


