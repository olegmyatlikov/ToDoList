//
//  OMMDatepickerViewController.m
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMDatepickerViewController.h"
#import "OMMAddTaskViewController.h"
#import "NSDate+OMMDateConverter.h"

@interface OMMDatepickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation OMMDatepickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.minimumDate = [NSDate date];
}

- (IBAction)setDateButton:(UIButton *)sender {
    [self.delegate sendDateToTaskViewController:[self.datePicker.date convertDateToString]];
    [self.delegate showTabBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
