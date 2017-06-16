//
//  BookAddressViewController.h
//  ColourLife
//
//  Created by colourlife on 14-8-12.
//
//

#import <UIKit/UIKit.h>


@protocol BookAddressViewDelegate <NSObject>
@optional

-(void)passValue:(NSString *)phoneNum KeyName:(NSString *)keyName;

@end



@interface BookAddressViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

{
    
    int pageindex;
    NSMutableArray     *dataArray;
    UITableView        *pullTableView;
    NSMutableSet       *lastNameAll;          //姓的所有集合
    NSMutableArray     *differetLastName;     //存储所有不同姓的集合；
    
      
    
}



@property (nonatomic) id <BookAddressViewDelegate> delegate;
@property (nonatomic, assign) id dataSource;
@property (nonatomic, assign) id tableDelegate;


@end
