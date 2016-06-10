//
//  CHAWayfindingRouteXMLParser.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/29/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHAWayfindingRouteXMLParser.h"
#import "CHAMapLocation.h"
#import "CHAVerticalPathInfo.h"
#import "CHAFloorPathInfo.h"
#import "CHARoute.h"
#import "CHADirectionSet.h"

@interface CHAWayfindingRouteXMLParser ()

@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *objectName;
@property (nonatomic, strong) NSMutableDictionary *routeInformation;

@end

@implementation CHAWayfindingRouteXMLParser

- (instancetype)init
{
    if (self = [super init])
    {
        _routeInformation = [NSMutableDictionary new];
        _nodes = [NSMutableArray new];
    }
    return self;
}
#pragma mark - NSXMLParsers Optional Delegate Methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.info = @"";
    
    NSString *sectionName = [attributeDict objectForKey:@"xsi:type"];
    if (sectionName)
    {
        self.objectName = sectionName;
    }
    
    if ([elementName.lowercaseString isEqualToString:@"fault"])
    {
        NSString *underlyingData = [[NSString alloc] initWithData:self.parserData encoding:NSUTF8StringEncoding];
//        NSLog(@"underlyingData: %@",underlyingData);
//        NSLog(@"\nparser %@\nelementName %@\nnamespaceURI %@\nqName %@", parser, elementName, namespaceURI, qName);
        
        if (self.errorHandler) {
            self.errorHandler([NSError errorWithDomain:@"com.MeetingPlay.GaylordHotels.RouteParsingError"
                                                  code:9999
                                              userInfo:@{NSLocalizedDescriptionKey: underlyingData}]);
        }
        
        [parser  abortParsing];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.info = [self.info stringByAppendingString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (!self.objectName)
    {
//        NSString *underlyingData = [[NSString alloc] initWithData:self.parserData encoding:NSUTF8StringEncoding];
//        NSLog(@"underlyingData: %@",underlyingData);
//        NSLog(@"\nparser %@\nelementName %@\nnamespaceURI %@\nqName %@", parser, elementName, namespaceURI, qName);
//        if (self.errorHandler)
//        {
//            self.errorHandler([NSError errorWithDomain:@"com.MeetingPlay.GaylordHotels.RouteParsingError"
//                                                  code:9999
//                                              userInfo:@{NSLocalizedDescriptionKey: underlyingData}]);
//
//        }
        
        [parser abortParsing];
        
        return;
    }
    
    if (self.info)
    {
        NSArray *routeDetails = [self.routeInformation objectForKey:self.objectName];
        if (!routeDetails) {
            routeDetails = [NSArray new];
        }
        routeDetails = [routeDetails arrayByAddingObject:@{elementName: self.info}];
        [self.routeInformation setObject:routeDetails forKey:self.objectName];
    }
    
    if ([elementName isEqualToString:@"anyType"])
    {
        NSDictionary *elementDictionary = [NSDictionary dictionaryWithDictionary:self.routeInformation];
        if (elementDictionary)
        {
            [self.nodes addObject:elementDictionary];
        }
        self.routeInformation = [NSMutableDictionary new];
    }
    
    self.info = @"";
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
//    [self printDebugDescriptions];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self parseBasicRoutingInformation:self.nodes];
//    NSLog(@"finished custom parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (self.errorHandler)
    {
        self.errorHandler(parseError);
        
//        NSString *underlyingData = [[NSString alloc] initWithData:self.parserData encoding:NSUTF8StringEncoding];
//        self.errorHandler([NSError errorWithDomain:@"com.MeetingPlay.GaylordHotels.RouteParsingError"
//                                              code:9999
//                                          userInfo:@{NSLocalizedDescriptionKey: underlyingData}]);
    }
//    [self printDebugDescriptions];
}

- (void)printDebugDescriptions
{
//    NSString *underlyingData = [[NSString alloc] initWithData:self.parserData encoding:NSUTF8StringEncoding];
    /*
    NSLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
          underlyingData);
     */
}

#pragma mark - Custom Class Creation
- (void)parseBasicRoutingInformation:(NSArray *)basicRoutingInformation
{
    __block NSMutableArray *allPoints = [NSMutableArray new];
    __block NSMutableArray *floorPathInfo = [NSMutableArray new];
    __block NSMutableArray *directions = [NSMutableArray new];
    
    for (id routeItem in basicRoutingInformation)
    {
        if ([routeItem isKindOfClass:[NSDictionary class]])
        {
            [routeItem enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
             {
                 if ([key isKindOfClass:[NSString class]])
                 {
                     if ([key isEqualToString:@"ArrayOfString"])
                     {
                         [allPoints addObjectsFromArray:obj];
                     }
                     else if ([key isEqualToString:@"FloorPathInfo"])
                     {
                         [floorPathInfo addObject:routeItem];
                     }
                     else if ([key isEqualToString:@"xsd:string"])
                     {
//                         [floorPathInfo addObject:routeItem];
                     }
                     else
                     {
                         [directions addObject:routeItem];
                     }
                 }
             }];
        }
        else
        {
            NSLog(@"%@",NSStringFromClass([basicRoutingInformation class]));
        }
    }
    
    NSArray *parsedDirections = [self directionInfo:directions];
    NSArray *parsedFloorPaths = [self floorPathInfo:floorPathInfo];
    NSArray *pointCollection = [CHAMapLocation mapLocationsFromSource:allPoints];

    CHARoute *newRoute = [CHARoute new];
    newRoute.mapPoints = pointCollection;
    newRoute.directions = parsedDirections;
    newRoute.floorPathInfo = parsedFloorPaths;
    
    [CHARoute identifyStepNodes:newRoute.floorPathInfo];
    
    if (self.parseCompletionHandler)
    {
        self.parseCompletionHandler(newRoute);
    }
}

- (NSArray *)floorPathInfo:(NSArray *)floorPathData
{
    NSMutableArray *parsedFloorPaths = [NSMutableArray new];
    
    [floorPathData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         for (NSString *pathInfoKey in obj)
         {
             if ([pathInfoKey isEqualToString:@"xsd:string"])
             {
                 id verticalInformation = [[[obj objectForKey:pathInfoKey] firstObject] objectForKey:@"anyType"];
                 if (verticalInformation)
                 {
                     NSDictionary *verticalPathComponents = [CHAVerticalPathInfo extractVerticalPathInfo:verticalInformation];
                     CHAVerticalPathInfo *verticalPathInfo = [CHAVerticalPathInfo verticalPathFromData:verticalPathComponents];
                     verticalPathInfo.rawDataString = verticalInformation;
                     if (verticalPathInfo)
                     {
                         [parsedFloorPaths addObject:verticalPathInfo];
                     }
                 }
             }
             else if ([pathInfoKey isEqual:@"FloorPathInfo"])
             {
                 NSArray *pathInfo = [obj objectForKey:@"FloorPathInfo"];
                 NSNumber *floorNumber = [CHAFloorPathInfo extractFloorNumber:pathInfo];
                 NSArray *pathNodes = [CHAFloorPathInfo pathNodesFromData:pathInfo];
                 
                 if (floorNumber && pathNodes)
                 {
                     if (pathNodes.count == 1)
                     {
                         NSLog(@"\npossible elevator %@", pathInfo);
                     }
                     else
                     {
                         CHAFloorPathInfo *floorPathInfo = [CHAFloorPathInfo floorPathWithFloor:floorNumber
                                                                                      pathNodes:pathNodes];
                         if (floorPathInfo)
                         {
                             [parsedFloorPaths addObject:floorPathInfo];
                         }
                         else
                         {
                             NSLog(@"\nno floor path info found %@", pathInfo);
                         }
                     }
                 }
                 else
                 {
                     NSLog(@"\nfloorNumber or pathNodes were nil %@", pathInfo);
                 }
             }
             else
             {
                 continue;
             }
         }
     }];
    
    return parsedFloorPaths;
}

