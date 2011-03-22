What is mGrab?
================================
mGrab is a miniature API wrapper for TinyGrab '2.0', this was origonally developed by [NSPwn](http://www.nspwn.com) for SB2Cloud. This is designed to work within SpringBoard on iOS so yeah it might not work for you.

How do i use it?
================================
The implementation file is self explanatory. [mGrab error] will contain the last error message, [mGrab url] will return the url of the last upload.

	mGrab *grab = [[mGrab alloc] initWithEmail:@"testuser@yoursite.com" andPassword:@"password"];
	
	if (! [grab login])
	{
		//Failed to login
		return NO;
	}
	
	NSString *url = [grab upload:@"/Users/somebody/Desktop/NicePicture.png"];
	
	if (url != nil)
	{
		//Sweet everything worked, url returned
		return url;
	}
	
	NSLog(@"mGrab error: %@", [mGrab error]);
	return @"";