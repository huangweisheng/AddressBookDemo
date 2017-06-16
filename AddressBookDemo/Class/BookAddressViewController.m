//
//  BookAddressViewController.m
//  ColourLife
//
//  Created by colourlife on 14-8-12.
//
//
#pragma mark - 获取屏幕大小
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define GT_IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define viewHeight HEIGHT-64
#define viewOriginY ( GT_IOS7 ? 64.0 : 44.0)

#import "BookAddressViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"
#import "ChineseString.h"


@interface BookAddressViewController ()

{
    ABAddressBookRef addressBook;
    CFArrayRef results;
    NSString *lastName;
    NSString *fisrtName;
    NSString *fullName;
    
    
    CFTypeRef lastNameVtmp;
    CFTypeRef firstNameVtmp;
    
    NSString *phoneNum;
    NSString *name;
    NSString *key;
    NSString *keyName;
 
    NSString *string;
    NSString *string1;
    
    
    NSMutableArray     *arrayAll;   //所有人的数组
//    NSMutableArray     *lastNameArray;
//    NSMutableArray     *fisrtNameArray;
    
    NSMutableArray     *sameArray;   //姓相同的数组
    
    //  NSMutableDictionary *dict;
    NSMutableDictionary *dictAll;          // 排序之后的首字母
    NSMutableDictionary *dictNameNum;     //全部姓名与号码的字典
    
    NSMutableArray      *wordArray;       //字母数组
    NSMutableArray      *categoryArray;   //除去重复的字母的字母数组
    NSMutableArray    *test;
    
    NSString           *tempString1;
    NSString           *SameFName;      //首字母相同的姓名
    NSString           *firstWord;      //首字母
}

@end

@implementation BookAddressViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTableView];
 
    arrayAll     = [[NSMutableArray alloc]init];

    wordArray    = [[NSMutableArray alloc]init];
    dictAll      = [[NSMutableDictionary alloc]init];
    dictNameNum  = [[NSMutableDictionary alloc]init];
    
    [self readAddress];
    [self sortOfName];
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - AddTableView
- (void) addTableView
{
    
    //   pullTableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, ViewContextY, 320, self.view.bounds.size.height )];
    pullTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, viewOriginY, 320, viewHeight) style:UITableViewStyleGrouped];
    pullTableView.delegate = self;
    pullTableView.dataSource = self;
    //  pullTableView.pullDelegate = self;
    
    pullTableView.backgroundColor = [UIColor clearColor];
    pullTableView.backgroundView = nil;
    pullTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:pullTableView];
    
}



-(void)reponseDatas:(NSDictionary *)data operationTag:(NSInteger)tag
{
    if (tag == 10) {
        
        NSArray *arr        = [[NSArray alloc]init];
        arr                  = [data objectForKey:@"regStatus"];
        
        NSLog(@"***********%@",data);
    }
}


#pragma mark - paixu

