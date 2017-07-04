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

@end


@implementation OMMDatepickerViewController

#pragma mark - localization

static NSString *OMMDatepickerChoseDateTitle;
static NSString *OMMDatepickerDoneButton;
static NSString *OMMDatepickerCancelButton;
static NSString *OMMDatepickerLocaleIdentifair;

+ (void)initialize {
    OMMDatepickerChoseDateTitle = NSLocalizedString(@"navigation_item.title-CHOSE_DATE", nil);
    OMMDatepickerDoneButton = NSLocalizedString(@"navigation_item_button.title-DONE", nil);
    OMMDatepickerCancelButton = NSLocalizedString(@"navigation_item_button.title-CANCEL", nil);
    OMMDatepickerLocaleIdentifair = NSLocalizedString(@"datepicker_locale.identifair", nil);
}


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES];
    if (self.startDate) {
        [self.datePicker setDate:self.startDate];
        self.selectedDateLabel.text = [self.startDate convertDateToLongDateString];
    } else {
        [self.datePicker setDate:[NSDate date]];
        self.selectedDateLabel.text = [[NSDate date] convertDateToLongDateString];
    }
    
    self.navigationItem.title = OMMDatepickerChoseDateTitle;
    UIBarButtonItem *saveDateButton = [[UIBarButtonItem alloc] initWithTitle:OMMDatepickerDoneButton style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:OMMDatepickerCancelButton style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveDateButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self.datePicker addTarget:self action:@selector(datePicherValueChanged) forControlEvents:UIControlEventValueChanged];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:OMMDatepickerLocaleIdentifair];
    self.datePicker.locale = locale;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.minimumDate = [NSDate date];
}


#pragma mark - methods

- (void)datePicherValueChanged {
    self.selectedDateLabel.text = [self.datePicker.date convertDateToLongDateString];
}

- (void)doneButtonPressed {
    [self.delegate viewControllerDidDoneAction:self];
}

- (void)cancelButtonPressed {
    [self.delegate viewControllerDidCancelAction:self];
}

@end
