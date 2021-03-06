//
//  HPCalcBrain.h
//  HPCalc
//
//  Created by Tom Darci on 10/9/12.
//  Copyright (c) 2012 So Much Fun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPCalcBrain : NSObject

- (void) pushOperand: (double) operand;
- (void) popStack;
- (void) pushVariable: (NSString *) variable;
- (double) performOperation: (NSString *) operation;
- (NSString *) descriptionOfVariables;
- (double) run;
- (void) clear;

@property (readonly) id program;
@property NSDictionary *variableValues;

+ (double) runProgram: (id) program
  usingVariableValues:(NSDictionary *)vals;

+ (NSString *) descriptionOfProgram: (id) program;
+ (NSSet *) variablesUsedInProgram: (id) program;
+ (NSString *) descriptionOfVariables: (id) program withVariables: (NSDictionary *) variables;

@end
