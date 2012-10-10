//
//  HPCalcBrain.m
//  HPCalc
//
//  Created by Tom Darci on 10/9/12.
//  Copyright (c) 2012 So Much Fun. All rights reserved.
//

#import "HPCalcBrain.h"

@interface HPCalcBrain()

@property (nonatomic, strong) NSMutableArray *operandStack;

@end




@implementation HPCalcBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray *) operandStack
{
    if (_operandStack == nil) _operandStack = [[NSMutableArray alloc] init];
    return _operandStack;
}

- (void) pushOperand: (double) operand {
    NSNumber *wrappedOperand = [NSNumber numberWithDouble:operand];
    [self.operandStack addObject:wrappedOperand];
    [self showStack];
}

- (void) showStack {
    NSEnumerator *iter = [self.operandStack objectEnumerator];
    id obj;
    int counter = 0;
    NSLog(@"== Stack Contents ==");
    while (obj = [iter nextObject]){
        counter++;
        NSLog(@"%d. %@", counter, obj);
    }
    NSLog(@"================");
}
     


- (double) popOperand {
    NSNumber *operand = [self.operandStack lastObject];
    if (operand) {
        [self.operandStack removeLastObject];
        [self showStack];
        return [operand doubleValue];
    } else {
        NSLog(@"Nothing to pop.");
        return 0;
    }
}

- (double) performOperation: (NSString *) operation {
    double result;
    if ([operation isEqualToString:@"+"]){
        result =  [self popOperand] + [self popOperand];
    }
    else if ([operation isEqualToString:@"*"]){
        result =  [self popOperand] * [self popOperand];
    }
    else if ([operation isEqualToString:@"/"]){
        double secondArg = [self popOperand];
        double firstArg = [self popOperand];
        result = firstArg / secondArg;
    }
    else if ([operation isEqualToString:@"-"]){
        double secondArg = [self popOperand];
        double firstArg = [self popOperand];
        result =  firstArg - secondArg;
    }
    else if ([operation isEqualToString:@"sin"]) {
        result = sin([self popOperand]);
    }
    else if ([operation isEqualToString:@"cos"]) {
        result = cos([self popOperand]);
    }
    else if ([operation isEqualToString:@"sqrt"]) {
        result = sqrt([self popOperand]);
    }
    else if ([operation isEqualToString:@"pi"]) {
        result = 3.14159265359;
    }
    [self pushOperand:result];
    return result;
}


@end
