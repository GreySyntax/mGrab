//
//  mGrab.h
//  Pneumonia
//
//  Created by GreySyntax.
//  Copyright 2010-2011 NSPwn. All rights reserved.
//

#import <SystemConfiguration/SCNetworkReachability.h>
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>
#import <openssl/md5.h>
#import <netinet/in.h>

@interface mGrab : NSObject
{
	NSString *url;
	NSString *error;
	
@private BOOL session;
@private BOOL reachable;
@private NSString *email;
@private NSString *password;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *error;

#pragma mark -
#pragma mark Core
- (id)init;
- (id)initWithEmail:(NSString*)useremail andPassword:(NSString*)userpassword;
- (BOOL)login;
- (NSString*)uploadFromFile:(NSString*)file;
- (NSString*)upload:(NSData*)image;

#pragma mark -
#pragma mark Common
- (NSString*)generateName;
- (NSString*)md5:(NSString*)chunk;
- (BOOL)network;
@end