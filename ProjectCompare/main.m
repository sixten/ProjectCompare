//
//  main.m
//  ProjectCompare
//
//  Created by Sixten Otto on 9/15/13.
//  Copyright (c) 2013 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FSArgumentParser/FSArgumentSignature.h>
#import <FSArgumentParser/FSArgumentPackage.h>
#import <FSArgumentParser/FSArgumentPackage_Private.h>
#import <FSArgumentParser/FSArgumentParser.h>

typedef NS_ENUM(NSUInteger, SFKOCommands) {
  SFKOCommandHelp,
  SFKOCommandCompare,
};


int main(int argc, const char * argv[])
{
  @autoreleasepool {
    
    // set up command line arguments
    FSArgumentSignature *projectArg = [FSArgumentSignature argumentSignatureWithFormat:@"[-p --project]="];
    FSArgumentSignature *helpSubcommand = [FSArgumentSignature argumentSignatureWithFormat:@"[help]"];
    FSArgumentSignature *compareSubcommand = [FSArgumentSignature argumentSignatureWithFormat:@"[compare]"];
    [compareSubcommand setInjectedSignatures:[NSSet setWithObjects:
                                              [FSArgumentSignature argumentSignatureWithFormat:@"[-s --source-target]="],
                                              [FSArgumentSignature argumentSignatureWithFormat:@"[-d --destination-target]="],
                                              nil]];
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
    else if( SFKOCommandCompare == command ) {
    }
    
    // dump information about the command line arguments
#ifdef DEBUG
    printf("\n---------------\n%s\n", [[arguments prettyDescription] UTF8String]);
#endif
    
  }
  return 0;
}

