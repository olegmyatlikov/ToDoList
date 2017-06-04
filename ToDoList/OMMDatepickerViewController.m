//
//  OMMDatepickerViewController.m
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMDatepickerViewController.h"
#import "OMMAddTaskViewController.h"

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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-YYYY"];
    [self.delegate sendDateToTaskViewController:[formatter stringFromDate:self.datePicker.date]];
    [self.delegate showTabBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
