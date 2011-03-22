//
//  mGrab.m
//  Pneumonia
//
//  Created by GreySyntax.
//  Copyright 2010-2011 NSPwn. All rights reserved.
//

#import "mGrab.h"

@implementation mGrab
@synthesize url, error;

#pragma mark -
#pragma mark Core
- (id)init
{
	return [self initWithEmail:nil andPassword:nil];
}

- (id)initWithEmail:(NSString*)email andPassword:(NSString*)password
{
	if((self = [super init]))
	{
		self.email = email;
		self.password = password;
		self.session = NO;
		self.url = @"";
		self.error = @"";
	}
	
	return self;
}

- (BOOL)login
{
	if (image == nil || self.email == nil || self.password != nill)
	{
		self.error = @"Email/Password was nil";
		return NO;
	}
	
	NSError *error;
	
	//creating the url request:
	NSURL *uploadEndpoint = [NSURL URLWithString:@"http://tinygrab.com/api/v3.php?m=grab/upload"];
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:uploadEndpoint];

	//adding header information:
	[postRequest setHTTPMethod:@"POST"];

	NSString *stringBoundary = [NSString stringWithString:@"---------------------------mGrab"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[postRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];

	//setting up the body:
	NSMutableData *postBody = [NSMutableData data];

	//EMAIL
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:self.email] dataUsingEncoding:NSUTF8StringEncoding]];

	//PASSWORD
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"passwordhash\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:[self md5:password]] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//END
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:postBody];

	error = nil;
	NSURLResponse *response = nil;

	NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];

	if (error != nil) {
		
		self.error = [error localizedDescription];
		return NO;
	}

	if (![response respondsToSelector:@selector(allHeaderFields)]) {

		self.error = @"Cant access headers (failed to cast)";
		return NO;
	}

	NSDictionary *dict = [response allHeaderFields];

	if (dict == nil) {

		self.error = @"Headers were empty";
		return NO;
	}
	
	#if defined(DEBUG)
	NSLog(@"DICT:\r\n\r\n%@", dict);
	#endif
	
	self.error = [dict objectForKey:@"X-Error-Text"]; // Will either update or set error to nill
	
	if (self.error != nil)
	{
		return NO;
	}
	
	self.session = YES;
	return YES;
}

- (NSString*)upload:(NSString*)file
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:file])
	{
		self.error = @"Specified file not found";
		return @"";
	}
	
	
	return [self upload:[NSData dataWithContentsOfFile:file]];
}

- (NSString*)upload:(NSData*)image
{
	
	if (image == nil || self.email == nil || self.password != nill)
	{
		self.error = @"Image/Email/Password was nil";
		return @"";
	}
	
	if (!self.session && ![self login])
	{
		self.error = @"Failed to login";
		return NO;
	}
	
	NSError *error;
	
	//creating the url request:
	NSURL *uploadEndpoint = [NSURL URLWithString:@"http://tinygrab.com/api/v3.php?m=grab/upload"];
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:uploadEndpoint];

	//adding header information:
	[postRequest setHTTPMethod:@"POST"];

	NSString *stringBoundary = [NSString stringWithString:@"---------------------------mGrab"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[postRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];

	//setting up the body:
	NSMutableData *postBody = [NSMutableData data];

	//EMAIL
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:self.email] dataUsingEncoding:NSUTF8StringEncoding]];

	//PASSWORD
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"passwordhash\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:[self md5:password]] dataUsingEncoding:NSUTF8StringEncoding]];

	//IMAGE
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n", [self generateName]] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:img]];

	//END
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:postBody];

	error = nil;
	NSURLResponse *response = nil;

	NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];

	if (error != nil) {
		
		self.error = [error localizedDescription];
		return @"";
	}

	if (![response respondsToSelector:@selector(allHeaderFields)]) {

		self.error = @"Cant access headers (failed to cast)";
		return @"";
	}

	NSDictionary *dict = [response allHeaderFields];

	if (dict == nil) {

		self.error = @"Headers were empty";
		return @"";
	}
	
	#if defined(DEBUG)
	NSLog(@"DICT:\r\n\r\n%@", dict);
	#endif
	
	self.url = [dict objectForKey:@"X-Grab-Url"];
	self.error = [dict objectForKey:@"X-Error-Text"]; // Will either update or set error to nill
	
	return self.url
}

#pragma mark -
#pragma mark Common
- (NSString*)generateName
{
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2011-02-01 19:50:41 PST
	
	return [NSString stringWithFormat:@"mGrab - %@.png", [dateFormat stringFromDate:[NSDate date]]];
}

- (NSString*)md5:(NSString*)chunk
{
  const char *cStr = [chunk UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];

  CC_MD5(cStr, strlen(cStr), result);

  return [[NSString
      stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
      result[0], result[1],
      result[2], result[3],
      result[4], result[5],
      result[6], result[7],
      result[8], result[9],
      result[10], result[11],
      result[12], result[13],
      result[14], result[15]
      ] lowercaseString];
}

- (BOOL)network
{
	const char *host = "tinygrab.com";
	SCNetworkReachabilityRef reach = SCNetworkReachabilityCreateWithName(NULL, host);

	SCNetworkReachabilityFlags flag;

	Boolean conn = SCNetworkReachabilityGetFlags(reach, &flag);

	//Can we reach tinygrab.com?
	return (conn && (flag & kSCNetworkFlagsReachable) && !(flag & kSCNetworkFlagsConnectionRequired));
}
@end