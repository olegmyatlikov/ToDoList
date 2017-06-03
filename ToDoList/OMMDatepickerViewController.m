//
//  OMMDatepickerViewController.m
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMDatepickerViewController.h"

@interface OMMDatepickerViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation OMMDatepickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate date];
}

- (IBAction)setDateButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.selectedDate = self.datePicker.date;
}

@end
