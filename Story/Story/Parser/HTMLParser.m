//
//  HTMLParser.m
//  Story
//
//  Created by Ravi shah on 12/09/15.
//  Copyright (c) 2015 myComp. All rights reserved.
//

#import "HTMLParser.h"


@implementation HTMLParser

- (HTMLNode*)doc
{
	if (_document == nil)
		return nil;
	
	return [[HTMLNode alloc] initWithXMLNode:(xmlNode*)_document];
}

- (HTMLNode*)html
{
	if (_document == nil)
		return nil;
	
	return [[self doc] findChildTag:@"html"];
}

- (HTMLNode*)head
{
	if (_document == nil)
		return nil;

	return [[self doc] findChildTag:@"head"];
}

- (HTMLNode*)body
{
    if (_document == nil)
        return nil;
	
	return [[self doc] findChildTag:@"body"];
}

- (id)initWithString:(NSString*)string error:(NSError**)err
{ 
	if (self = [super init])
	{
		_document = nil;
		
		if ([string length] > 0)
		{
			CFStringEncoding cfstrenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
			CFStringRef cfstrref = CFStringConvertEncodingToIANACharSetName(cfstrenc);
			const char *enc = CFStringGetCStringPtr(cfstrref, 0);
			int optionHtml = HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING;
			_document = htmlReadDoc ((xmlChar*)[string UTF8String], NULL, enc, optionHtml);
		}
		else 
		{
			if (err) {
				*err = [NSError errorWithDomain:@"HTMLdomain" code:1 userInfo:nil];
			}
		}
	}
	
	return self;
}

- (id)initWithData:(NSData*)data error:(NSError**)err
{
	if (self = [super init])
	{
		_document = nil;

		if (data)
		{
			CFStringEncoding cfstrenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
			CFStringRef cfstrref = CFStringConvertEncodingToIANACharSetName(cfstrenc);
			const char *enc = CFStringGetCStringPtr(cfstrref, 0);
			
			_document = htmlReadDoc((xmlChar*)[data bytes],
							 "",
							enc,
							XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
		}
		else
		{
			if (err)
			{
				*err = [NSError errorWithDomain:@"HTMLdomain" code:1 userInfo:nil];
			}

		}
	}
	
	return self;
}

- (id)initWithContentsOfURL:(NSURL*)url error:(NSError*__autoreleasing*)err
{
	
	NSData *_data = [[NSData alloc] initWithContentsOfURL:url options:0 error:err];

	if (_data == nil || err)
	{
		return nil;
	}
	
	self = [self initWithData:_data error:err];
	
	return self;
}


- (void)dealloc
{
	if (_document)
	{
		xmlFreeDoc(_document);
	}

}

@end
