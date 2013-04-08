//
//  CCTContactsReader.m
//
//  Created by Weipin Xia on 4/8/13.
//  Copyright (c) 2013 Weipin Xia. All rights reserved.
//

#import "CCTContactsReader.h"

@implementation CCTContactsReader

ABPropertyID ABPropertyFromCCTContactsReaderABProperty(CCTContactsReaderABPropertyID property) {
    ABPropertyID propertyID = 0;
    
    if (CCTContactsReaderABPersonEmailProperty == property) {
        propertyID = kABPersonEmailProperty;
    } else if (CCTContactsReaderABPersonPhoneProperty == property) {
        propertyID = kABPersonPhoneProperty;
    } else {
        NSCAssert(NO, @"Invalid CCTContactsReaderABPropertyID value");
    }
    
    return propertyID;
}

+ (NSDictionary *)obtainDataFromAddressbook:(ABAddressBookRef)addressbook forPropertyKeys:(NSArray *)propertyKeys {
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressbook);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
    for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        NSMutableDictionary *personDict = [NSMutableDictionary dictionary];
    
        for (NSNumber *k in propertyKeys) {
            ABMultiValueRef property = ABRecordCopyValue(person, ABPropertyFromCCTContactsReaderABProperty([k integerValue]));
            if (!property) {
                continue;
            }
            NSMutableArray *values = [NSMutableArray array];
            for (CFIndex j = 0; j < ABMultiValueGetCount(property); j++) {
                id value = CFBridgingRelease(ABMultiValueCopyValueAtIndex(property, j));
                [values addObject:value];
            }
            CFRelease(property);
            personDict[k] = values;
        }
        
        ABRecordID record_id = ABRecordGetRecordID(person);
        dict[@(record_id)] = personDict;
    }

    CFRelease(people);
    return dict;
}

- (void)obtainDataFromAddressbook:(NSArray *)propertyKeys {
    if (ABAddressBookGetAuthorizationStatus) {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (kABAuthorizationStatusNotDetermined == status
            || kABAuthorizationStatusAuthorized == status) {
      
        } else {
            [self.delegate contactsReader:self didObtainData:nil authorizationStatus:status error:nil];
            return;
        }    
    }
  
    if (ABAddressBookCreateWithOptions) {
        CFErrorRef ce = NULL;
        ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, &ce);
        NSError *e = CFBridgingRelease(ce);
        if (e) {
            ABAuthorizationStatus status = kABAuthorizationStatusNotDetermined;
            if (kABOperationNotPermittedByUserError == e.code) {
                status = kABAuthorizationStatusDenied;
            }
            [self.delegate contactsReader:self didObtainData:nil authorizationStatus:status error:e];
            CFRelease(addressbook);
            return;
        }
    
        ABAddressBookRequestAccessWithCompletion(addressbook, ^(bool granted, CFErrorRef ce) {
            ABAuthorizationStatus status = granted ? kABAuthorizationStatusAuthorized : kABAuthorizationStatusDenied;
            NSError *e = CFBridgingRelease(ce);
            if (!granted || e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate contactsReader:self
                                    didObtainData:nil
                              authorizationStatus:status
                                            error:e];
                }); // main_queue
                CFRelease(addressbook);
                return;
            }
      
            /*
             The completion handler is called on an arbitrary queue. 
             If the ABAddressBookRef object is used throughout the app, then all 
             usage must be dispatched to the same queue to use ABAddressBookRef 
             in a thread-safe manner.
             */
            if ([self.delegate respondsToSelector:@selector(contactsReader:didGetAddressbook:)]) {
                [self.delegate contactsReader:self didGetAddressbook:addressbook];
            }
            
            NSDictionary *data = [[self class] obtainDataFromAddressbook:addressbook forPropertyKeys:propertyKeys];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate contactsReader:self didObtainData:data authorizationStatus:status error:nil];
            }); // main_queue
            CFRelease(addressbook);
        });
        
    } else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL);
        dispatch_async(queue, ^{
            ABAddressBookRef addressbook = ABAddressBookCreate();
            if ([self.delegate respondsToSelector:@selector(contactsReader:didGetAddressbook:)]) {
                [self.delegate contactsReader:self didGetAddressbook:addressbook];
            }
            NSDictionary *data = [[self class] obtainDataFromAddressbook:addressbook forPropertyKeys:propertyKeys];
            CFRelease(addressbook);
      
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate contactsReader:self didObtainData:data authorizationStatus:kABAuthorizationStatusAuthorized error:nil];
            }); // main_queue
        }); // global_queue
        
    } // handing the differernce between iOS 5 and iOS 6+
}

@end
