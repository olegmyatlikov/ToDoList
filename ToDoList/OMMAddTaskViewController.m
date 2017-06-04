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
#import "OMMTask.h"


@interface OMMAddTaskViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dateUIButton;
@property (weak, nonatomic) IBOutlet UITextField *taskNameUITextField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesUITextView;

@end


@implementation OMMAddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(addTask)];
    NSString *todayDateString = [[NSDate date] convertDateToString];
    [self.dateUIButton setTitle:todayDateString forState:UIControlStateNormal];
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
    OMMTask *task = [OMMTaskService createTaskWithName:self.taskNameUITextField.text finishDate:[NSDate convertStringToDate:self.dateUIButton.titleLabel.text] notes:self.taskNotesUITextView.text];
    [self.delegate addNewTaskInTaskArray:task];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end


