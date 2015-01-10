//
//  SettingsViewController.m
//  TipCalculator
//
//  Created by David Rajan on 12/29/14.
//  Copyright (c) 2014 David Rajan. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *defaultTipControl;
@property (weak, nonatomic) IBOutlet UISwitch *colorSchemeSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDefaults];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadDefaults];
}

- (void)loadDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.defaultTipControl.selectedSegmentIndex = [defaults integerForKey:@"defaultTipIndex"];
    [self.colorSchemeSwitch setOn:[defaults boolForKey:@"darkColorSwitch"]];
    [self updateColorScheme];
}

- (void)updateColorScheme {
    if (self.colorSchemeSwitch.isOn) {
        self.view.backgroundColor = [UIColor blackColor];
        [[UILabel appearance] setTextColor:[UIColor greenColor]];
        [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor greenColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        [[UILabel appearance] setTextColor:[UIColor darkTextColor]];
        [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor redColor];
    }
}

- (IBAction)updateDefaults:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.defaultTipControl.selectedSegmentIndex forKey:@"defaultTipIndex"];
    [defaults setBool:self.colorSchemeSwitch.isOn forKey:@"darkColorSwitch"];
    [self updateColorScheme];
}

@end
