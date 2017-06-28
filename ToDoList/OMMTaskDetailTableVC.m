//
//  OMMTaskDetailTableVC.m
//  ToDoList
//
//  Created by Admin on 12.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskDetailTableVC.h"
#import "UIView+OMMHeaderInSection.h"

@interface OMMTaskDetailTableVC ()

@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *remaindSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;

@property (weak, nonatomic) IBOutlet UITableViewCell *startDateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *priorityCell;

@property (assign, nonatomic) BOOL enableRemainder;
@property (assign, nonatomic) TaskPriority priority;
@property (strong, nonatomic) UIBarButtonItem *saveTaskButton;

@end


@implementation OMMTaskDetailTableVC


#pragma mark - constants 

static NSString * const OMMTaskDetailVCSetDateLabelText = @"set date";
static NSString * const OMMTaskDetailVCNoneLabelText = @"none";
static NSString * const OMMTaskDetailVCSaveButtonTitle = @"Save";
static NSString * const OMMTaskDetailVCCancelButtonTitle = @"Cancel";
static NSString * const OMMTaskDetailVCTextLabelProperty = @"text";
static NSString * const OMMTaskDetailVCEmptyRequaredFieldsAlertText = @"Please add tasks name and chose remainder date!";
static NSString * const OMMTaskDetailVCOkWarningAlertActionTitle = @"Ok";
static NSString * const OMMTaskDetailVCSelectPriorityAlertTitle = @"Select Priority";
static NSString * const OMMTaskDetailVCOkAlertPriorityActionTitle = @"Cancel";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.task) {
        self.taskNameTextField.text = self.task.name;
        self.startDateLabel.text = [self.task.startDate convertDateToString];
        [self.remaindSwitcher setOn:self.task.enableRemainder];
        self.priorityLabel.text = [self.task taskPriotityToString:self.task.priority];
        self.taskNotesTextView.text = self.task.note;
    } else {
        self.startDateLabel.text = OMMTaskDetailVCSetDateLabelText;
        self.priorityLabel.text = OMMTaskDetailVCNoneLabelText;
        self.priority = none;
    }
    
    self.saveTaskButton = [[UIBarButtonItem alloc] initWithTitle:OMMTaskDetailVCSaveButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(saveTaskButtonPressed)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:OMMTaskDetailVCCancelButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.saveTaskButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self disableSaveButton];
    
    // detect changes
    [self.taskNameTextField addTarget:self action:@selector(enableSaveButton) forControlEvents:UIControlEventEditingChanged];
    [self.remaindSwitcher addTarget:self action:@selector(enableSaveButton) forControlEvents:UIControlEventValueChanged];
    self.taskNotesTextView.delegate = self;
    [self.startDateLabel addObserver:self forKeyPath:OMMTaskDetailVCTextLabelProperty options:NSKeyValueObservingOptionNew context:nil];
    [self.priorityLabel addObserver:self forKeyPath:OMMTaskDetailVCTextLabelProperty options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.taskNameTextField becomeFirstResponder];
}


#pragma mark - methods

- (void)saveTaskButtonPressed {
    // alert if taskName field empty or didn't chose a start date
    if ([self.taskNameTextField.text length] < 1 || [self.startDateLabel.text isEqualToString:OMMTaskDetailVCSetDateLabelText]) {
        [self openEmptyValueAlert];
        
    } else {
        if (self.task) { // save all changes (use the memory)
            OMMTask *editTask = self.task;
            editTask.name = self.taskNameTextField.text;
            editTask.startDate = [NSDate convertStringToDate:self.startDateLabel.text];
            editTask.note = self.taskNotesTextView.text;
            editTask.priority = self.priority;
            editTask.enableRemainder = [self.remaindSwitcher isOn];
        } else {
            OMMTaskService *taskService = [OMMTaskService sharedInstance];
            OMMTask *newTask = [taskService createTaskWithName:self.taskNameTextField.text
                                                        startDate:[NSDate convertStringToDate:self.startDateLabel.text]
                                                            notes:self.taskNotesTextView.text
                                                         priority:self.priority
                                                  enableRemainder:[self.remaindSwitcher isOn]];
            [taskService addTask:newTask toTaskGroup:self.taskGroup]; // task service save task and push notification to all tabs
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)enableSaveButton {
    self.saveTaskButton.enabled = YES;
}

- (void)disableSaveButton {
    self.saveTaskButton.enabled = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self enableSaveButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self enableSaveButton];
}

#pragma mark - Alerts

// warning alert if requared fields is empty
- (void)openEmptyValueAlert {
    UIAlertController *emptyValueAlert = [UIAlertController alertControllerWithTitle:OMMTaskDetailVCEmptyRequaredFieldsAlertText message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:OMMTaskDetailVCOkWarningAlertActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    [emptyValueAlert addAction:okButton];
    [self presentViewController:emptyValueAlert animated:YES completion:nil];
}


// chose priority alertActionSheet
- (void)openPriorityAlertActionSheet {
    UIAlertController *priorityAlert = [UIAlertController alertControllerWithTitle:OMMTaskDetailVCSelectPriorityAlertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *nonePriority = [UIAlertAction actionWithTitle:OMMTaskPriorityNone style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = OMMTaskPriorityLow;
        self.priority = none;
    }];
    UIAlertAction *lowPriority = [UIAlertAction actionWithTitle:OMMTaskPriorityLow style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = OMMTaskPriorityLow;
        self.priority = low;
    }];
    UIAlertAction *mediumPriority = [UIAlertAction actionWithTitle:OMMTaskPriorityMedium style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = OMMTaskPriorityMedium;
        self.priority = medium;
    }];
    UIAlertAction *highPriority = [UIAlertAction actionWithTitle:OMMTaskPriorityHigh style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = OMMTaskPriorityHigh;
        self.priority = high;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:OMMTaskDetailVCOkAlertPriorityActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){ }];
    
    [priorityAlert addAction:nonePriority];
    [priorityAlert addAction:lowPriority];
    [priorityAlert addAction:mediumPriority];
    [priorityAlert addAction:highPriority];
    [priorityAlert addAction:cancel];
    
    [self presentViewController:priorityAlert animated:YES completion:nil];
}


#pragma mark - tableView methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return [UIView createViewForHeaderInSection:tableView withTitle:sectionTitle];
}

#pragma mark - did selec the row

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // push to datePickerVC
    if (selectedCell == self.startDateCell) {
        OMMDatepickerViewController *datepickerVC = [[OMMDatepickerViewController alloc] init];
        datepickerVC.startDate = [NSDate convertStringToDate:self.startDateLabel.text];
        datepickerVC.delegate = self;
        [self.navigationController pushViewController:datepickerVC animated:YES];
    }
    
    // alert actionSheet for chose priority
    if (selectedCell == self.priorityCell) {
        [self openPriorityAlertActionSheet];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - protocol methods

- (void)setDateFromDatePickerVC:(OMMDatepickerViewController *)datePickerVC date:(NSString *)date {
    self.startDateLabel.text = date;
}

- (void)showTabBar {
    [self.tabBarController.tabBar setHidden:NO];
}


// removeObservers
- (void)dealloc {
    [self.priorityLabel removeObserver:self forKeyPath:OMMTaskDetailVCTextLabelProperty];
    [self.startDateLabel removeObserver:self forKeyPath:OMMTaskDetailVCTextLabelProperty];
    
}


@end
