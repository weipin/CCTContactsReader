//
//  ViewController.h
//  ContactsReaderDemo
//
//  Created by Weipin Xia on 4/8/13.
//  Copyright (c) 2013 Weipin Xia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCTContactsReader.h"


@interface ViewController : UIViewController<CCTContactsReaderDelegate>

@property (weak) IBOutlet UITextView *textView;
@property (weak) IBOutlet UIActivityIndicatorView *indicatorView;

@end
