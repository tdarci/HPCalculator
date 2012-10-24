//
//  HPCalcBrain.m
//  HPCalc
//
//  Created by Tom Darci on 10/9/12.
//  Copyright (c) 2012 So Much Fun. All rights reserved.
//

#import "HPCalcBrain.h"

// ============================================================
@interface HPCalcBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end


// ============================================================
@implementation HPCalcBrain

@synthesize programStack = _programStack;
@synthesize variableValues = _variableValues;

- (id) program {
  return [self.programStack copy];
}

- (NSMutableArray *) programStack
{
  if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
  return _programStack;
}

- (void) pushOperand: (double) operand {
  NSNumber *wrappedOperand = [NSNumber numberWithDouble:operand];
  [self.programStack addObject:wrappedOperand];
  [self showStack];
}

- (void) popStack {
  if ([self.programStack count] > 0) {
    [self.programStack removeLastObject];
  }
}

- (void) pushVariable: (NSString *) variable {
  [self.programStack addObject:variable];
  [self showStack];
}

- (double) performOperation: (NSString *) operation {
  [self.programStack addObject:operation];
  [self showStack];
  return [self run];
}

- (double) run {
  return [HPCalcBrain runProgram:self.program usingVariableValues:[self variableValues]];
}

- (void) showStack {
  NSEnumerator *iter = [self.programStack objectEnumerator];
  id obj;
  int counter = 0;
  NSLog(@"== Stack Contents ==");
  while (obj = [iter nextObject]){
    counter++;
    NSLog(@"%d. %@", counter, obj);
  }
}

- (NSString *) descriptionOfVariables {
  return [HPCalcBrain descriptionOfVariables:self.program withVariables:self.variableValues];
}

- (void) clear
{
  [self.programStack removeAllObjects];
}

// ============================================================
// class methods

+ (NSArray *) biOperators {
  static NSArray *things;
  if (! things) {
    things = [NSArray arrayWithObjects:@"+", @"*", @"/", @"-", nil];
  }
  return things;
}

+ (NSArray *) uniOperators {
  static NSArray *things;
  if (! things) {
    things = [NSArray arrayWithObjects:@"sin", @"cos", @"sqrt", nil];
  }
  return things;
}

+ (NSArray *) soloOperators {
  static NSArray *things;
  if (! things) {
    things = [NSArray arrayWithObjects:@"pi", nil];
  }
  return things;
}

+ (NSArray *) supportedOperators {
  static NSArray *things;
  if (! things) {
    NSMutableArray *foo = [NSMutableArray arrayWithArray:[self biOperators]];
    [foo addObjectsFromArray:[self uniOperators]];
    [foo addObjectsFromArray:[self soloOperators]];
    things = [foo mutableCopy];
  }
  return things;
}

+ (double)runStack: (NSMutableArray *)stack
usingVariableValues: (NSDictionary *) vals{
  
  double result = 0;
  
  id topOfStack = [stack lastObject];
  if (topOfStack) [stack removeLastObject];
  
  if ([topOfStack isKindOfClass:[NSNumber class]]) {
    result = [topOfStack doubleValue];
  } else if ([topOfStack isKindOfClass:[NSString class]]) {
    
    // this comparison should work for strings.
    if ([[self supportedOperators] containsObject:topOfStack ]) {
      // this is an operation
      NSString *operation = topOfStack;
      
      if ([operation isEqualToString:@"+"]){
        result =  [self runStack: stack usingVariableValues: vals] + [self runStack: stack usingVariableValues: vals];
      }
      else if ([operation isEqualToString:@"*"]){
        result =  [self runStack: stack usingVariableValues: vals] * [self runStack: stack usingVariableValues: vals];
      }
      else if ([operation isEqualToString:@"/"]){
        double secondArg = [self runStack: stack usingVariableValues: vals];
        double firstArg = [self runStack: stack usingVariableValues: vals];
        result = firstArg / secondArg;
      }
      else if ([operation isEqualToString:@"-"]){
        double secondArg = [self runStack: stack usingVariableValues: vals];
        double firstArg = [self runStack: stack usingVariableValues: vals];
        result =  firstArg - secondArg;
      }
      else if ([operation isEqualToString:@"sin"]) {
        result = sin([self runStack: stack usingVariableValues: vals]);
      }
      else if ([operation isEqualToString:@"cos"]) {
        result = cos([self runStack: stack usingVariableValues: vals]);
      }
      else if ([operation isEqualToString:@"sqrt"]) {
        result = sqrt([self runStack: stack usingVariableValues: vals]);
      }
      else if ([operation isEqualToString:@"pi"]) {
        result = 3.14159265359;
      }
    } else {
      // this is a variable
      result = [[vals objectForKey:topOfStack] doubleValue];
    }
  }
  return result;
}

