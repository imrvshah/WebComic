//
//  HTMLNode.h
//  Story
//
//  Created by Ravi shah on 12/09/15.
//  Copyright (c) 2015 myComp. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <libxml/HTMLparser.h>
#import "HTMLParser.h"

@class HTMLParser;

#define ParsingDepthUnlimited 0
#define ParsingDepthSame -1
#define ParsingDepth size_t

typedef enum
{
	HTMLHrefNode,
	HTMLTextNode,
	HTMLUnkownNode,
	HTMLCodeNode,
	HTMLSpanNode,
	HTMLPNode,
	HTMLLiNode,
	HTMLUlNode,
	HTMLImageNode,
	HTMLOlNode,
	HTMLStrongNode,
	HTMLPreNode,
	HTMLBlockQuoteNode,
} HTMLNodeType;

@interface HTMLNode : NSObject 
{
@public
	xmlNode *_node;
}

- (id)initWithXMLNode:(xmlNode *)xmlNode;
- (HTMLNode *)findChildOfClass:(NSString *)className;
- (NSArray *)findChildrenOfClass:(NSString *)className;

//Finds a single child with a matching attribute 
//set allowPartial to match partial matches 
//e.g. <img src="http://www.google.com> [findChildWithAttribute:@"src" matchingName:"google.com" allowPartial:TRUE]
- (HTMLNode *)findChildWithAttribute:(NSString *)attribute matchingName:(NSString *)className allowPartial:(BOOL)partial;

- (NSArray *)findChildrenWithAttribute:(NSString *)attribute matchingName:(NSString *)className allowPartial:(BOOL)partial;

- (NSString *)getAttributeNamed:(NSString *)name;

- (NSArray *)findChildTags:(NSString *)tagName;

- (HTMLNode *)findChildTag:(NSString *)tagName;

- (HTMLNode *)firstChild;

- (NSString *)contents;

- (NSString *)allContents;

- (NSString *)rawContents;

- (HTMLNode *)nextSibling;

- (HTMLNode *)previousSibling;

- (NSString *)className;

- (NSString *)tagName;

- (HTMLNode *)parent;

- (NSArray *)children;

- (HTMLNodeType)nodetype;

NSString *getAttributeNamed(xmlNode *node, const char *nameStr);
void setAttributeNamed(xmlNode *node, const char *nameStr, const char *value);
HTMLNodeType nodeType(xmlNode *node);
NSString *allNodeContents(xmlNode *node);
NSString *rawContentsOfNode(xmlNode *node);


@end
