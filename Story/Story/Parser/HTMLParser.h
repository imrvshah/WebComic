//
//  HTMLParser.h
//  Story
//
//  Created by Ravi shah on 12/09/15.
//  Copyright (c) 2015 myComp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNode.h"

@class HTMLNode;

@interface HTMLParser : NSObject 
{
	htmlDocPtr _document;
}

- (id)initWithContentsOfURL:(NSURL*)url error:(NSError**)error;
- (id)initWithData:(NSData*)data error:(NSError**)error;
- (id)initWithString:(NSString*)string error:(NSError**)error;

- (HTMLNode*)doc;
- (HTMLNode*)body;
- (HTMLNode*)html;
- (HTMLNode*)head;

@end
