//
//  ViewController.m
//  Story
//
//  Created by Ravi shah on 12/09/15.
//  Copyright (c) 2015 myComp. All rights reserved.
//

#import "ViewController.h"
#import "HTMLParser.h"
#import "StoryDetailModel.h"

#define kBASIC_URL @"http://xkcd.com"
//http://xkcd.com/611/
@interface ViewController ()<NSXMLParserDelegate>
{
    NSMutableArray *elementsArray;
    NSMutableString *currentString;
}
- (IBAction)nextPressed:(id)sender;
- (IBAction)randomPressed:(id)sender;
- (IBAction)previousPressed:(id)sender;

@property (nonatomic) StoryDetailModel *storyModel;
@property (nonatomic) NSUInteger maxNumber;
@property (nonatomic) NSUInteger minNumber;
@property (weak, nonatomic) IBOutlet UIImageView *storyImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.minNumber = 1;
    self.maxNumber = 2;
    self.storyModel = [StoryDetailModel new];
    // Do any additional setup after loading the view, typically from a nib.
    //    [self parserInHTML];
    [self parseXML];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Utility Fuctions

/**
 It will open next story
 @param UIbuttonBar
 @return none
 */
- (IBAction)nextPressed:(id)sender {
    if (self.storyModel) {
        [self parserInHTMLForURLString:self.storyModel.nextIdString];
    }
}
/**
 It will open random story
 @param UIbuttonBar
 @return none
 */
- (IBAction)randomPressed:(id)sender {
    [self parserInHTMLForURLString:[self randomURL]];
}
/**
 It will open previous story
 @param UIbuttonBar
 @return none
 */
- (IBAction)previousPressed:(id)sender {
    if (self.storyModel) {
        [self parserInHTMLForURLString:self.storyModel.prevIdString];
    }
}
/**
 It will open random URL
 @param none
 @return Random URL string
 */
- (NSString *)randomURL {
    NSInteger randomIndex = [self randomNumberBetween:self.minNumber maxNumber:self.maxNumber];
    NSString *urlString = [NSString stringWithFormat:@"%@/%ld/",kBASIC_URL,(long)randomIndex];
    return urlString;
}
/**
 Find random Number
 @param Minimum number and Maximum number
 @returnnumber as NSUInteger
 */
- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random() % (max-min+1);//arc4random_uniform(max - min + 1);
}


#pragma mark HTML Parsing

/**
 Strat to pass HTM string
 @param URL as a string
 @return none
 */
- (void)parserInHTMLForURLString:(NSString *)urlString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        HTMLParser *htmlParser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] error:nil];
        HTMLNode *body = [htmlParser body];
        HTMLNode *title = [body findChildWithAttribute:@"id" matchingName:@"ctitle" allowPartial:true];
        NSLog(@"%@",[title allContents]);
        HTMLNode *comic = [body findChildWithAttribute:@"id" matchingName:@"comic" allowPartial:true];
        HTMLNode *img = [comic findChildWithAttribute:@"src" matchingName:@"" allowPartial:true];
        NSString *imgLink = [NSString stringWithFormat:@"http:%@",[img getAttributeNamed:@"src"]];
        NSLog(@"%@",imgLink);
        
        HTMLNode *prev = [body findChildWithAttribute:@"rel" matchingName:@"prev" allowPartial:true];
        NSString *prevId = [NSString stringWithFormat:@"%@%@",kBASIC_URL,[prev getAttributeNamed:@"href"]];
        NSLog(@"%@",prevId);
        HTMLNode *next = [body findChildWithAttribute:@"rel" matchingName:@"next" allowPartial:true];
        NSString *nextId = [NSString stringWithFormat:@"%@%@",kBASIC_URL,[next getAttributeNamed:@"href"]];
        NSLog(@"%@",nextId);
        
        self.storyModel.title = [title allContents];
        self.storyModel.imageURL = imgLink;
        self.storyModel.nextIdString = nextId;
        self.storyModel.prevIdString = prevId;
        
        [self updateUI:self.storyModel];
    });
}
/**
 When we finished parsing this function is used update our UI
 @param StoryModel
 @return none
 */
- (void)updateUI:(StoryDetailModel *)model {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = model.title;
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.storyImageView.image = [UIImage imageWithData:data];
        });
    });
}

#pragma mark-XML Parsing

//http://xkcd.com/rss.xml

/**
 Start to Pass XML
 @param StoryModel
 @return none
 */
- (void)parseXML {
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rss.xml",kBASIC_URL]]];//init NSXMLParser with receivedXMLData
    [xmlParser setDelegate:self]; // Set delegate for NSXMLParser
    [xmlParser parse]; //Start parsing
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    elementsArray = [[NSMutableArray alloc] init];
}

/**
 store all found characters between elements in currentString mutable string
 @param Found character string
 @return none
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!currentString)
    {
        currentString = [[NSMutableString alloc] init];
    }
    [currentString appendString:string];
}

/**
 When end of XML tag is found this method gets notified
 @param Element name, URI and Qualified name
 @return none
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"link"])
    {
        [elementsArray addObject:currentString];
        currentString=nil;
        return;
    }
    
    currentString =nil;
}

/**
 Parsing has ended
 @param parser
 @return none
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"Content of Elements Array: %@",elementsArray);
    
    NSMutableArray *ids = [NSMutableArray array];
    for (NSString *url in elementsArray) {
        NSString *idStr = [[url componentsSeparatedByString:[kBASIC_URL stringByAppendingString:@"/"]].lastObject stringByReplacingOccurrencesOfString:@"/" withString:@""];
        [ids addObject:@(idStr.integerValue)];
    }
    
    float xmax = -MAXFLOAT;
    for (NSNumber *num in ids) {
        NSUInteger x = num.integerValue;
        if (x > xmax) xmax = x;
    }
    
    self.maxNumber = xmax;
    elementsArray=nil;
    
    [self parserInHTMLForURLString:[self randomURL]];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    UIAlertView* parseErrorAlert = [[UIAlertView alloc] initWithTitle:@"Parse Error" message:[NSString stringWithFormat:@"%@",[parseError localizedDescription]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [parseErrorAlert show];
}


@end
