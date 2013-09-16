//
//  SFKOProjectTask.m
//  ProjectCompare
//
//  Created by Sixten Otto on 9/16/13.
//  Copyright (c) 2013 Sixten Otto. All rights reserved.
//

#import <XcodeEditor/XcodeEditor.h>

#import "SFKOProjectTask.h"

NSString *const SFKOProjectTaskErrorDomain = @"SFKOProjectTask";


@interface SFKOProjectTask ()

@property (strong, nonatomic, readwrite) XCProject *project;
@property (strong, nonatomic, readwrite) XCTarget  *sourceTarget;
@property (strong, nonatomic, readwrite) XCTarget  *destinationTarget;

@end


@implementation SFKOProjectTask

- (instancetype)initWithProjectPath:(NSString *)projectPath
                       sourceTarget:(NSString *)sourceTargetName
                  destinationTarget:(NSString *)destinationTargetName
{
  NSParameterAssert(projectPath);
  NSParameterAssert(sourceTargetName);
  NSParameterAssert(destinationTargetName);
  
  self = [super init];
  if (self) {
    XCProject *project = [[XCProject alloc] initWithFilePath:projectPath];
    NSAssert(project, @"Could not intantiate project with path %@", projectPath);
    
    XCTarget *sourceTarget = [project targetWithName:sourceTargetName];
    NSAssert(sourceTarget, @"Could not find source target %@ in project", sourceTargetName);
    
    XCTarget *destinationTarget = [project targetWithName:destinationTargetName];
    NSAssert(destinationTarget, @"Could not find destination target %@ in project", destinationTargetName);
    
    self.project = project;
    self.sourceTarget = sourceTarget;
    self.destinationTarget = destinationTarget;
  }
  return self;
}

- (BOOL)verifyProject:(NSError *__autoreleasing *)error
{
  BOOL valid = YES;
  
  if( nil == self.project ) {
    valid = NO;
    if( NULL != error ) {
      *error = [NSError errorWithDomain:SFKOProjectTaskErrorDomain code:SFKOProjectTaskErrorInvalidProject userInfo:@{
             NSLocalizedDescriptionKey : @"The project path you specified is invalid, or the project could not be read.",
                }];
    }
  }
  else if( nil == self.sourceTarget ) {
    valid = NO;
    if( NULL != error ) {
      *error = [NSError errorWithDomain:SFKOProjectTaskErrorDomain code:SFKOProjectTaskErrorInvalidSourceTarget userInfo:@{
             NSLocalizedDescriptionKey : @"The project you specified does not contain a target matching the source name you specified.",
                }];
    }
  }
  else if( nil == self.destinationTarget ) {
    valid = NO;
    if( NULL != error ) {
      *error = [NSError errorWithDomain:SFKOProjectTaskErrorDomain code:SFKOProjectTaskErrorInvalidDestinationTarget userInfo:@{
             NSLocalizedDescriptionKey : @"The project you specified does not contain a target matching the destination name you specified.",
                }];
    }
  }
  
  return valid;
}

@end
