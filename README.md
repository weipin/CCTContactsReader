CCTContactsReader
====
A very simple Objective-C class to help you obtain data from Address Book database.


Features
----
- One single method call(obtainDataFromAddressbook:), and it won't block main thread.
- Requesting access to contact data, which is REQUIRED in iOS 6.
- An unified interface to help you handle access authorization status and errors.
- Obtain certain attributes(kABPersonEmailProperty and kABPersonPhoneProperty) as Objective-C objects.
- Providing a delegate method so you can handle the Address Book database (ABAddressBookRef).
- Support both iOS 5 and iOS 6.

How to use
----
- Add CCTContactsReader.h and CCTContactsReader.m to your project. 
- Add AddressBook.framework.
- Implement delegate methods (`CCTContactsReaderDelegate`).
- Create a CCTContactsReader instance and assign the delegate.
- Call `obtainDataFromAddressbook:` and check/obtain data in delegate methods.

ContactsReaderDemo
----

When you launch ContactsReaderDemo, it will display a blank text view and a button below it. Tap the button, the app will try to obtain all the email addresses and phone numbers from your Address Book database, and list them in the text view.

Let's see how `CCTContactsReader` is used in ContactsReaderDemo.

- `ViewController` instance is the delegate of CCTContactsReader, so delegate methods `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:`(REQUIRED) and `contactsReader:didGetAddressbook:` are implemented in ViewController.m.
- In action method `obtainData:`, an `CCTContactsReader` instance is created and `obtainDataFromAddressbook:` method is called. `@[@(CCTContactsReaderABPersonEmailProperty)]` was passed as attributes, to obtain all the email addresses.
  
  For the attributes passed to `obtainDataFromAddressbook:`, the method will obtain the values of these attributes and return them as Objective-C objects, in delegate method `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:`. The attributes is a NSArray object which contains NSNumber objects. The value of the NSNumber objects MUST be type `CCTContactsReaderABPropertyID`. At the time of writing this, there are only two types available: `CCTContactsReaderABPersonEmailProperty` and `CCTContactsReaderABPersonPhoneProperty`.
- In delegate method `contactsReader:didGetAddressbook:`, ContactsReaderDemo uses a helper method `obtainDataFromAddressBook:forPropertyKeys:` to obtain all the phone numbers. Normally, you can add your own code in `contactsReader:didGetAddressbook:` to obtain various data from Address Book database.
- In delegate method `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:`, ContactsReaderDemo dumps the results to text view.
  The data comes from the method argument `data`, and the ivar `_data` (which is obtained in `contactsReader:didGetAddressbook:`).
  
  You are also required to handle access authorization status and errors in `contactsReader:didObtainData:authorizationStatus:authorizationStatus:error:`. The implementation in `ViewController` handles all the necessary cases, which you can use as a start point.

