//
//  OMMTaskDetailTableVC.m
//  ToDoList
//
//  Created by Admin on 12.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTaskDetailTableVC.h"

@interface OMMTaskDetailTableVC ()

@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *remaindSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;


@property (weak, nonatomic) IBOutlet UITableViewCell *startDateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *priorityCell;

@end


@implementation OMMTaskDetailTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskNameTextField.text = self.task.name;
    self.startDateLabel.text = [self.task.startDate convertDateToString];
    [self.remaindSwitcher setOn:self.task.enableRemainder];
    self.priorityLabel.text = [self.task taskPriotityToString:self.task.priority];
    self.taskNotesTextView.text = self.task.note;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50.0f)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, tableView.bounds.size.width, 20)];
    
    headerView.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.text = sectionTitle;
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.startDateCell) {
        
    }
    if (selectedCell == self.priorityCell) {
        UIAlertController *priorityAlert = [UIAlertController alertControllerWithTitle:@"Select Priority" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *nonePriority = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ }];
        UIAlertAction *lowPriority = [UIAlertAction actionWithTitle:@"Low" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ }];
        UIAlertAction *midlePriority = [UIAlertAction actionWithTitle:@"Midle" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ }];
        UIAlertAction *highPriority = [UIAlertAction actionWithTitle:@"High" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){ }];
        
        [priorityAlert addAction:nonePriority];
        [priorityAlert addAction:lowPriority];
        [priorityAlert addAction:midlePriority];
        [priorityAlert addAction:highPriority];
        [priorityAlert addAction:cancel];
        
        [self presentViewController:priorityAlert animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