- (NSArray *)directionInfo:(NSArray *)directionData
{
    NSMutableArray *directions = [NSMutableArray new];
    
    __block CHADirectionSet *newDirections = nil;
    __block BOOL shouldCombine = false;
    __block NSString *previousDirection = nil;
    
    // create direction sets, remove unnecessary ones, and join related direction set
    for (NSDictionary *directionSet in directionData)
    {
        __block BOOL addNewDirectionSet = true;
        
        NSArray *directionInformation = [directionSet objectForKey:@"Directions"];
        
        __block NSMutableArray *newDirectionInformation = [NSMutableArray new];
        
        [directionInformation enumerateObjectsUsingBlock:^(id directionDetailObject, NSUInteger idx, BOOL *stop)
        {
            __block NSMutableDictionary *newDirectionDetailObject = [NSMutableDictionary new];
            [directionDetailObject enumerateKeysAndObjectsUsingBlock:^(id detailKey, id details, BOOL *stop)
            {
                if ([detailKey isEqualToString:@"Text"])
                {
                    if ([details rangeOfString:@"departing floor " options:NSCaseInsensitiveSearch].location != NSNotFound
                        || [details rangeOfString:@"arrive at floor " options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        addNewDirectionSet = false;
                    }
                    else
                    {
                        if ([details rangeOfString:@"Continue on elevator passing floor " options:NSCaseInsensitiveSearch].location == NSNotFound
                            && [details rangeOfString:@"Continue on stairs passing floor " options:NSCaseInsensitiveSearch].location == NSNotFound
                            && [details rangeOfString:@"Continue on escalator passing floor " options:NSCaseInsensitiveSearch].location == NSNotFound)
                        {
                            NSString *newDirectionsText = details;
                            if (shouldCombine)
                            {
                                shouldCombine = false;
                                if (previousDirection.length > 0 && [details length] > 0)
                                {
                                    newDirectionsText = [previousDirection stringByAppendingString:[NSString stringWithFormat:@";%@",details]];
                                }
                            }
                            
                            if (newDirectionsText.length > 0)
                            {
                                [newDirectionDetailObject setObject:newDirectionsText forKey:detailKey];
                            }
                            
                            addNewDirectionSet = true;
                            previousDirection = @"";
                        }
                        else
                        {
                            addNewDirectionSet = false;
//                            shouldCombine = true;
                            
                            previousDirection = details;
                        }
                    }
                }
                else
                {
                    [newDirectionDetailObject setObject:details forKey:detailKey];
                }
            }];
            
            [newDirectionInformation addObject:newDirectionDetailObject];
        }];
        
        
        if (addNewDirectionSet)
        {
            // perform text substitutions
            newDirections = [CHADirectionSet directionsFromData:newDirectionInformation];
            [directions addObject:newDirections];
        }
        else
        {
//            NSLog(@"skip departing/arrive instruction");
        }
    }

    NSArray *directionSets = [NSArray arrayWithArray:directions];
    
    return directionSets;
}




























@end




