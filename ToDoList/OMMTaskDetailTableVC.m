//
//  OMMTaskDetailTableVC.m
//  ToDoList
//
//  Created by Admin on 12.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskDetailTableVC.h"
#import "OMMTaskService.h"
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.task) {
        self.taskNameTextField.text = self.task.name;
        self.startDateLabel.text = [self.task.startDate convertDateToString];
        [self.remaindSwitcher setOn:self.task.enableRemainder];
        self.priorityLabel.text = [self.task taskPriotityToString:self.task.priority];
        self.taskNotesTextView.text = self.task.note;
    } else {
        self.startDateLabel.text = @"set date";
        self.priorityLabel.text = @"none";
        self.priority = none;
    }
    
    self.saveTaskButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveTaskButtonPressed)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.saveTaskButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self disableSaveButton];
    
    // detect changes
    [self.taskNameTextField addTarget:self action:@selector(enableSaveButton) forControlEvents:UIControlEventEditingChanged];
    [self.remaindSwitcher addTarget:self action:@selector(enableSaveButton) forControlEvents:UIControlEventValueChanged];
    self.taskNotesTextView.delegate = self;
    [self.startDateLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.priorityLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)saveTaskButtonPressed {
    if ([self.taskNameTextField.text length] < 1 || [self.startDateLabel.text isEqualToString:@"set date"]) {
        [self openEmptyValueAlert];
        
    } else {
        
        if (self.task) {
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
            [taskService addTask:newTask];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskWasCreatedOrEdited" object:self userInfo:nil];
        
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

- (void)openEmptyValueAlert {
    UIAlertController *emptyValueAlert = [UIAlertController alertControllerWithTitle:@"Please add tasks name and chose remainder date!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    [emptyValueAlert addAction:okButton];
    [self presentViewController:emptyValueAlert animated:YES completion:nil];
}

- (void)openPriorityAlertActionSheet {
    UIAlertController *priorityAlert = [UIAlertController alertControllerWithTitle:@"Select Priority" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *nonePriority = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = @"none";
        self.priority = none;
    }];
    UIAlertAction *lowPriority = [UIAlertAction actionWithTitle:@"Low" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = @"low";
        self.priority = low;
    }];
    UIAlertAction *mediumPriority = [UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = @"medium";
        self.priority = medium;
    }];
    UIAlertAction *highPriority = [UIAlertAction actionWithTitle:@"High" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = @"high";
        self.priority = high;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){ }];
    
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

#pragma mark - didSelectRowAtIndexPath

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

- (void)dealloc {
    [self.priorityLabel removeObserver:self forKeyPath:@"text"];
    [self.startDateLabel removeObserver:self forKeyPath:@"text"];
    
}


@end
