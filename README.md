The purpose of CCTContactsReader, a very simple Objective-C class, is to simplified the work of obtaining data from address book database. Here is a list of highlights:

- One simple method (obtainDataFromAddressbook:)
- Won't block main thread
- Handle access authorization
- An unified interface for authorization status handling and error handling
- Obtain certain attributes(email and phone number) as Objective-C objects
- A delegate method to handle Address Book database (ABAddressBookRef)
- Support both iOS 5 and iOS 6.


How to use CCTContactsReader
----

Before you get started, you need to add CCTContactsReader.h, CCTContactsReader.m and AddressBook.framework to your project.

After that, you can create a CCTContactsReader instance, assign it a delegate and call `obtainDataFromAddressbook:`. The argument `propertyKeys` is the 'keys' of the data you want to obtain as Objective-C objects. At the time of writing this, there are only two types available: `CCTContactsReaderABPersonEmailProperty`(email address) and `CCTContactsReaderABPersonPhoneProperty`(phone number). The CCTContactsReader instance will return the objects in delegate method `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:`, as argument `data`.

```
    CCTContactsReader *reader = [[CCTContactsReader alloc] init];
    reader.delegate = self;

    NSArray *propertyKeys = @[@(CCTContactsReaderABPersonEmailProperty)];
    [reader obtainDataFromAddressbook:propertyKeys];
```

- Delegate method `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:` is *required*. You can use this method to access the objects obtained from database, and check access authorization status and errors.

- Delegate method `contactsReader:didGetAddressbook:` is *optional*. In the case that you want to process the database by yourself, you can find the addressbook(`ABAddressBookRef`) in this method. CCTContactsReader will create and release the addressbook for you. Also, `contactsReader:didGetAddressbook:` will only be called if everything goes well -- user grants your app access to the contact data, no error happens, etc. The idea is, by letting the CCTContactsReader do the dirty work, you can focus on the task of getting data.
  
  **Important note:** `contactsReader:didGetAddressbook:` will be called on an arbitrary queue (not main thread). So if you want to do some UI work, you need to execute the code in main thread explicitly.
  
```
  /*
   IMPORTANT: called on an arbitrary queue (not main thread)
   */
  - (void)contactsReader:(CCTContactsReader *)contactsReader
       didGetAddressbook:(ABAddressBookRef)addressbook {
      // Add your code here to handle Address Book database
      ...
      
      
      dispatch_async(dispatch_get_main_queue(), ^{
          // Update UI
          ...
      });
  }
```
  
  
- Why not use global ABPropertyID variables directly, such as kABPersonEmailProperty and kABPersonPhoneProperty?

  The fact is that seems these global variables are not assigned, until the address book database is created (by calling `ABAddressBookCreateWithOptions` or `ABAddressBookCreate`).

- What if I want to obtain data with types other than CCTContactsReaderABPersonEmailProperty and CCTContactsReaderABPersonPhoneProperty?

  You can either extend the class to support more types or implement the optional delegate method `contactsReader:didGetAddressbook:`.

  - To extend the class, you can add more types to enum `CCTContactsReaderABPropertyID`, and add code in method `obtainDataFromAddressBook:forPropertyKeys:`.
  - If your choice is to implement delegate method `contactsReader:didGetAddressbook:`, you can find argument `addressbook`(ABAddressBookRef), which can be used to obtain all the data you want.
  
- How to handle access authorization status and errors?

  In delegate method `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:`, you can check argument `authorizationStatus` and `error`. The code in ContactsReaderDemo is a good starting point, which handles all the necessary cases.
  - Permission was previously denied.
  - Permission is denied.
  - Restricted.
  
```
- (void)contactsReader:(CCTContactsReader *)contactsReader
         didObtainData:(NSDictionary *)data
   authorizationStatus:(ABAuthorizationStatus)authorizationStatus
                 error:(NSError *)error {
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

    // ...
    
    return;
}
```
  

About ContactsReaderDemo
----

When you launch ContactsReaderDemo, it will display a blank text view with a button below it. Tap the button, the app will try to obtain all the email addresses and phone numbers from your Address Book database, and list them in the text view.

Let's take a look on how ContactsReaderDemo uses `CCTContactsReader`.

- As delegate of the CCTContactsReader, ViewController implements methods `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:` and `contactsReader:didGetAddressbook:` in ViewController.m.
- In action method `obtainData:`, a `CCTContactsReader` instance is created and method `obtainDataFromAddressbook:` is called. `@[@(CCTContactsReaderABPersonEmailProperty)]` was passed as argument `propertyKeys`, to obtain all the email addresses.
- In delegate method `contactsReader:didGetAddressbook:`, ContactsReaderDemo uses a helper method `obtainDataFromAddressBook:forPropertyKeys:` to obtain all the phone numbers, and store the objects in ivar `_data`.
- In delegate method `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:`, ContactsReaderDemo displays the results in text view.
  The results is a combination of the argument `data`(emails), and the ivar `_data`(phone numbers).

