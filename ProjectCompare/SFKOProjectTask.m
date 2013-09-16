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

- (BOOL)compare:(NSError *__autoreleasing *)error
{
  BOOL success = YES;
  
  NSArray *descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"pathRelativeToProjectRoot" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
  
  // compare members
  printf("\nMembers:\n");
  NSArray *sourceMembers = [[self.sourceTarget members] sortedArrayUsingDescriptors:descriptors];
  NSArray *destMembers = [[self.destinationTarget members] sortedArrayUsingDescriptors:descriptors];
  printf("%lu vs %lu files\n", (unsigned long)[sourceMembers count], (unsigned long)[destMembers count]);
  [self compareSourceArray:sourceMembers toDestinationArray:destMembers];
  
  // compare resources
  printf("\nResources:\n");
  NSArray *sourceResources = [[self.sourceTarget resources] sortedArrayUsingDescriptors:descriptors];
  NSArray *destResources = [[self.destinationTarget resources] sortedArrayUsingDescriptors:descriptors];
  printf("%lu vs %lu files\n", (unsigned long)[sourceResources count], (unsigned long)[destResources count]);
  [self compareSourceArray:sourceResources toDestinationArray:destResources];
  
  return success;
}

- (void)compareSourceArray:(NSArray *)source toDestinationArray:(NSArray *)dest
{
  NSUInteger sIdx = 0, dIdx = 0, guard = 0;
  XCSourceFile *sFile, *dFile;
  
  while( guard < ([source count] + [dest count]) ) {
    if( sIdx < [source count] ) {
      sFile = source[sIdx];
    }
    if( dIdx < [dest count] ) {
      dFile = dest[dIdx];
    }
    
    NSComparisonResult keyOrder = NSNotFound;
    if( sFile != nil && dFile != nil  ) {
      keyOrder = [[sFile pathRelativeToProjectRoot] caseInsensitiveCompare:[dFile pathRelativeToProjectRoot]];
    }
    else if( sFile == nil && dFile == nil ) {
      break;
    }
    
    if( keyOrder == NSOrderedSame ) {
      // in both targets, which is great
      ++sIdx;
      ++dIdx;
    }
    else if( keyOrder == NSOrderedDescending || sFile == nil ) {
      // in destination, not source
      printf("  + %s\n", [[dFile pathRelativeToProjectRoot] UTF8String]);
      ++dIdx;
    }
    else if( keyOrder == NSOrderedAscending || dFile == nil ) {
      // in source, not destination
      printf("  - %s\n", [[sFile pathRelativeToProjectRoot] UTF8String]);
      ++sIdx;
    }
    else {
      NSAssert(NO, @"Shouldn't be here!");
    }
    
    ++guard;
  }
  NSAssert(guard <= ([source count] + [dest count]), @"Shouldn't process this loop more than the total number of source + destination items");
}

@end
