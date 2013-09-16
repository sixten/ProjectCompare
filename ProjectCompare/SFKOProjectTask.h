//
//  SFKOProjectTask.h
//  ProjectCompare
//
//  Created by Sixten Otto on 9/16/13.
//  Copyright (c) 2013 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCProject, XCTarget;

extern NSString *const SFKOProjectTaskErrorDomain;

NS_ENUM(NSInteger, SFKOProjectTaskErrors) {
  SFKOProjectTaskErrorInvalidProject           = 1, // specified project doesn't exist / can't be read
  
  SFKOProjectTaskErrorInvalidSourceTarget      = 5, // project doesn't contain a target with the given name
  SFKOProjectTaskErrorInvalidDestinationTarget = 6,
};


@interface SFKOProjectTask : NSObject

@property (strong, nonatomic, readonly) XCProject *project;
@property (strong, nonatomic, readonly) XCTarget  *sourceTarget;
@property (strong, nonatomic, readonly) XCTarget  *destinationTarget;


- (instancetype)initWithProjectPath:(NSString *)projectPath
                       sourceTarget:(NSString *)sourceTargetName
                  destinationTarget:(NSString *)destinationTargetName;

- (BOOL)verifyProject:(NSError *__autoreleasing *)error;

- (BOOL)compare:(NSError *__autoreleasing *)error;

@end
