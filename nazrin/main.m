//
//  main.m
//  nazrin
//
//  Created by lifeaether on 2013/04/19.
//
//

#import <Cocoa/Cocoa.h>

@interface Nazrin : NSObject
@end

@implementation Nazrin

- (void)shorteningURL:(NSPasteboard *)pasteBoard userData:(NSString *)data error:(NSString **)errorString
{
    NSString *type = nil;
    if ( [[pasteBoard types] containsObject:NSStringPboardType] ) type = NSStringPboardType;
    if ( [[pasteBoard types] containsObject:NSURLPboardType] ) type = NSURLPboardType;

    if ( ! type ) {
        *errorString = NSLocalizedString( @"Error: Pasteboard does not contains string or URL.", nil );
    }
    
    NSString *srcString = [pasteBoard stringForType:type];
    NSString *escapedString = [srcString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *nazrinURLString = [NSString stringWithFormat:@"http://nazr.in/api/shorten?url=%@", escapedString];
    NSURL *url = [NSURL URLWithString:nazrinURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ( ! responseData ) {
        *errorString = NSLocalizedString( @"Error: NazService failed to get shortening URL from nazr.in.", nil );
        return;
    }
    
    NSString *responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    if ( ! [responseString hasPrefix:@"http"] ) {
        *errorString = NSLocalizedString( @"Error: The URL couldn't shorten URL.", nil );
        return;
    }
    
    [pasteBoard declareTypes:[NSArray arrayWithObject:type] owner:nil];
    [pasteBoard setString:responseString forType:type];
}

@end

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    id serviceProvider = [[Nazrin alloc] init];
    NSRegisterServicesProvider( serviceProvider, @"NazService" );
    
    [[NSRunLoop currentRunLoop] run];
    
    [serviceProvider release];
    [pool release];
    
    return 0;
}
