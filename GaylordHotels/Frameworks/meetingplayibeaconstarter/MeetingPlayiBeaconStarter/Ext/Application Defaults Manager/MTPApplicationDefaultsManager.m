//
//  MTPApplicationDefaultsManager.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPApplicationDefaultsManager.h"
#import "AppDelegate.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "SIAlertView.h"
#import "EventKeys.h"
#import "MTPAppSettingsKeys.h"

@implementation MTPApplicationDefaultsManager

+ (instancetype)defaultsManager:(AppDelegate *)appDelegate
{
    return [[MTPApplicationDefaultsManager alloc] initWithAppDelegate:appDelegate];
}

- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate
{
    self = [super init];
    if (self) {
        _appDelegate = appDelegate;
        _eventDefaults = [self retrieveEventDefaults];
        [self setupDefaults:_eventDefaults];
        [self fetchCustomFonts];
        [self setupAppearanceDefaults];
    }
    return self;
}

- (NSDictionary *)retrieveEventDefaults
{
    NSString *defaultLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"applicationLanguage"];
    if (!defaultLanguage)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"English"
                                                  forKey:@"applicationLanguage"];
    }
    
    NSDictionary *languages = nil;
    
    NSData *languagesJSON = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"piic_languages"
                                                                                           ofType:@"json"]];
    if (languagesJSON)
    {
        NSError *jsonParsingError = nil;
        NSArray *languageOptions = [NSArray new];
        id languagesFromJSON =
        [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"piic_languages"
                                                                                                               ofType:@"json"]]
                                        options:NSJSONReadingAllowFragments
                                          error:&jsonParsingError];
        if (jsonParsingError)
        {
            SIAlertView *jsonParsingError = [[SIAlertView alloc] initWithTitle:@"Error Fetching Languages" andMessage:@"We're sorry, but we couldn't retrieve the list of languages"];
            [jsonParsingError addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
            [jsonParsingError show];
            languageOptions = @[@"English"/*,@"Français"*/];
        }
        else
        {
            if ([languagesFromJSON isKindOfClass:[NSDictionary class]])
            {
                languageOptions = [languagesFromJSON objectForKey:@"RECORDS"];
            }
        }
        
        NSMutableArray *languageKeys = [NSMutableArray new];
        //    NSMutableArray *languagePlistFiles = [NSMutableArray new];
        [languageOptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key isEqualToString:@"language"]) {
                        [languageKeys addObject:obj];
                    }
                }];
            }
        }];
        
        languages = [NSDictionary dictionaryWithObjects:@[@"EventDefaults",
                                                                        @"EventDefaults-jp",
                                                                        @"EventDefaults-kr",
                                                                        @"EventDefaults-cn",
                                                                        @"EventDefaults-pr",
                                                                        @"EventDefaults-es",
                                                                        @"EventDefaults-it",
                                                                        @"EventDefaults-pl"]
                                                              forKeys:languageKeys];
    }
    else
    {
        languages = @{@"English": @"EventDefaults"};
    }
    
    NSString *selectedLanguagePropertyList = languages[defaultLanguage];
    if (selectedLanguagePropertyList.length < 1)
    {
        selectedLanguagePropertyList = @"EventDefaults";
    }
    
    NSString *eventsDefaultURL = [[NSBundle mainBundle] pathForResource:selectedLanguagePropertyList
                                                                 ofType:@"plist"];
    
    if (eventsDefaultURL.length > 0) {
        return [NSDictionary dictionaryWithContentsOfFile:eventsDefaultURL];
    } else {
        return nil;
    }
}

- (void)setupDefaults:(NSDictionary *)eventDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:eventDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fetchEventDefaults
{
//    NSFetchRequest *eventDefaults = [self defaultRequestMethod:@"GET" URL:@"http://application.defaults/URL" parameters:nil];
}

- (void)fetchCustomFonts
{
    NSDictionary *customFonts = [self.userDefaults objectForKey:MTP_CustomFonts];
    [customFonts enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        return;
    }];
}

- (void)setupAppearanceDefaults
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    NSString *navigationBarFont = [[self.userDefaults objectForKey:MTP_CustomFonts] objectForKey:@"navigationBarFont"];
    if (navigationBarFont.length > 0)
    {
        [titleTextAttributes addEntriesFromDictionary:@{NSFontAttributeName: [UIFont fontWithName:navigationBarFont size:15.f]}];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
    
    [[SIAlertView appearance] setDestructiveButtonColor:kDarkBlue];
    [[SIAlertView appearance] setCancelButtonColor:UIColorFromRGB(0x2a142e)];
    
    [[SIAlertView appearance] setTitleFont:[UIFont fontWithName:@"RobotoCondensed-Bold" size:25.f]];
    [[SIAlertView appearance] setTitleColor:UIColorFromRGB(0x2a142e)];
    
    [[SIAlertView appearance] setMessageColor:[UIColor darkGrayColor]];
    [[SIAlertView appearance] setMessageFont:[UIFont fontWithName:@"Roboto" size:17.f]];
    
    [[SIAlertView appearance] setButtonFont:[UIFont fontWithName:@"RobotoCondensed-Bold" size:20.f]];
//    [[SIAlertView appearance] setButtonColor:kDarkBlue];
}

@end