//姓名按照首字母排序
-(void)sortOfName{
    
    NSMutableArray *chineseStringsArray=   [NSMutableArray array];
    NSRange  range                     =   NSMakeRange(0, 1);
    for(int i=0;i<[arrayAll count];i++){
        ChineseString *chineseString=[[ChineseString alloc]init];
        chineseString.string=[NSString stringWithString:[arrayAll objectAtIndex:i]];
        if(chineseString.string==nil){
            chineseString.string=@"";
        }
        
        if(![chineseString.string isEqualToString:@""]){
            NSString *pinYinResult=[NSString string];
            for(int j=0;j<chineseString.string.length;j++){
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin=pinYinResult;
        }else{
            chineseString.pinYin=@"";
        }
        [chineseStringsArray addObject:chineseString];
    }
    
    //Step2输出
    NSLog(@"\n\n\n转换为拼音首字母后的NSString数组");
    for(int i=0;i<[chineseStringsArray count];i++){
        ChineseString *chineseString=[chineseStringsArray objectAtIndex:i];
        NSLog(@"原String:%@----拼音首字母String:%@",chineseString.string,chineseString.pinYin);
    }
    
    //Step3:按照拼音首字母对这些Strings进行排序
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    //Step3输出
    // NSLog(@"\n\n\n按照拼音首字母后的NSString数组");
    for(int i=0;i<[chineseStringsArray count];i++){
        ChineseString *chineseString=[chineseStringsArray objectAtIndex:i];
        
        //    NSLog(@"原String:%@----拼音首字母String:%@",chineseString.string,[chineseString.pinYin substringWithRange:range]);
        [wordArray addObject:[chineseString.pinYin substringWithRange:range]];
        
        categoryArray = [[NSMutableArray alloc] init];
        for (unsigned i = 0; i < [wordArray count]; i++){
            if ([categoryArray containsObject:[wordArray objectAtIndex:i]] == NO){
                [categoryArray addObject:[wordArray objectAtIndex:i]];
            }
        }
    }
    
    //  首字母与姓名存到字典中
    
    for (int i=0; i<[categoryArray count]; i++)//遍历所有姓
    {
        sameArray   =   [[NSMutableArray alloc]init];
        for (int j=0; j<[chineseStringsArray count]; j++)//遍历所有人的姓名
        {
            ChineseString *chineseString  =   [chineseStringsArray objectAtIndex:j];
            
            tempString1                   =   chineseString.string;  //姓名
            firstWord                     =   [chineseString.pinYin substringWithRange:range];  //首字母
            
            if ([firstWord  isEqualToString:[categoryArray objectAtIndex:i]]) //将每个人得姓跟每个姓比较
            {
                //姓相同就将对应的学生对象存起来
                [sameArray addObject:tempString1];
                NSLog(@"!!!!%@",tempString1);
                //samArray存所有姓相同的人
            }
        }
        
        [dictAll setObject:sameArray forKey:[categoryArray objectAtIndex:i]];//生成对应的字典
    }
    
    
    // Step4:如果有需要，再把排序好的内容从ChineseString类中提取出来
    NSMutableArray *result=[NSMutableArray array];
    for(int i=0;i<[chineseStringsArray count];i++){
        [result addObject:((ChineseString*)[chineseStringsArray objectAtIndex:i]).string];
    }
    
    //Step4输出
 //   NSLog(@"\n\n\n最终结果:");
    for(int i=0;i<[result count];i++){
        NSLog(@"%@",[result objectAtIndex:i]);
    }
    
}


#pragma mark - read bookaddress
//读取通讯录  并且构造姓名与号码的字典
- (void)readAddress
{
    addressBook        = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_semaphore_signal(sema);
                                                 });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
     //    dispatch_release(sema);
    }
    
    results   = ABAddressBookCopyArrayOfAllPeople(addressBook);
    dataArray = (__bridge NSMutableArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
    int peopleCount = dataArray.count;
    // NSLog(@"****%@",dataArray);
    for (int i=0; i<peopleCount; i++)
    {
        phoneNum           = nil;
        fullName           = nil;
        lastName           = nil;
        fisrtName          = nil;
        
        ABRecordRef record = CFArrayGetValueAtIndex((__bridge CFArrayRef)(dataArray), i);
      
        lastNameVtmp       = ABRecordCopyValue(record, kABPersonLastNameProperty);
        firstNameVtmp      = ABRecordCopyValue(record, kABPersonFirstNameProperty);
        
        if (lastNameVtmp)
        {
             lastName = [NSString stringWithString:(__bridge NSString *)(lastNameVtmp)];
             NSLog(@"%@",lastName);

          if (firstNameVtmp) {
            fisrtName = [NSString stringWithString:(__bridge NSString *)(firstNameVtmp)];
            NSLog(@"****%@",fisrtName);
            
            fullName  = [lastName stringByAppendingString:fisrtName];

           }else{
        
            fullName  = lastName;
           }
        }
        else{
           
            if (firstNameVtmp) {
                fisrtName = [NSString stringWithString:(__bridge NSString *)(firstNameVtmp)];
                NSLog(@"****%@",fisrtName);
            
                fullName  = fisrtName;
            }
           else{
           
               fullName  = @"无名称";
               
           }
         }
        
        
        [arrayAll addObject:fullName];
        
        ABMultiValueRef phones    =   ABRecordCopyValue(record, kABPersonPhoneProperty);
        int phoneCount            =   ABMultiValueGetCount(phones);
        for (int j=0; j<phoneCount; j++)
        {
            // phone number
            
            phoneNum = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
            if (phoneNum)
                CFRelease((__bridge CFTypeRef)(phoneNum));
        }
        NSLog(@"%@",phoneNum);
        
        [dictNameNum setValue:phoneNum forKey:fullName];  //构造姓名与电话的字典

        
    }
    if (results)
        CFRelease(results);
    results     = nil;
    if (addressBook)
        CFRelease(addressBook);
    addressBook = NULL;
}



#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [categoryArray count];
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if([categoryArray count]==0)
    {
        return @"";
    }
    return [categoryArray objectAtIndex:section];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    keyName           =   [categoryArray objectAtIndex:section];   //通过section在categoryArray里拿到相应的key
    return     [[dictAll objectForKey:keyName] count];            //通过key在dictall中找到（姓）对应的数组，数组中元素的个数就是每组对应的行数
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
    //不能是UITableViewCellEditingStyleNone
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellWithIdentifier = @"Cell";
    UITableViewCell *cell  =  [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    
    if (cell == nil) {
        cell   =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
        
    }
    NSUInteger section  = [indexPath section];
    keyName             = [categoryArray objectAtIndex:section];
    key                 = [[dictAll objectForKey:keyName] objectAtIndex:indexPath.row];
    phoneNum            = [dictNameNum objectForKey:key];
    cell.textLabel.text         = [[dictAll objectForKey:keyName] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text   =  @"邀请";
    cell.detailTextLabel.font   = [UIFont systemFontOfSize:14];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger section  =   [indexPath section];
    keyName             =   [categoryArray objectAtIndex:section];
    key                 =   [[dictAll objectForKey:keyName] objectAtIndex:indexPath.row];
    phoneNum            =   [dictNameNum objectForKey:key];
    
    if (phoneNum.length==11 || phoneNum.length==13 || phoneNum.length == 17) {
        
        if ([self.delegate respondsToSelector:@selector(passValue:KeyName:)]) {
            [self.delegate passValue:phoneNum KeyName:key ];
            [self performSelector:@selector(backPressed:) withObject:self afterDelay:0.5f];
        }
        
    }
    else{
    
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"电话号码格式不对" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
       
    
     }
    
}

//字母索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
    
    for (char c = 'A';c<='Z';c++) {
        [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
    }
    return toBeReturned;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger count = 0;
    for(NSString *character in categoryArray)
        
    {
        if([character isEqualToString:title])
            
        {
            return count;
        }
        
        count ++;
    }
    return 0;
}




#pragma mark -backpress
-(void)backPressed:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
