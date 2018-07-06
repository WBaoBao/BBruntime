//
//  ViewController.m
//  runtime
//
//  Created by apple on 2018/7/5.
//  Copyright © 2018年 baobao. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

#import "UIButton+event.h"
#import "DWExchangeTwoMethod.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
     
     1.动态交换两个方法的实现
     2.为类别添加属性(我们知道类别是不能扩展属性的，只能扩展方法，但可以运行时实现，通过为类增加属性)
     3.获取某个类的所有成员变量和成员方法
     4.实现NSCoding的自动归档和自动解档
     5.动态添加对象的成本变量和成员方法
     作用：当硬件内存过小的时候，如果我们将每个方法都直接加到内存当中去，但是几百年不用一次，这样就造成了浪费，所有采取动态添加
     6.实现字典和模型的自动转换
     
     作者：Dwyane_Coding
     链接：https://www.jianshu.com/p/0ac816ac8a3f
     來源：简书
     简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
     
     */
    
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    //给button动态创建子类实现按钮特定的点击方法
    [btn setNeedsCameraPermission];
    
    
    
    /**
     一、动态交换方法
     可以交换方法，防止数组越界导致的崩溃
     */
    //然而并没有看到效果
    DWExchangeTwoMethod *exchangeMethod = [DWExchangeTwoMethod new];
    
    //得到类的实例方法
    Method workMethod = class_getInstanceMethod([exchangeMethod class], @selector(play));
    //得到类的类方法
    Method playMethod = class_getClassMethod([DWExchangeTwoMethod class], @selector(work));
    method_exchangeImplementations(workMethod, playMethod);
    
    [exchangeMethod play];
    [DWExchangeTwoMethod work];
    
    
    /*
     二、为分类添加属性
     */
    btn.height = @"为分类添加属性";
    NSLog(@" --- %@",btn.height);
    
    /*
     三、获取实例变量列表
     
     class_copyPropertyList与class_copyIvarList
     class_copyPropertyList返回的仅仅是对象类的属性(@property申明的属性)，而class_copyIvarList返回类的所有属性和变量(包括在@interface大括号中声明的变量)
     
     */
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([DWExchangeTwoMethod class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        const char* name = ivar_getName(ivar);
        const char* type = ivar_getTypeEncoding(ivar);
        NSLog(@"变量名%s :%s", name, type);
    }
    //    此时要注意, 尽管在ARC模式下, 取出变量后要依然手动释放内存, 利用free()方法即可:
    free(ivars);
    
    
    
    /*
     五、动态添加方法
     */
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn1];
    btn1.frame = CGRectMake(30, 0, 30, 30);
    [btn1 setBackgroundColor:[UIColor blueColor]];
    [btn1 addTarget:self action:@selector(click1:) forControlEvents:UIControlEventTouchUpInside];
    

    
}

- (void)click{
    
}

/*********动态添加方法*********/
- (void)click1:(UIButton *)sender{
    [self performSelector:@selector(runPlay)];
}

void runPlay(id self ,SEL _cmd){
    NSLog(@"动态添加成功");
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor redColor];
    [self presentViewController:vc animated:YES completion:nil];
   
}

//动态决议
+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    if (aSEL ==  NSSelectorFromString(@"runPlay")) {
        //注册事件
        //    第一个v表示返回值类型为void,(如果是@表示返回为id)
        //    第二个@表示的是函数的调用者类型,
        //    第三个:表示 SEL
        //    第四个@表示需要一个id类型的参数（如果有入参的话）
        class_addMethod(self, aSEL, (IMP) runPlay, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}
/***********/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
