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

- (id)initWithEmail:(NSString*)useremail andPassword:(NSString*)userpassword
{
	if((self = [super init]))
	{
		email = useremail;
		password = userpassword;
		session = NO;
		reachable = NO;
        url = @"";
		error = @"";
	}
	
	return self;
}

- (void)dealloc
{
	[email release];
	[password release];	
	[url release];
	[error release];
	[super dealloc];
}

- (BOOL)login
{
	if (email == nil || password == nil)
	{
		error = @"Email/Password was nil";
		return NO;
	}
	
	if (! [self network])
	{
		error = @"No network connection was available";
		return NO;
	}
	
	NSError *err;
	
	//creating the url request:
	NSURL *uploadEndpoint = [NSURL URLWithString:@"http://tinygrab.com/api/v3.php?m=user/verify"];
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
	[postBody appendData:[[NSString stringWithString:email] dataUsingEncoding:NSUTF8StringEncoding]];

	//PASSWORD
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"passwordhash\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:[self md5:password]] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//END
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:postBody];

	err = nil;
	NSURLResponse *response = nil;

	[NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&err];

	if (err != nil) {
		
		error = [err localizedDescription];
		return NO;
	}

	if (![response respondsToSelector:@selector(allHeaderFields)]) {

		error = @"Cant access headers (failed to cast)";
		return NO;
	}

	NSDictionary *dict = [response allHeaderFields];

	if (dict == nil) {

		error = @"Headers were empty";
		return NO;
	}
	
	#if defined(DEBUG)
	NSLog(@"DICT:\r\n\r\n%@", dict);
	#endif
	
	error = [dict objectForKey:@"X-Error-Text"]; // Will either update or set error to nill
	
	if (err != nil)
	{
		return NO;
	}
	
	return (session = YES);
}

- (NSString*)uploadFromFile:(NSString *)file
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:file])
	{
		error = @"Specified file not found";
		return @"";
	}
	
	
	return [self upload:[NSData dataWithContentsOfFile:file]];
}

- (NSString*)upload:(NSData*)image
{
	
	if (image == nil || email == nil || password == nil)
	{
        NSLog(@"image: %@\r\nemail: %@\r\npassword: %@", image, email, password);
        error = @"Image/Email/Password was nil";
		return @"";
	}
	
	if (!session && ![self login])
	{
		return NO;
	}
	
	if (! reachable && ![self network])
	{
		self.error = @"No network connection was available";
	}
	
	NSError *err;
	
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
	[postBody appendData:[[NSString stringWithString:email] dataUsingEncoding:NSUTF8StringEncoding]];

	//PASSWORD
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"passwordhash\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:[self md5:password]] dataUsingEncoding:NSUTF8StringEncoding]];

	//IMAGE
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n", [self generateName]] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:image]];

	//END
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:postBody];

	err = nil;
	NSURLResponse *response = nil;

	[NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&err];

	if (err != nil) {
		
		error = [err localizedDescription];
		return @"";
	}

	if (![response respondsToSelector:@selector(allHeaderFields)]) {

		error = @"Cant access headers (failed to cast)";
		return @"";
	}

	NSDictionary *dict = [response allHeaderFields];

	if (dict == nil) {

		error = @"Headers were empty";
		return @"";
	}
	
	#if defined(DEBUG)
	NSLog(@"DICT:\r\n\r\n%@", dict);
	#endif
	
	error = [dict objectForKey:@"X-Error-Text"]; // Will either update or set error to nill
	
	return (url = [dict objectForKey:@"X-Grab-Url"]);
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
	return (reachable = (conn && (flag & kSCNetworkFlagsReachable) && !(flag & kSCNetworkFlagsConnectionRequired)));
}
@end
