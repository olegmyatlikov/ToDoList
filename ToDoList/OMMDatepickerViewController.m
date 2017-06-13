//
//  OMMDatepickerViewController.m
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMDatepickerViewController.h"
#import "NSDate+OMMDateConverter.h"

@interface OMMDatepickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;

@end

@implementation OMMDatepickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES];
    self.selectedDateLabel.text = [self.startDate convertDateToString];
    
    self.navigationItem.title = @"Chose date";
    UIBarButtonItem *saveDateButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveDateButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self.datePicker addTarget:self action:@selector(datePicherValueChanged) forControlEvents:UIControlEventValueChanged];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    self.datePicker.locale = locale;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.minimumDate = [NSDate date];
    [self.datePicker setDate:self.startDate];
}

- (void)datePicherValueChanged {
    self.selectedDateLabel.text = [self.datePicker.date convertDateToString];
}

- (IBAction)setDateButton:(UIButton *)sender {
    [self.delegate setDateFromDatePickerVC:self date:self.selectedDateLabel.text];
    [self.delegate showTabBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonPressed {
    [self.delegate setDateFromDatePickerVC:self date:self.selectedDateLabel.text];
    [self.delegate showTabBar];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
