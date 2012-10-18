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
    return [HPCalcBrain runProgram:self.program];
    
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

+ (double)popOperandOffStack: (NSMutableArray *)stack {
    
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
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
    }
    return result;
}

+ (double) runProgram:(id)program {
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    return  [self popOperandOffStack:stack];
}

+ (NSString *)descriptionOfProgram:(id)program {
    return @"Please implement me.";
}

@end
