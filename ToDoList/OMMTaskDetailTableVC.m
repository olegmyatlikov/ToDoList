//
//  OMMTaskDetailTableVC.m
//  ToDoList
//
//  Created by Admin on 12.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskDetailTableVC.h"
#import "UIView+OMMHeaderInSection.h"
#import "AppDelegate.h"

@interface OMMTaskDetailTableVC ()

@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *remaindSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;

@property (weak, nonatomic) IBOutlet UITableViewCell *startDateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *priorityCell;

@property (assign, nonatomic) BOOL enableRemainder;
@property (assign, nonatomic) OMMTaskPriority priority;
@property (strong, nonatomic) UIBarButtonItem *saveTaskButton;

@end


@implementation OMMTaskDetailTableVC

#pragma mark - localization 

static NSString *OMMTaskDetailVCSetDateLabelText;
static NSString *OMMTaskDetailVCNoneLabelText;
static NSString *OMMTaskDetailVCSaveButtonTitle;
static NSString *OMMTaskDetailVCCancelButtonTitle;
static NSString *OMMTaskDetailVCEmptyRequaredFieldsAlertText;
static NSString *OMMTaskDetailVCOkWarningAlertActionTitle;
static NSString *OMMTaskDetailVCSelectPriorityAlertTitle;
static NSString *OMMTaskDetailVCOkAlertPriorityActionTitle;

+ (void)initialize {
    OMMTaskDetailVCSetDateLabelText = NSLocalizedString(@"cell_label.text-SET_DATE", nil);
    OMMTaskDetailVCNoneLabelText = NSLocalizedString(@"cell_label.text-NONE", nil);
    OMMTaskDetailVCSaveButtonTitle = NSLocalizedString(@"navigation_item_button.title-SAVE", nil);
    OMMTaskDetailVCCancelButtonTitle = NSLocalizedString(@"navigation_item_button.title-CANCEL", nil);
    OMMTaskDetailVCEmptyRequaredFieldsAlertText = NSLocalizedString(@"warning_alert.title-PLEASE_ADD_TASKS_NAME_AND_CHOSE_REMAIDER_DATE", nil);
    OMMTaskDetailVCOkWarningAlertActionTitle = NSLocalizedString(@"warning_alert_action.title-OK", nil);
    OMMTaskDetailVCSelectPriorityAlertTitle = NSLocalizedString(@"priority_alert_action.title-SELECT_PRIORITY", nil);
    OMMTaskDetailVCOkAlertPriorityActionTitle = NSLocalizedString(@"priority_alert_action.title-CANCEL", nil);
}

#pragma mark - constants 

//NSString * const OMMTaskDetailTaskWasModifyNotification = @"TaskListWasModify";
static NSString * const OMMTaskDetailVCTextLabelProperty = @"text";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.task) {
        self.taskNameTextField.text = self.task.name;
        self.startDateLabel.text = [self.task.startDate convertDateToLongDateString];
        [self.remaindSwitcher setOn:self.task.enableRemainder];
        self.priorityLabel.text = [OMMTask taskPriorityToString:self.task.priority];
        self.taskNotesTextView.text = self.task.note;
    } else {
        self.startDateLabel.text = OMMTaskDetailVCSetDateLabelText;
        self.priorityLabel.text = OMMTaskDetailVCNoneLabelText;
        self.priority = OMMTaskPriorityNone;
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
        
        if (self.task) { // save all changes 
            [[OMMTaskService sharedInstance] updateTask:self.task name:self.taskNameTextField.text
                      taskStartDate:[NSDate convertStringToDate:self.startDateLabel.text]
                          taskNotes:self.taskNotesTextView.text
                       taskPriority:self.priority
                    enableRemainder:[self.remaindSwitcher isOn]];
        } else { // add new task
            NSManagedObjectContext *context = nil;
            id delegate = [[UIApplication sharedApplication] delegate];
            context = [delegate managedObjectContext];
            
            OMMTask *newTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
            
            
            newTask.name = self.taskNameTextField.text;
            newTask.startDate = [NSDate convertStringToDate:self.startDateLabel.text];
            newTask.note = self.taskNotesTextView.text;
            newTask.priority = [NSNumber numberWithInteger:self.priority];
            newTask.enableRemainder = [NSNumber numberWithBool:[self.remaindSwitcher isOn]];
            newTask.closed = [NSNumber numberWithBool:NO];
            [delegate saveContext];

        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
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
    
    UIAlertAction *nonePriority = [UIAlertAction actionWithTitle:[OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityNone]] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = [OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityNone]];
        self.priority = OMMTaskPriorityNone;
    }];
    UIAlertAction *lowPriority = [UIAlertAction actionWithTitle:[OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityLow]] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = [OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityLow]] ;
        self.priority = OMMTaskPriorityLow;
    }];
    UIAlertAction *mediumPriority = [UIAlertAction actionWithTitle:[OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityMedium]] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = [OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityMedium]];
        self.priority = OMMTaskPriorityMedium;
    }];
    UIAlertAction *highPriority = [UIAlertAction actionWithTitle:[OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityHigh]] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.priorityLabel.text = [OMMTask taskPriorityToString:[NSNumber numberWithInt:OMMTaskPriorityHigh]];
        self.priority = OMMTaskPriorityHigh;
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

- (void)viewControllerDidDoneAction:(OMMDatepickerViewController *)sender {
    self.startDateLabel.text = sender.selectedDateLabel.text;
    [self.tabBarController.tabBar setHidden:NO];
    [sender.navigationController popViewControllerAnimated:YES];
}

- (void)viewControllerDidCancelAction:(OMMDatepickerViewController *)sender {
    [self.tabBarController.tabBar setHidden:NO];
    [sender.navigationController popViewControllerAnimated:YES];
}


// removeObservers
- (void)dealloc {
    [self.priorityLabel removeObserver:self forKeyPath:OMMTaskDetailVCTextLabelProperty];
    [self.startDateLabel removeObserver:self forKeyPath:OMMTaskDetailVCTextLabelProperty];
    
}


@end
