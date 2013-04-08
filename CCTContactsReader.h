//
//  CCTContactsReader.h
//
//  Created by Weipin Xia on 4/8/13.
//  Copyright (c) 2013 Weipin Xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

typedef NS_ENUM(NSInteger, CCTContactsReaderABPropertyID)  {
    CCTContactsReaderABPersonUnknownProperty = 0,
    CCTContactsReaderABPersonEmailProperty,
    CCTContactsReaderABPersonPhoneProperty,
};

@class CCTContactsReader;
@protocol CCTContactsReaderDelegate <NSObject>

@required
- (void)contactsReader:(CCTContactsReader *)contactsReader
         didObtainData:(NSDictionary *)data
   authorizationStatus:(ABAuthorizationStatus)authorizationStatus
                 error:(NSError *)error;

@optional
/*
 IMPORTANT: called on an arbitrary queue (not main thread)
 */
- (void)contactsReader:(CCTContactsReader *)contactsReader
     didGetAddressbook:(ABAddressBookRef)addressbook;

@end


@interface CCTContactsReader : NSObject

@property (weak) id<CCTContactsReaderDelegate> delegate;

+ (NSDictionary *)obtainDataFromAddressbook:(ABAddressBookRef)addressBook forPropertyKeys:(NSArray *)propertyKeys;
- (void)obtainDataFromAddressbook:(NSArray *)propertyKeys;

@end
