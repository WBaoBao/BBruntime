//
//  UIButton+event.m
//  runtime
//
//  Created by apple on 2018/7/5.
//  Copyright © 2018年 baobao. All rights reserved.
//

#import "UIButton+event.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <objc/message.h>


@implementation UIButton (event)



//关联对象


- (NSString *)height{
    return objc_getAssociatedObject(self, @"height");
}
/*
 objc_setAssociatedObject   相当于 setValue:forKey 进行关联value对象
 
 objc_getAssociatedObject用来读取对象
 
 objc_AssociationPolicy属性 是设定该value在object内的属性，即 assgin, (retain,nonatomic)...等
 
 objc_removeAssociatedObjects函数来移除一个关联对象，或者使用objc_setAssociatedObject函数将key指定的关联对象设置为nil。
 */
/*
 key：要保证全局唯一，key与关联的对象是一一对应关系。必须全局唯一。通常用@selector(methodName)作为key。value：要关联的对象。注意到标记亮粉色部分 是第二个参数  const void *key 类型通常都是通常都是会采用静态变量来作为关键字  可以自己创建 也可以使用"@selector(btnAction:) "。
 */

/*
 policy：关联策略。有五种关联策略。
 
 OBJC_ASSOCIATION_ASSIGN 等价于 @property(assign)。OBJC_ASSOCIATION_RETAIN_NONATOMIC等价于 @property(strong, nonatomic)。OBJC_ASSOCIATION_COPY_NONATOMIC等价于@property(copy, nonatomic)。OBJC_ASSOCIATION_RETAIN等价于@property(strong,atomic)。OBJC_ASSOCIATION_COPY等价于@property(copy, atomic)。
 */
- (void)setHeight:(NSString *)height{
    objc_setAssociatedObject(self, @"height", height, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (void)setNeedsCameraPermission{
    NSString *className = [NSString stringWithFormat:@"CameraPermission_%@",self.class];
    //创建classname的类
    Class kclass = objc_getClass([className UTF8String]);
    if (!kclass)
    {
        //动态创建类
        /*
         objc_allocateClassPair(Class superclass,constchar*name, size_t extraBytes)
         @parame 父类
         @parame 类名
         @parame 类占用的空间
         
         void objc_disposeClassPair(Class cls)销毁类
         void objc_registerClassPair(Class cls)注册类
         */
        
        kclass = objc_allocateClassPair([self class], [className UTF8String], 0);
    }
    SEL setterSelector = NSSelectorFromString(@"sendAction:to:forEvent:");
    //
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    /*
     将一个类变为另一个类返回原来的类
     @parame 要被改变的类
     @parame 要变成的类
     */
    object_setClass(self, kclass);
    //
    const char *types = method_getTypeEncoding(setterMethod);
    //注册类和事件
    class_addMethod(kclass, setterSelector, (IMP)camerapermission_SendAction, types);
    
    objc_registerClassPair(kclass);
}

static void camerapermission_SendAction(id self, SEL _cmd, SEL action ,id target , UIEvent *event)
{
    struct objc_super superclass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    void (*objc_msgSendSuperCasted)(const void *, SEL, SEL, id, UIEvent*) = (void *)objc_msgSendSuper;
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                dispatch_async(dispatch_get_main_queue(), ^{
                    objc_msgSendSuperCasted(&superclass, _cmd,action,target,event);
                });
            }
        }];
    }else{
        objc_msgSendSuperCasted(&superclass, _cmd,action,target,event);
    }
}

@end