+ (NSString *)popStackForDescription: (NSMutableArray *)stack {
  
  NSString *result = @"";
  
  id topOfStack = [stack lastObject];
  if (topOfStack) [stack removeLastObject];
  
  if ([topOfStack isKindOfClass:[NSNumber class]]) {
    result = [topOfStack stringValue];
  } else if ([topOfStack isKindOfClass:[NSString class]]) {
    
    // this comparison should work for strings.
    if ([[self supportedOperators] containsObject:topOfStack ]) {
      // this is an operation
      NSString *operation = topOfStack;
      
      if ([operation isEqualToString:@"+"]){
        result = [result stringByAppendingString:@"("];
        result = [result stringByAppendingString:[self popStackForDescription: stack]];
        result = [result stringByAppendingString:@" + "];
        result = [result stringByAppendingString:[self popStackForDescription: stack]];
        result = [result stringByAppendingString:@")"];
      }
      else if ([operation isEqualToString:@"*"]){
        result = [result stringByAppendingString:@"("];
        result = [result stringByAppendingString:[self popStackForDescription: stack]];
        result = [result stringByAppendingString:@" * "];
        result = [result stringByAppendingString:[self popStackForDescription: stack]];
        result = [result stringByAppendingString:@")"];
      }
      else if ([operation isEqualToString:@"/"]){
        result = [result stringByAppendingString:@"("];
        NSString *secondArg = [self popStackForDescription: stack];
        NSString *firstArg = [self popStackForDescription: stack];
        result = [result stringByAppendingString:firstArg];
        result = [result stringByAppendingString:@" / "];
        result = [result stringByAppendingString:secondArg];
        result = [result stringByAppendingString:@")"];
      }
      else if ([operation isEqualToString:@"-"]){
        result = [result stringByAppendingString:@"("];
        NSString *secondArg = [self popStackForDescription: stack];
        NSString *firstArg = [self popStackForDescription: stack];
        result = [result stringByAppendingString:firstArg];
        result = [result stringByAppendingString:@" - "];
        result = [result stringByAppendingString:secondArg];
        result = [result stringByAppendingString:@")"];
      }
      else if ([operation isEqualToString:@"sin"]) {
        result = [result stringByAppendingString:@"sin("];
        result = [result stringByAppendingString:[self popStackForDescription: stack]];
        result = [result stringByAppendingString:@")"];
      }
      else if ([operation isEqualToString:@"cos"]) {
        result = [result stringByAppendingString:@"cos("];
        result = [result stringByAppendingString:[self popStackForDescription: stack]];
        result = [result stringByAppendingString:@")"];
      }
      else if ([operation isEqualToString:@"sqrt"]) {
        result = [result stringByAppendingString:@"sqrt("];
        result = [result stringByAppendingString:[self popStackForDescription: stack]];
        result = [result stringByAppendingString:@")"];
      }
      else if ([operation isEqualToString:@"pi"]) {
        result = [result stringByAppendingString:operation];
      }
    } else {
      // this is a variable
      result = [result stringByAppendingString:topOfStack];
    }
  }
  return result;
}

+ (NSMutableSet *) popStackForVariables: (NSMutableArray *)stack
{
  NSMutableSet *result = [NSMutableSet new];
  
  id topOfStack = [stack lastObject];
  if (topOfStack) [stack removeLastObject];
  
  if ([topOfStack isKindOfClass:[NSNumber class]]) {
      // do nothing
  } else if ([topOfStack isKindOfClass:[NSString class]]) {
    
    if ([[self supportedOperators] containsObject:topOfStack ]) {
      // this is an operation
      NSString *operation = topOfStack;
      
      if ([[self biOperators] containsObject:operation]){
        [result unionSet: [self popStackForVariables:stack]];
        [result unionSet: [self popStackForVariables:stack]];
      }
      else if ([[self uniOperators] containsObject:operation]){
        [result unionSet: [self popStackForVariables:stack]];
      }
    } else {
      // this is a variable. woot!
      [result addObject:topOfStack];
    }
  }
  return result;
}


+ (NSSet *) variablesUsedInProgram: (id) program {

  NSMutableArray *stack;
  
  if ([program isKindOfClass:[NSArray class]]) {
    stack = [program mutableCopy];
  }
  
  return [self popStackForVariables:stack];
}

+ (NSString *) descriptionOfVariables: (id) program withVariables: (NSDictionary *) variables {
  NSString * foo = @"";
  NSSet *vars = [self variablesUsedInProgram:program];
  for (id obj in vars) {
    NSString *varName = obj;
    NSString *desc = [varName stringByAppendingString:@" = "];
    double variableVal = [[variables objectForKey:varName] doubleValue];
    desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%f", variableVal]];
    if (foo != @"") {
      foo = [foo stringByAppendingString:@", "];
    }
    foo = [foo stringByAppendingString:desc];
  }
  return foo;
}

+ (double) runProgram:(id)program
  usingVariableValues:(NSDictionary *)vals{
  
  NSMutableArray *stack;
  
  if ([program isKindOfClass:[NSArray class]]) {
    stack = [program mutableCopy];
  }
  
  return [self runStack:stack usingVariableValues: vals];
}

+ (NSString *)descriptionOfProgram:(id)program {
  NSMutableArray *stack;
  
  if ([program isKindOfClass:[NSArray class]]) {
    stack = [program mutableCopy];
  }
  
  return [self popStackForDescription:stack];
}

@end
