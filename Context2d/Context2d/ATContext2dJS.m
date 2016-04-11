//
//  ATContext2dJS.m
//  Context2d
//
//  Created by Henryk Wollik on 10/04/16.
//  Copyright © 2016 automat. All rights reserved.
//

#import "ATContext2dJS.h"
#import "ATCOScriptInterface.h"
#import "ATSketchCanvas.h"

#import <JavaScriptCore/JavaScriptCore.h>

#pragma mark - ATContext2dJS

static BOOL verboseLog = NO;

@implementation ATContext2dJS
+ (void) setVerbose:(BOOL)verbose{
    verboseLog = verbose;
}

+ (void) runScript:(NSString*)script andTarget:(MSLayerGroup*)target{
    //for now
    JSContext *context = [JSContext new];
    
    //console
    context[@"__ATCOScriptPrint"] = ^(id o){
        ATCOScriptPrint(o);
    };
    NSString *patchConsole = @"var console = {log : function(){var o = [];for(var i = 0; i < arguments.length; ++i)o[i] = arguments[i] ; __ATCOScriptPrint(o.join(','));}};";
    
    //canvas
    ATSketchCanvas *canvas = [ATSketchCanvas canvasWithGroup:target];
    context[@"__ATSketchCanvasInstance"] = canvas;
    
    //exception
    [context setExceptionHandler:^(JSContext *context, JSValue *exception) {
        id exception_ = [exception toObject];
        NSString *string = [NSString stringWithFormat:@"Uncaught %@: line %@, column %@ \nstack:\n%@",
                            exception,
                            @([exception_[@"line"] integerValue] - 1),
                            exception_[@"column"],
                            exception[@"stack"]];
        ATCOScriptPrint(string);
    }];
    
    //build script
    NSMutableString *script_ = [NSMutableString new];
    [script_ appendString:patchConsole];
    [script_ appendString:@"\n"];
    [script_ appendString:script];
    
    //run
    [context evaluateScript:script_];
}

+ (void) runScriptAtPath:(NSString *)path andTarget:(MSLayerGroup *)target{
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self runScript:script andTarget:target];
}
@end