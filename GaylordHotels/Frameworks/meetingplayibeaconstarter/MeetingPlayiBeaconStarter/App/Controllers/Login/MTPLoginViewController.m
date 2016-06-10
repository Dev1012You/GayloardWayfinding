//
//  MTPLoginViewController.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPLoginViewController.h"
#import "MTPLoginClient.h"
#import "MTPCustomRootNavigationViewController.h"
#import "User+Helpers.h"

@interface MTPLoginViewController ()

@end

@interface MTPLoginViewController (UITextFieldSetup)<UITextFieldDelegate>
@end
@implementation MTPLoginViewController (UITextFieldSetup)

- (void)setupTextFields
{
    self.usernameTextField.autocapitalizationType = false;
    self.usernameTextField.autocorrectionType = false;
    self.usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.passwordTextField.secureTextEntry = true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

@end

@implementation MTPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTextFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressLogin:(id)sender
{
    NSError *validationError = nil;
    if (![self shouldLogin:@[@1]]) {
        return;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    [self.loginClient login:self.usernameTextField.text
                   password:nil
             successHandler:^(id responseObject, User *currentUser)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.rootNavigationController loadLandingViewController];
         });
     }
             failureHandler:^(NSError *error)
     {
         [weakSelf showLoginFailure:error];
     }
            validationError:validationError];
}

- (void)showLoginFailure:(NSError *)loginError
{
    if (self.failureBlock)
    {
        self.failureBlock();
    }
}

- (BOOL)shouldLogin:(NSArray *)loginPrerequisites
{
    return true;
}

@end
