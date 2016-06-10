//
//  CHAWayfindingSOAPTask.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHAWayfindingSOAPTask.h"
#import "GAHDestination.h"
#import "CHADestination.h"

#import "CHAWayfindingRouteXMLParser.h"
#import "EventKeys.h"

@interface CHAWayfindingSOAPTask ()
@property (nonatomic, strong) NSString *responseString;
@end

@implementation CHAWayfindingSOAPTask

- (instancetype)initWithRequestType:(WayfindingRequestType)requestType
{
    self = [[CHAWayfindingSOAPTask alloc] init];
    if (self)
    {
        _wayfindingRequestType = requestType;
        _dataTask = [self sessionDataTask:requestType
                       bodyRequestOptions:@{@"ProjectUniqueId": [CHAWayfindingSOAPTask projectUniqueID]}];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _searchLimitedAccessOnly = false;
    }
    return self;
}

- (NSMutableURLRequest *)request:(WayfindingRequestType)requestType
              bodyRequestOptions:(NSDictionary *)bodyRequestOptions
{
    NSMutableURLRequest *wayfindingRequest = [[NSMutableURLRequest alloc]
                                              initWithURL:[NSURL URLWithString:@"http://api.wayfindingpro.com/websiteapi.asmx"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:30];
    
    [wayfindingRequest setValue:@"text/xml"
             forHTTPHeaderField:@"Content-Type"];

    [wayfindingRequest setHTTPMethod:@"POST"];
    
    NSString *soapXMLRequestBody = [self xmlRequestEnvelopeStart];
    if ([self shouldIncludeAuthHeader:requestType])
    {
        soapXMLRequestBody = [soapXMLRequestBody stringByAppendingString:[self soapAuthHeader]];
    }
    soapXMLRequestBody = [soapXMLRequestBody stringByAppendingString:[self soapBodyRequest:requestType
                                                                            requestOptions:bodyRequestOptions]];
    soapXMLRequestBody = [soapXMLRequestBody stringByAppendingString:[self xmlRequestEnvelopeClose]];
    
    [wayfindingRequest setHTTPBody:[soapXMLRequestBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    return wayfindingRequest;
}

- (NSURLSessionDataTask *)sessionDataTask:(WayfindingRequestType)requestType
                       bodyRequestOptions:(NSDictionary *)bodyRequestOptions
{
    self.wayfindingRequestType = requestType;
    
    return [[NSURLSession sharedSession] dataTaskWithRequest:[self request:requestType bodyRequestOptions:bodyRequestOptions]
                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
            {
                if (error)
                {
                    if (self.defaultXMLParserCompletionHandler)
                    {
                        self.defaultXMLParserCompletionHandler(nil);
                    }
                    return;
                }
                
                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (dataString.length > 0)
                {
                    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];

                    if (self.customXMLParser)
                    {
                        xmlParser.delegate = self.customXMLParser;
                        [(CHAWayfindingRouteXMLParser *)self.customXMLParser setParserData:data];
                    }
                    else
                    {
                        xmlParser.delegate = self;
                    }
                    
                    [xmlParser parse];
                }
                else
                {
                    NSLog(@"\nerror creating a string from the data %@", response);
                }
            }];
}

- (void)startTask
{
    self.responseString = @"";
    [self.dataTask resume];
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.responseString = [self.responseString stringByAppendingString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"finished default parsing");
    
    self.responseString = [self.responseString stringByReplacingOccurrencesOfString:@"}{" withString:@"},{"];
    if ([self.responseString rangeOfString:@"["].location != 0)
    {
        self.responseString = [NSString stringWithFormat:@"[%@]",self.responseString];
    }
    
    NSError *serializationError = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:[self.responseString dataUsingEncoding:NSUTF8StringEncoding]
                                             options:NSJSONReadingAllowFragments
                                               error:&serializationError];
    if (serializationError)
    {
        NSLog(@"\nserialization error %@", serializationError);
    }
    
    self.fetchedData = obj;
    
    if (self.defaultXMLParserCompletionHandler)
    {
        self.defaultXMLParserCompletionHandler(obj);
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"default parsing error %@",parseError);
    if (self.defaultXMLParserCompletionHandler)
    {
        self.defaultXMLParserCompletionHandler(nil);
    }
}

#pragma mark - Request Setup

- (NSString *)soapAuthHeader
{
    /*
    <UserName>string</UserName>
    <Password>string</Password>
    <ApiKey>string</ApiKey>
    <isManager>string</isManager>
    <isKiosk>string</isKiosk> <LimitToAccessibleRoutes>string</LimitToAccessibleRoutes>
     */
    id accessibleOption = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessibleOnlyDirections];
    BOOL accessibleOnly = accessibleOption ? [accessibleOption boolValue] : false;
    
    NSString *fetchAccessibleOnly = accessibleOnly ? @"true" : @"false";
    
    return [NSString stringWithFormat:
            @"<soap12:Header><AuthHeader xmlns=\"http://api.wayfindingpro.com\">"
            "<LimitToAccessibleRoutes>%@</LimitToAccessibleRoutes>"
            "</AuthHeader>"
            "</soap12:Header>",
            fetchAccessibleOnly];
}

