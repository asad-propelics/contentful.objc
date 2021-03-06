//
//  CDAField.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import ObjectiveC.runtime;

#import "CDAResource.h"

#import "CDAField+Private.h"
#import "CDAFieldValueTransformer.h"
#import "CDAUtilities.h"

@interface CDAField ()

@property (nonatomic, weak) CDAClient* client;
@property (nonatomic) BOOL disabled;
@property (nonatomic, readonly) NSDictionary* fieldTypes;
@property (nonatomic) NSString* identifier;
@property (nonatomic) CDAFieldType itemType;
@property (nonatomic) BOOL localized;
@property (nonatomic) BOOL required;
@property (nonatomic) CDAFieldValueTransformer* transformer;

@end

#pragma mark -

@implementation CDAField

+(BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark -

-(NSString *)description {
    NSString* type = [[self.fieldTypes allKeysForObject:@(self.type)] firstObject];
    return [NSString stringWithFormat:@"CDAField %@ of type %@", self.identifier, type];
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary* rep = [@{ @"id": self.identifier,
                                   @"name": self.name } mutableCopy];

    switch (self.type) {
        case CDAFieldTypeAsset:
        case CDAFieldTypeEntry:
            rep[@"type"] = [self fieldTypeToString:CDAFieldTypeLink];
            rep[@"linkType"] = [self fieldTypeToString:self.type];
            break;

        case CDAFieldTypeArray:
        case CDAFieldTypeBoolean:
        case CDAFieldTypeDate:
        case CDAFieldTypeInteger:
        case CDAFieldTypeLink:
        case CDAFieldTypeLocation:
        case CDAFieldTypeNone:
        case CDAFieldTypeNumber:
        case CDAFieldTypeObject:
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText:
            rep[@"type"] = [self fieldTypeToString:self.type];
            break;
    }

    switch (self.itemType) {
        case CDAFieldTypeNone:
            break;
        case CDAFieldTypeAsset:
        case CDAFieldTypeEntry:
            if (self.type == CDAFieldTypeLink) {
                rep[@"linkType"] = [self fieldTypeToString:self.itemType];
            } else {
                rep[@"items"] = @{ @"type": [self fieldTypeToString:CDAFieldTypeLink],
                                   @"linkType": [self fieldTypeToString:self.itemType] };
            }
            break;
        case CDAFieldTypeArray:
        case CDAFieldTypeBoolean:
        case CDAFieldTypeDate:
        case CDAFieldTypeInteger:
        case CDAFieldTypeLink:
        case CDAFieldTypeLocation:
        case CDAFieldTypeNumber:
        case CDAFieldTypeObject:
        case CDAFieldTypeSymbol:
        case CDAFieldTypeText:
            rep[@"items"] = @{ @"type": [self fieldTypeToString:self.itemType] };
            break;
    }

    return rep;
}

-(NSDictionary*)fieldTypes {
    static dispatch_once_t once;
    static NSDictionary* fieldTypes;
    dispatch_once(&once, ^ { fieldTypes = @{
                                            @"Array": @(CDAFieldTypeArray),
                                            @"Boolean": @(CDAFieldTypeBoolean),
                                            @"Date": @(CDAFieldTypeDate),
                                            @"Integer": @(CDAFieldTypeInteger),
                                            @"Link": @(CDAFieldTypeLink),
                                            @"Location": @(CDAFieldTypeLocation),
                                            @"Number": @(CDAFieldTypeNumber),
                                            @"Object": @(CDAFieldTypeObject),
                                            @"Symbol": @(CDAFieldTypeSymbol),
                                            @"Text": @(CDAFieldTypeText),
                                            @"Entry": @(CDAFieldTypeEntry),
                                            @"Asset": @(CDAFieldTypeAsset),
                                            }; });
    return fieldTypes;
}

-(NSString*)fieldTypeToString:(CDAFieldType)fieldType {
    NSArray* possibleFieldTypes = [self.fieldTypes allKeysForObject:@(fieldType)];
    NSAssert(possibleFieldTypes.count == 1,
             @"Field-type %ld lacks proper string representation.", (long)fieldType);
    return possibleFieldTypes[0];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
                           client:(CDAClient*)client
            localizationAvailable:(BOOL)localizationAvailable {
    self = [super init];
    if (self) {
        NSParameterAssert(client);
        self.client = client;
        
        if (dictionary[@"id"]) {
            NSString* identifier = dictionary[@"id"];
            self.identifier = identifier;
        } else {
            [NSException raise:NSInvalidArgumentException format:@"Fields need an identifier"];
        }

        self.name = dictionary[@"name"];
        
        NSString* itemType = dictionary[@"items"][@"linkType"] ?: dictionary[@"linkType"];
        if (itemType) {
            self.itemType = [self stringToFieldType:itemType];
        } else {
            itemType = dictionary[@"items"][@"type"];
            self.itemType = itemType ? [self stringToFieldType:itemType] : CDAFieldTypeNone;
        }
        
        self.type = [self stringToFieldType:dictionary[@"type"]];
        
        self.disabled = [dictionary[@"disabled"] boolValue];
        self.localized = [dictionary[@"localized"] boolValue];
        self.required = [dictionary[@"required"] boolValue];
        
        self.transformer = [CDAFieldValueTransformer transformerOfType:self.type
                                                                client:self.client
                                                 localizationAvailable:localizationAvailable];
        self.transformer.itemType = self.itemType;
    }
    return self;
}

-(id)parseValue:(id)value {
    return [self.transformer transformedValue:value];
}

-(CDAFieldType)stringToFieldType:(NSString*)string {
    NSNumber* fieldTypeNumber = self.fieldTypes[string];
    NSAssert(fieldTypeNumber, @"Unknown field-type '%@'", string);
    return [fieldTypeNumber integerValue];
}

// We only encode properties that have write permissions
#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {

        self.name       = [aDecoder decodeObjectForKey:@"name"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];

        self.disabled   = [aDecoder decodeBoolForKey:@"disabled"];
        self.localized  = [aDecoder decodeBoolForKey:@"localized"];
        self.required   = [aDecoder decodeBoolForKey:@"required"];

        self.itemType   = [aDecoder decodeIntegerForKey:@"itemType"];
        self.type       = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];

    [aCoder encodeBool:self.disabled forKey:@"disabled"];
    [aCoder encodeBool:self.localized forKey:@"localized"];
    [aCoder encodeBool:self.required forKey:@"required"];

    [aCoder encodeInteger:self.itemType forKey:@"itemType"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

@end
