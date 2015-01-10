//
//  TipViewController.m
//  TipCalculator
//
//  Created by David Rajan on 12/19/14.
//  Copyright (c) 2014 David Rajan. All rights reserved.
//

#import "TipViewController.h"
#import "SettingsViewController.h"

@interface TipViewController ()

@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;

@property (weak, nonatomic) IBOutlet UILabel *split1Label;
@property (weak, nonatomic) IBOutlet UILabel *split2Label;
@property (weak, nonatomic) IBOutlet UILabel *split3Label;
@property (weak, nonatomic) IBOutlet UILabel *split4Label;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

- (IBAction)onTap:(id)sender;
- (void)updateValues;

@end

@implementation TipViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Tip Calculator";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(onSettingsButton)];
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.numberFormatter.minimumFractionDigits = 2;
    self.numberFormatter.maximumFractionDigits = 2;
    self.numberFormatter.locale = [NSLocale currentLocale];
    
    self.billTextField.delegate = self;
    self.billTextField.placeholder = [self.numberFormatter currencySymbol];
}

- (void)onSettingsButton {
    [self.navigationController pushViewController:[[SettingsViewController alloc] init] animated:YES];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}


- (IBAction)onUpdateBill:(id)sender {
    [self updateValues];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Make sure that user doesn't remove currency symbol or change to non-numerical value
    if (![str hasPrefix:[self.numberFormatter currencySymbol]] || (str.length > 1 && ![self.numberFormatter numberFromString:str])) {
        
        textField.backgroundColor = [UIColor redColor];
        [UIView animateWithDuration:1.5 animations:^{
            textField.backgroundColor = [UIColor yellowColor];
        }];
        
        return NO;
    }

    return YES;
}

- (void)updateValues {
    float billAmount = [[self.numberFormatter numberFromString:self.billTextField.text] floatValue];
    
    NSArray *tipValues = @[@(0.15), @(0.18), @(0.2)];
    float tipAmount = billAmount * [tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    float totalAmount = billAmount + tipAmount;
    
    self.tipLabel.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:tipAmount]];
    self.totalLabel.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmount]];
    
    self.split1Label.text = self.totalLabel.text;
    self.split2Label.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmount/2]];
    self.split3Label.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmount/3]];
    self.split4Label.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmount/4]];
    
    // Save bill amount to restore later
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:CACurrentMediaTime() forKey:@"timeSaved"];
    [defaults setObject:self.billTextField.text forKey:@"billAmount"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Load colors depending on color scheme selected in prefs
    if ([defaults boolForKey:@"darkColorSwitch"]) {
        self.view.backgroundColor = [UIColor blackColor];
        self.billTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.billTextField.tintColor = [UIColor blackColor];
        self.billTextField.textColor = [UIColor blackColor];
        [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor greenColor];
        [[UILabel appearance] setTextColor:[UIColor greenColor]];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.billTextField.keyboardAppearance = UIKeyboardAppearanceLight;
        [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor redColor];
        [[UILabel appearance] setTextColor:[UIColor darkTextColor]];
    }
    
    // Restore tip amount to default selected in prefs
    self.tipControl.selectedSegmentIndex = [defaults integerForKey:@"defaultTipIndex"];
    
    self.billTextField.alpha = 0;
    [UIView animateWithDuration:1.5 animations:^{
        self.billTextField.alpha = 1;
        self.billTextField.backgroundColor = [UIColor yellowColor];
    }];
    
    // Using CACurrentMediaTime() instead of NSDate to avoid potential time sync issues
    CFTimeInterval timeSaved = [defaults doubleForKey:@"timeSaved"];
    CFTimeInterval elapsedTime = CACurrentMediaTime() - timeSaved;
    
    // If it's less than 600s (10 min) since last launch restore previous bill amount.
    if (elapsedTime < 600) {
        self.billTextField.text = [defaults stringForKey:@"billAmount"];
    } else {
        self.billTextField.text = [self.numberFormatter currencySymbol];
    }
    
    [self updateValues];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"view will disappear");
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"view did disappear");
}

@end
