//
//  ViewController.m
//  ContactsReaderDemo
//
//  Created by Weipin Xia on 4/8/13.
//  Copyright (c) 2013 Weipin Xia. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSDictionary *_data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CCTContactsReader delegate

- (void)contactsReader:(CCTContactsReader *)contactsReader
         didObtainData:(NSDictionary *)data
   authorizationStatus:(ABAuthorizationStatus)authorizationStatus
                 error:(NSError *)error {
    [self.indicatorView stopAnimating];

    if (kABAuthorizationStatusDenied == authorizationStatus) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Address Book Access Denied"
                                                            message:@"You must authorize this application to access "
                                                                    @"the Address Book data (Settings > Privacy > Contacts)."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (kABAuthorizationStatusRestricted == authorizationStatus) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Address Book Access Restricted"
                                                            message:@"Please remove active restrictions and try again "
                                                                    @"(Settings > General > Restrictions > Contacts). "
                                                                    @"Then please stop and restart the app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    NSMutableArray *emails = [NSMutableArray array];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [emails addObjectsFromArray:obj[@(CCTContactsReaderABPersonEmailProperty)]];
    }];

    NSMutableArray *phones = [NSMutableArray array];
    [_data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [phones addObjectsFromArray:obj[@(CCTContactsReaderABPersonPhoneProperty)]];
    }];

    NSString *result = [NSString stringWithFormat:@"Emails:%@\r\nPhones:%@", emails, phones];
    self.textView.text = result;
    
    return;
}

/*
 IMPORTANT: called on an arbitrary queue (not main thread)
 */
- (void)contactsReader:(CCTContactsReader *)contactsReader
     didGetAddressbook:(ABAddressBookRef)addressbook {
    // Add your code here to handle Address Book database
    
    _data = [CCTContactsReader obtainDataFromAddressbook:addressbook forPropertyKeys:@[@(CCTContactsReaderABPersonPhoneProperty)]];
}

#pragma mark - Action

- (IBAction)obtainData:(id)sender {
    [self.indicatorView startAnimating];
    CCTContactsReader *reader = [[CCTContactsReader alloc] init];
    reader.delegate = self;
    
    NSArray *propertyKeys = @[@(CCTContactsReaderABPersonEmailProperty)];
    [reader obtainDataFromAddressbook:propertyKeys];
}

@end
