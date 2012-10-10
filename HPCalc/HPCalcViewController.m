//
//  HPCalcViewController.m
//  HPCalc
//
//  Created by Tom Darci on 10/9/12.
//  Copyright (c) 2012 So Much Fun. All rights reserved.
//

#import "HPCalcViewController.h"
#import "HPCalcBrain.h"

@interface HPCalcViewController ()

@property (nonatomic) BOOL userEntryInProgress;
@property (nonatomic, strong) HPCalcBrain *brain;
@end




@implementation HPCalcViewController

@synthesize display = _display;
@synthesize userEntryInProgress = _userEntryInProgress;
@synthesize brain = _brain;

- (HPCalcBrain *)brain {
    if (! _brain) _brain = [[HPCalcBrain alloc] init];
    return _brain;
}

- (IBAction)digitButtonPressed:(UIButton *)sender {
    NSString *digit = sender.currentTitle;
    UILabel *myDisplay = self.display;
    
    if (self.userEntryInProgress){
        NSString *currentText = myDisplay.text;
        NSString *newText = [currentText stringByAppendingString:digit];
        if ([self isValidEntry:newText]) {
            myDisplay.text = newText;
        }
    } else {
        myDisplay.text = digit;
        self.userEntryInProgress = YES;
    }
}

- (BOOL) isValidEntry: (NSString *) entry {
    if (! entry) {
        return NO;
    }
    NSString *regex = @"^.*\\.{1}.*\\.{1}.*$";
    NSPredicate *regextest = [NSPredicate
                              predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([regextest evaluateWithObject:entry] == YES) {
        NSLog(@"This number has multiple decimal points.");
        return NO;
    } else {
        return YES;
    }

}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userEntryInProgress) [self enterPressed];
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
}

- (IBAction)enterPressed {
    self.userEntryInProgress = NO;
    double newOperand = [self.display.text doubleValue];
    [self.brain pushOperand:newOperand];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
