//
//  AppDelegate.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "AppDelegate.h"
#import "OMMTaskService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // accept to recive noyifications || use sound || use badge on icon
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationType = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:userNotificationType categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    }
    
    // load data from file
    NSString *dataFilePath = [OMMTaskService sharedInstance].appDataFilePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath]) {
        OMMTaskService *taskServiceFromFile = [NSKeyedUnarchiver unarchiveObjectWithFile:dataFilePath];
        [[OMMTaskService sharedInstance] updateDataFromFile:taskServiceFromFile];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