- (NSString *)soapBodyRequest:(WayfindingRequestType)requestType
               requestOptions:(NSDictionary *)requestOptions
{
    NSString *soapBody = @"<soap12:Body>";
    soapBody = [soapBody stringByAppendingString:[self requestForType:requestType requestOptions:requestOptions]];
    soapBody = [soapBody stringByAppendingString:@"</soap12:Body>"];

    return soapBody;
}

- (NSString *)requestForType:(WayfindingRequestType)requestType
              requestOptions:(NSDictionary *)requestOptions
{
    NSString *requestBody;
    
    switch (requestType)
    {
        case WayfindingRequestTypeGetDestinations:
        {
            requestBody = [self getDestinationsBody:requestOptions];
            break;
        }
        case WayfindingRequestTypeGetGroupedDestinationsAndPOI:
        {
            requestBody = [self getGroupedDestinationsAndPOI:requestOptions];
            break;
        }
        case WayfindingRequestTypeGetMapImageByName:
        {
            requestBody = [self getMapImageByName:requestOptions];
            break;
        }
        case WayfindingRequestTypeGetMapImageURLs:
        {
            requestBody = [self getMapImageURLBody:requestOptions];
            break;
        }
        case WayfindingRequestTypeGetPath:
        {
            requestBody = [self getPath:requestOptions];
            break;
        }
        default:
            break;
    }
    
    return requestBody;
}
#pragma mark - Request Body Types
- (NSString *)getDestinationsBody:(NSDictionary *)bodyParameters
{
    return [NSString stringWithFormat:
            @"<GetDestinations xmlns=\"http://api.wayfindingpro.com\">%@</GetDestinations>",
            [self serializeBodyParameters:bodyParameters]];
}

- (NSString *)getGroupedDestinationsAndPOI:(NSDictionary *)bodyParameters
{
    return [NSString stringWithFormat:
            @"<GetGroupedDestinationsAndPoi xmlns=\"http://api.wayfindingpro.com\">%@</GetGroupedDestinationsAndPoi>",
            [self serializeBodyParameters:bodyParameters]];
}

- (NSString *)getMapImageByName:(NSDictionary *)bodyParameters
{
    return [NSString stringWithFormat:
            @"<GetMapImageByName xmlns=\"http://api.wayfindingpro.com\">%@</GetMapImageByName>",
            [self serializeBodyParameters:bodyParameters]];
}

- (NSString *)getMapImageURLBody:(NSDictionary *)bodyParameters
{
    return [NSString stringWithFormat:
            @"<GetMapImageUrls xmlns=\"http://api.wayfindingpro.com\">%@</GetMapImageUrls>",
           [self serializeBodyParameters:bodyParameters]];
}

- (NSString *)getPath:(NSDictionary *)bodyParameters
{
    NSString *failure = [NSString stringWithFormat:
                         @"<GetPath xmlns=\"http://api.wayfindingpro.com\">%@</GetPath>",
                         [self serializeBodyParameters:bodyParameters]];
    return failure;
}

#pragma mark - Request Building and Serialization
- (NSString *)serializeBodyParameters:(NSDictionary *)bodyParameters
{
    __block NSString *bodyParameterString = @"";
    [bodyParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isKindOfClass:[NSString class]])
         {
             if ([obj isKindOfClass:[NSString class]]
                 || [obj isKindOfClass:[NSNumber class]])
             {
                 bodyParameterString = [bodyParameterString stringByAppendingFormat:@"<%@>%@</%@> ",key,obj,key];
             }
         }
     }];
    return bodyParameterString;
}

- (BOOL)shouldIncludeAuthHeader:(WayfindingRequestType)requestType
{
    switch (requestType)
    {
        case WayfindingRequestTypeGetMapImageByName:
        case WayfindingRequestTypeGetPath:
        {
            return true;
            break;
        }
        case WayfindingRequestTypeGetDestinations:
        case WayfindingRequestTypeGetGroupedDestinationsAndPOI:
        case WayfindingRequestTypeGetMapImageURLs:
        case WayfindingRequestTypeGetMultiFloorImage:
        case WayfindingRequestTypeGetMultiFloorNodeYOffsets:
        case WayfindingRequestTypeGetPoiImages:
        case WayfindingRequestTypeGetProjectNameFromUniqueID:
        case WayfindingRequestTypeGetProjectOwnerStatus:
        default:
        {
            return false;
            break;
        }
    }
}

- (NSString *)xmlRequestEnvelopeStart
{
    return @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
    "xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\"> ";
}

- (NSString *)xmlRequestEnvelopeClose
{
    return @"</soap12:Envelope>";
}

+ (NSString *)projectUniqueID
{
    return @"dcWdiqLu";
}

