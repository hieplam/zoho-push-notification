#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#ifdef FB_SONARKIT_ENABLED
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>

static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef FB_SONARKIT_ENABLED
  InitializeFlipper(application);
#endif

  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"zohotest"
                                            initialProperties:nil];

  if (@available(iOS 13.0, *)) {
      rootView.backgroundColor = [UIColor systemBackgroundColor];
  } else {
      rootView.backgroundColor = [UIColor whiteColor];
  }

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"----------------device token %@", [deviceToken description]);
  const unsigned *tokenBytes = [deviceToken bytes];
  NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                 ntohl(tokenBytes[0]), ntohl(tokenBytes[1]),
                                 ntohl(tokenBytes[2]), ntohl(tokenBytes[3]),
                                 ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                                 ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
  
  NSLog(@"hex token ---------------------------------- %@", [hexToken description]);
  [RNZohoDeskPortalSDK setDeviceIDForZDPortal:hexToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  NSString *str = [NSString stringWithFormat:@"Error: %@", err];
  NSLog(@"-------------Error Failed Register remote noti:%@", str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [RNZohoDeskPortalSDK processRemoteNotification:userInfo];
  if (application.applicationState == UIApplicationStateActive)
  {
    NSLog(@"-------app was already in the foreground");
  }

  else
  {
    NSLog(@"--------app was just brought from background to foreground");
  }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler {

  if (application.applicationState == UIApplicationStateInactive)
  {
    NSLog(
        @"-----Inactive - the user has tapped in the notification when app was "
        @"closed or in background");
    // do some tasks
    [RNZohoDeskPortalSDK processRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
  }
  else if (application.applicationState == UIApplicationStateBackground)
  {
    NSLog(@"-----application Background - notification has arrived when app "
          @"was in "
          @"background");
    NSString *contentAvailable = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"content-available"]];

    if ([contentAvailable isEqualToString:@"1"])
    {
      // do tasks
      [RNZohoDeskPortalSDK processRemoteNotification:userInfo];
      NSLog(@"-----content-available is equal to 1");
      completionHandler(UIBackgroundFetchResultNewData);
    }
  }
  else
  {
    NSLog(@"-------application Active - notication has arrived while app was "
          @"opened");
    // Show an in-app banner
    // do tasks
    [RNZohoDeskPortalSDK processRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
  }
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
  // register to receive notifications
  [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
    handleActionWithIdentifier:(NSString *)identifier
         forRemoteNotification:(NSDictionary *)userInfo
             completionHandler:(void (^)())completionHandler {
  // handle the actions
  if ([identifier isEqualToString:@"declineAction"]) {
  } else if ([identifier isEqualToString:@"answerAction"]) {
  }
}
#endif

@end
