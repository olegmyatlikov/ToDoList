//
//  OMMSearchTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 15/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMSearchTableViewController.h"
#import "OMMTaskService.h"
#import "OMMTasksGroup.h"
#import "OMMTask.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMSearchTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) OMMTaskService *taskService;
@property (nonatomic, strong) NSArray *resultTaskArray;
@property (nonatomic, strong) NSArray *tasksArray;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSPredicate *activeTasksPredicate;
@property (nonatomic, strong) NSPredicate *closedTasksPredicate;

@end

@implementation OMMSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    self.activeTasksPredicate = [NSPredicate predicateWithFormat:@"closed = 0"];
    self.closedTasksPredicate = [NSPredicate predicateWithFormat:@"closed = 1"];
    
    self.tasksArray = [self.taskService.allTasksArray filteredArrayUsingPredicate:self.activeTasksPredicate];
    self.resultTaskArray = self.tasksArray;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[@"Active tasks", @"Completed"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES; // hide searchController if present another viewController and do visible if go back
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    self.tasksArray = [self.taskService.allTasksArray filteredArrayUsingPredicate:self.activeTasksPredicate];
    self.resultTaskArray = self.tasksArray;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.resultTaskArray.count > 0) {
        self.tableView.backgroundView = nil;
        
        return 1;
    } else {
        UILabel *noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        noResultLabel.text = @"No Result";
        [noResultLabel setFont:[UIFont systemFontOfSize:24 weight:normal]];
        noResultLabel.textColor = [UIColor lightGrayColor];
        noResultLabel.textAlignment = NSTextAlignmentCenter;
        self.tableView.backgroundView = noResultLabel;
        
        return 0;
    }
}

// select scope another button

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if (selectedScope == 0) {
        self.tasksArray = [self.taskService.allTasksArray filteredArrayUsingPredicate:self.activeTasksPredicate];
    } else {
        self.tasksArray = [self.taskService.allTasksArray filteredArrayUsingPredicate:self.closedTasksPredicate];
    }
    self.resultTaskArray = self.tasksArray;
    [self.tableView reloadData];
    self.searchController.searchBar.text = @"";
}


//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
//    UISegmentedControl *segmentControlButtons = [[UISegmentedControl alloc] initWithItems:@[@"Active", @"Complited"]];
//    [segmentControlButtons setWidth:130.f forSegmentAtIndex:0];
//    [segmentControlButtons setWidth:130.f forSegmentAtIndex:1];
//    segmentControlButtons.center = headerView.center;
//    segmentControlButtons.selectedSegmentIndex = 0;
//    [headerView addSubview:segmentControlButtons];
//    
//    return headerView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 50.f;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @" ";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultTaskArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OMMTaskCell" bundle:nil] forCellReuseIdentifier:@"OMMTaskCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    }
    
    OMMTask *task = [self.resultTaskArray objectAtIndex:indexPath.row];
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToString];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}


#pragma mark - search and update result

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultTaskArray = self.tasksArray;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    if (searchText.length != 0) {
        self.resultTaskArray = [self.tasksArray filteredArrayUsingPredicate:predicate];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTask *task = [self.resultTaskArray objectAtIndex:indexPath.row];
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    taskDetails.task = task;
    [self.navigationController pushViewController:taskDetails animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.resultTaskArray = [self.taskService.allTasksArray mutableCopy];
}


@end
