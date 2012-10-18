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

- (double) performOperation: (NSString *) operation {
    
    [self.programStack addObject:operation];
    [self showStack];
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
    //    NSLog(@"================");
}

- (void) clear
{
    [self.programStack removeAllObjects];
}

// ============================================================
// class methods

+ (NSArray *) supportedOperators {
    static NSArray *things;
    if (! things) {
        things = [NSArray arrayWithObjects:@"+", @"*", @"/", @"-", @"sin", @"cos", @"sqrt", @"pi", nil];
    }
    return things;
}

+ (double)popOperandOffStack: (NSMutableArray *)stack {
    
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
                result =  [self popOperandOffStack: stack] + [self popOperandOffStack: stack];
            }
            else if ([operation isEqualToString:@"*"]){
                result =  [self popOperandOffStack: stack] * [self popOperandOffStack: stack];
            }
            else if ([operation isEqualToString:@"/"]){
                double secondArg = [self popOperandOffStack: stack];
                double firstArg = [self popOperandOffStack: stack];
                result = firstArg / secondArg;
            }
            else if ([operation isEqualToString:@"-"]){
                double secondArg = [self popOperandOffStack: stack];
                double firstArg = [self popOperandOffStack: stack];
                result =  firstArg - secondArg;
            }
            else if ([operation isEqualToString:@"sin"]) {
                result = sin([self popOperandOffStack: stack]);
            }
            else if ([operation isEqualToString:@"cos"]) {
                result = cos([self popOperandOffStack: stack]);
            }
            else if ([operation isEqualToString:@"sqrt"]) {
                result = sqrt([self popOperandOffStack: stack]);
            }
            else if ([operation isEqualToString:@"pi"]) {
                result = 3.14159265359;
            }
        } else {
            // this is a variable
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
                result = [result stringByAppendingString:[self popStackForDescription: stack]];
                result = [result stringByAppendingString:@" + "];
                result = [result stringByAppendingString:[self popStackForDescription: stack]];
            }
            else if ([operation isEqualToString:@"*"]){
                result = [result stringByAppendingString:[self popStackForDescription: stack]];
                result = [result stringByAppendingString:@" * "];
                result = [result stringByAppendingString:[self popStackForDescription: stack]];
            }
            else if ([operation isEqualToString:@"/"]){
                NSString *secondArg = [self popStackForDescription: stack];
                NSString *firstArg = [self popStackForDescription: stack];
                result = [result stringByAppendingString:firstArg];
                result = [result stringByAppendingString:@" / "];
                result = [result stringByAppendingString:secondArg];
            }
            else if ([operation isEqualToString:@"-"]){
                NSString *secondArg = [self popStackForDescription: stack];
                NSString *firstArg = [self popStackForDescription: stack];
                result = [result stringByAppendingString:firstArg];
                result = [result stringByAppendingString:@" - "];
                result = [result stringByAppendingString:secondArg];
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
        }
    }
    return result;
}

+ (double) runProgram:(id)program
  usingVariableValues:(NSDictionary *)vals{
    
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    return  [self popOperandOffStack:stack];
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    return  [self popStackForDescription:stack];
}

@end
