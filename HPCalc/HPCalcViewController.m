//
//  HPCalcViewController.m
//  HPCalc
//
//  Created by Tom Darci on 10/9/12.
//  Copyright (c) 2012 So Much Fun. All rights reserved.
//

#import "HPCalcViewController.h"
#import "HPCalcBrain.h"

// ============================================================
@interface HPCalcViewController ()

@property (nonatomic) BOOL userEntryInProgress;
@property (nonatomic, strong) HPCalcBrain *brain;
@property (nonatomic) NSUInteger testValsIdx;

@end

// ============================================================
@implementation HPCalcViewController

@synthesize display = _display;
@synthesize historyTicker = _historyTicker;
@synthesize userEntryInProgress = _userEntryInProgress;
@synthesize brain = _brain;
@synthesize testValsIdx = _testValsIdx;

- (NSDictionary *) testVals {
  static NSMutableArray *dictArray;
  
  if (! dictArray) {
    dictArray = [NSMutableArray new];
    [dictArray addObject:@{@"foo": @1.0, @"bar": @2.0, @"bop": @3.0}];
    [dictArray addObject:@{@"foo": @0.0, @"bar": @0.0, @"bop": @0.0}];
    [dictArray addObject:@{@"foo": @1.0, @"bop": @3.0}];
    [dictArray addObject:@{@"foo": @-1.0, @"bar": @2.0, @"bop": @3.0}];
    [dictArray addObject:@{@"foo": @1000.0, @"bar": @2000.0, @"bop": @3000.0}];
    [dictArray addObject:@{@"foo": @1.2345, @"bar": @6.7890, @"bop": @100.0}];
  }
  
  if ((self.testValsIdx >= [dictArray count]) || (self.testValsIdx <= 0)) {
    self.testValsIdx = 0;
  }
  
  NSDictionary *curDict = [dictArray objectAtIndex:self.testValsIdx];
  return curDict;
}

- (HPCalcBrain *)brain {
  if (! _brain) {
    _brain = [[HPCalcBrain alloc] init];
    _brain.variableValues = [self testVals];
  }
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

- (void) redoResult {
  double result = [self.brain run];
  [self displayResult:result];
  [self updateDescription];
}

- (IBAction)undoButtonPressed {
  
  if (self.userEntryInProgress) {
    
    UILabel *myDisplay = self.display;
    NSString *curText = myDisplay.text;
    
    if ([curText length] <= 1) {
      self.userEntryInProgress = NO;
      [self redoResult];
    } else {
      curText = [curText substringToIndex:(curText.length - 2)];
      myDisplay.text = curText;
    }
    
  } else {
    [self.brain popStack];
    [self redoResult];
  }
  
}

- (void) updateDescription {
  self.historyTicker.text = [HPCalcBrain descriptionOfProgram:self.brain.program];
  self.variableDisplay.text = [self.brain descriptionOfVariables];
}

- (IBAction)operationPressed:(UIButton *)sender {
  
  if (self.userEntryInProgress) [self enterPressed];
  
  double result = [self.brain performOperation:sender.currentTitle];
  [self displayResult:result];
}

- (void) displayResult: (double) result
{
  NSString *resultString = [NSString stringWithFormat:@"%g", result];
  self.display.text = resultString;
  [self updateDescription];
}

- (IBAction)variablePressed:(UIButton *)sender {
  // if we are in the middle of entering a number, then send it along
  if (self.userEntryInProgress) [self enterPressed];
  // display our variable
  NSString *variable = sender.currentTitle;
  UILabel *myDisplay = self.display;
  myDisplay.text = variable;
  // enter our variable
  [self enterPressed];
}

- (IBAction)clearPressed {
  [self.brain clear];
  self.display.text = @"0";
  [self updateDescription];
}

- (IBAction)testValsPressed:(UIButton *)sender {
  self.testValsIdx++;
  self.brain.variableValues = [self testVals];
  [self redoResult];
}

- (IBAction)enterPressed {
  self.userEntryInProgress = NO;
  double newOperand = [self.display.text doubleValue];
  if ((newOperand == 0.0) && !([self.display.text hasPrefix:@"0"])) {
    NSString *variableName = self.display.text;
    [self.brain pushVariable:variableName];
  } else {
    [self.brain pushOperand:newOperand];
  }
  [self updateDescription];
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