- (NSString *)actionForRequestType:(WayfindingRequestType)requestType
{
    NSDictionary *actions = @{@(WayfindingRequestTypeGetDestinations): @"GetDestinations",
                              @(WayfindingRequestTypeGetGroupedDestinationsAndPOI): @"GetGroupedDestinationsAndPOI",
                              @(WayfindingRequestTypeGetMapImageByName): @"GetMapImageByName",
                              @(WayfindingRequestTypeGetMapImageURLs): @"GetMapImageURLs",
                              @(WayfindingRequestTypeGetMultiFloorImage): @"GetMultiFloorImage",
                              @(WayfindingRequestTypeGetMultiFloorNodeYOffsets): @"GetMultiFloorNodeYOffsets",
                              @(WayfindingRequestTypeGetPath): @"GetPath",
                              @(WayfindingRequestTypeGetPoiImages): @"GetPoiImages",
                              @(WayfindingRequestTypeGetProjectNameFromUniqueID): @"GetProjectNameFromUniqueId",
                              @(WayfindingRequestTypeGetProjectOwnerStatus): @"GetProjectOwnerStatus"};
    
    NSString *actionForKey = [actions objectForKey:@(requestType)];
    
    return [NSString stringWithFormat:@"http://api.wayfindingpro.com/%@",actionForKey];
}


#pragma mark - Convenience Initializers
+ (instancetype)getPathStartFloor:(NSNumber *)startFloor
                 startXCoordinate:(NSNumber *)startX
                 startYCoordinate:(NSNumber *)startY
                         endFloor:(NSNumber *)endFloor
                   endXCoordinate:(NSNumber *)endX
                             endY:(NSNumber *)endY
{
    CHAWayfindingSOAPTask *task = [[CHAWayfindingSOAPTask alloc] init];
    
    if ([startFloor isKindOfClass:[NSNumber class]] && [endFloor isKindOfClass:[NSNumber class]])
    {
        NSMutableDictionary *bodyOptions = [NSMutableDictionary new];
        
        [bodyOptions setObject:[self projectUniqueID] forKey:@"ProjectUniqueId"];
        [bodyOptions setObject:@(0) forKey:@"BuildingID"];
        
        [bodyOptions setObject:startFloor forKey:@"StartFloor"];
        [bodyOptions setObject:[NSString stringWithFormat:@"%@,%@",startX,startY]
                        forKey:@"StartLocation"];
        
        [bodyOptions setObject:endFloor forKey:@"EndFloor"];
        [bodyOptions setObject:[NSString stringWithFormat:@"%@,%@",endX,endY]
                        forKey:@"EndLocation"];

        [bodyOptions setObject:@(false) forKey:@"DoReturnOffsetNodes"];
        
        task.dataTask = [task sessionDataTask:WayfindingRequestTypeGetPath
                           bodyRequestOptions:bodyOptions];
    }
    return task;
}

+ (instancetype)getDestinations:(NSString *)buildingID
{
    CHAWayfindingSOAPTask *task = [[CHAWayfindingSOAPTask alloc] init];
    NSMutableDictionary *bodyOptions = [NSMutableDictionary new];
    [bodyOptions setObject:[self projectUniqueID] forKey:@"ProjectUniqueId"];
    if (buildingID)
    {
        [bodyOptions setObject:buildingID forKey:@"BuildingID"];
    }
    task.dataTask = [task sessionDataTask:WayfindingRequestTypeGetDestinations
                       bodyRequestOptions:bodyOptions];
    return task;
}

+ (instancetype)getGroupedDestinationsAndPOI:(NSString *)buildingID
                             splitIntoGroups:(BOOL)splitIntoGroups
{
    CHAWayfindingSOAPTask *task = [[CHAWayfindingSOAPTask alloc] init];
    NSMutableDictionary *bodyOptions = [NSMutableDictionary new];
    [bodyOptions setObject:[self projectUniqueID] forKey:@"ProjectUniqueId"];
    if (buildingID)
    {
        [bodyOptions setObject:buildingID forKey:@"BuildingID"];
    }
    [bodyOptions setObject:@(splitIntoGroups) forKey:@"DoSplitIntoGroups"];
    
    task.dataTask = [task sessionDataTask:WayfindingRequestTypeGetGroupedDestinationsAndPOI
                       bodyRequestOptions:bodyOptions];
    return task;
}

+ (instancetype)getMultiFloorNodeYOffsets:(NSString *)buildingID
{
    CHAWayfindingSOAPTask *task = [[CHAWayfindingSOAPTask alloc] init];
    NSMutableDictionary *bodyOptions = [NSMutableDictionary new];
    [bodyOptions setObject:[self projectUniqueID] forKey:@"ProjectUniqueId"];
    if (buildingID)
    {
        [bodyOptions setObject:buildingID forKey:@"BuildingID"];
    }
    task.dataTask = [task sessionDataTask:WayfindingRequestTypeGetMultiFloorNodeYOffsets
                       bodyRequestOptions:bodyOptions];
    return task;
}

@end