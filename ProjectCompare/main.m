//
//  main.m
//  ProjectCompare
//
//  Created by Sixten Otto on 9/15/13.
//  Copyright (c) 2013 Sixten Otto. All rights reserved.
//

#import <sysexits.h>
#import <Foundation/Foundation.h>
#import <FSArgumentParser/FSArgumentSignature.h>
#import <FSArgumentParser/FSArgumentPackage.h>
#import <FSArgumentParser/FSArgumentPackage_Private.h>
#import <FSArgumentParser/FSArgumentParser.h>

#import "SFKOProjectTask.h"

typedef NS_ENUM(NSUInteger, SFKOCommands) {
  SFKOCommandHelp,
  SFKOCommandCompare,
};


int main(int argc, const char * argv[])
{
  @autoreleasepool {
    
    // set up command line arguments
    FSArgumentSignature *projectArg = [FSArgumentSignature argumentSignatureWithFormat:@"[-p --project]="];
    FSArgumentSignature *sourceArg = [FSArgumentSignature argumentSignatureWithFormat:@"[-s --source-target]="];
    FSArgumentSignature *destintionArg = [FSArgumentSignature argumentSignatureWithFormat:@"[-d --destination-target]="];
    
    FSArgumentSignature *helpSubcommand = [FSArgumentSignature argumentSignatureWithFormat:@"[help]"];
    FSArgumentSignature *compareSubcommand = [FSArgumentSignature argumentSignatureWithFormat:@"[compare]"];
    [compareSubcommand setInjectedSignatures:[NSSet setWithObjects: sourceArg, destintionArg, nil]];
    NSArray *signatures = @[ projectArg, compareSubcommand, helpSubcommand ];
    
    FSArgumentParser *parser = [[FSArgumentParser alloc] initWithArguments:[[NSProcessInfo processInfo] arguments] signatures:signatures];
    FSArgumentPackage *arguments = [parser parse];

    
    // determine which command to invoke
    SFKOCommands command = NSNotFound;
    uint8_t commandsSpecified = 0;
    
    if( 0 < [arguments countOfSignature:helpSubcommand] ) {
      command = SFKOCommandHelp;
      ++commandsSpecified;
    }
    if( 0 < [arguments countOfSignature:compareSubcommand] ) {
      command = SFKOCommandCompare;
      ++commandsSpecified;
    }
    
    if( 1 != commandsSpecified ) {
      printf("You must specify exactly one of the following commands:\n  compare\n  help\n");
      return 1;
    }
    else if( SFKOCommandHelp == command ) {
      printf("Project Compare v1.0\n\nAvailable commands:\n\n");
      printf("%s\n", [[compareSubcommand descriptionForHelp:2 terminalWidth:80] UTF8String]);
      printf("%s\n", [[helpSubcommand descriptionForHelp:2 terminalWidth:80] UTF8String]);
    }
    else {
      // make sure that all of the required arguments are present
      BOOL validArguments = YES;
      if( 1 != [arguments countOfSignature:projectArg] ) {
        validArguments = NO;
        printf("You must specify an Xcode project file on which to operate.\n");
      }
      if( 1 != [arguments countOfSignature:sourceArg] ) {
        validArguments = NO;
        printf("You must specify a source target for the operation.\n");
      }
      if( 1 != [arguments countOfSignature:destintionArg] ) {
        validArguments = NO;
        printf("You must specify a destnation target for the operation.\n");
      }
      
      if( !validArguments ) {
        return EX_USAGE;
      }
      
      // set up the task with the input params
      NSError *error = nil;
      SFKOProjectTask *task = [[SFKOProjectTask alloc] initWithProjectPath:[arguments firstObjectForSignature:projectArg] sourceTarget:[arguments firstObjectForSignature:sourceArg] destinationTarget:[arguments firstObjectForSignature:destintionArg]];
      if( ![task verifyProject:&error] ) {
        printf("An error occurred: %s\n", [[error localizedDescription] UTF8String]);
        return EX_DATAERR;
      }
  
      // execute the desired command
      if( SFKOCommandCompare == command ) {
        if( ![task compare:&error] ) {
          printf("Target comparison failed: %s\n", [[error localizedDescription] UTF8String]);
          return 1;
        }
      }
    }
    
    // dump information about the command line arguments
#ifdef DEBUG
    printf("\n---------------\n%s\n", [[arguments prettyDescription] UTF8String]);
#endif
    
  }
  return 0;
}

