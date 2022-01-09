//
//  RSSParser.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/09/28.
//  
//

#import "RSSParser.h"
#import "Item.h"
#import "NSData.h"
#include <libxml/parser.h>
#include <libxml/xpath.h>

@interface RSSParser()

@end

@implementation RSSParser

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)parseWithURL:(NSURL*)url completionHandler:(void (^)(NSArray* items, NSError* error))completionHandler {
    __block NSArray *items = @[];//[[NSMutableArray alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.timeoutInterval = 5;
    request.HTTPMethod = @"GET";
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data){
            NSString *result = [[NSString alloc] initWithData:data encoding:data.stringEncoding];
            if (result){
                items = [self parseXML:result];
            }
        }
        completionHandler(items,error);
    }];
    
    [task resume];
}

- (NSArray*)parseXML: (NSString * _Nonnull)data {
    xmlDocPtr document = xmlParseMemory([data UTF8String], (int)[data lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    if(!document)return @[];
    
    xmlXPathContextPtr context = xmlXPathNewContext(document);
    if(!context)return @[];

    xmlXPathObjectPtr object = xmlXPathEvalExpression((xmlChar *)"//item", context);
    if(!object)return @[];
    
    xmlNodeSetPtr nodes = object->nodesetval;
    int size = (nodes) ? nodes->nodeNr : 0;
    
    NSMutableArray *items = [NSMutableArray array];
    for(int i = 0; i<size; i++){
        xmlNodePtr node = xmlXPathNodeSetItem(nodes, i);
        Item *item = [self convertToItem:node];
        [items addObject:item];
    }
    
    return items;
}

- (Item*)convertToItem: (xmlNodePtr)node {
    xmlNodePtr curNode = xmlFirstElementChild(node);
    Item *item = [[Item alloc] init];
    for (; curNode; curNode = xmlNextElementSibling(curNode)) {
        if (curNode == NULL) {
            continue;
        }
        NSString *content = [[NSString alloc] initWithCString:(char*)xmlNodeGetContent(curNode) encoding:NSUTF8StringEncoding];
        NSString *name = [[NSString alloc] initWithCString:(char*)curNode->name encoding:NSUTF8StringEncoding];
        
        if([name isEqualToString:@"title"]) item.title = content;
        if([name isEqualToString:@"link"]) item.link = content;
        if([name isEqualToString:@"pubDate"]) item.pubDate = content;
        if([name isEqualToString:@"description"]) item.itemDescription = content;
    }
    
    return item;
}



@end
