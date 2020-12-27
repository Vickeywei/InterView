//
//  main.m
//  Interview01-NSObject的本质
//
//  Created by 琦魏 on 2020/12/26.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import <objc/message.h>

struct wq_objc_class {
    Class isa;
    Class superclass;
};

@interface Person : NSObject



@end
@implementation Person

@end


@interface Student : Person

@end

@implementation Student



@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //1.实例对象的isa指针指向
        Student *p = [[Student alloc] init];
        
        Person *p2 = [[Person alloc] init];
        
        NSObject *object = [[NSObject alloc] init];
        /*通过p/x指令可以查看到instance对象的isa指针内存地址为0x001d8001000081a9
        通过p/x指令可以查看[Person class],class对象的内存地址为0x00000001000081a8
        从目前得到的结果来看内存地址并不相等.但是isa指针在32位操作系统的时候两个内存地址是直接可以打印出来证明相等的.
        但是在64位操作系统上,我们可以查看源码,我们获取到的isa是&ISA_MASK,所以我们可以通过位操作,就可以拿到真实的isa地址.
        我目前创建的时mac工程也就是x86架构,所以ISA_MASK=0x00007ffffffffff8ULL,然后我们通过位操作,得到的内存地址0x00000001000081a8正好等于类对象的地址.由此得出实例对象的isa指针其实包存的是类对象的内存地址.
        */
        //2.类对象的内存地址同样保存的是元类对象的内存地址
        
        //获取类对象
        Class personClass = object_getClass(p);
        struct wq_objc_class *classObject = (__bridge struct wq_objc_class *)personClass;
        //获取元类对象
        Class personMetaClass = object_getClass([Student class]);
        NSLog(@"%@,%@,%@",p,personClass,personMetaClass);
        NSLog(@"%p,%p,%p",p,personClass,personMetaClass);
        
        /**
         获取到元类对象后我们可以打印他们的isa指针地址.通过p命令我们打印不了isa,member reference base type 'Class' is not a structure or union
         classObject.isa.什么原因呢?这是因为objc头文件中没有将Class的结构体中的isa暴露出来.我们可以自定义一个与之相同但名称不同的结构体,然后通过转换就可以打印这个isa了.
         */
        
        /**
         
         # if __arm64__
         #   define ISA_MASK        0x0000000ffffffff8ULL

         #elif __x86_64__
         #   define ISA_MASK        0x00007ffffffffff8ULL
         
         */
        /**
         inline Class
         objc_object::ISA()
         {
             ASSERT(!isTaggedPointer());
         #if SUPPORT_INDEXED_ISA
             if (isa.nonpointer) {
                 uintptr_t slot = isa.indexcls;
                 return classForIndex((unsigned)slot);
             }
             return (Class)isa.bits;
         #else
             return (Class)(isa.bits & ISA_MASK);
         #endif
         }
         
         */
        
        
        
        NSLog(@"isa");
        
#pragma -mark superclass
        
        //实例对象的superclass
        Class studentClass = object_getClass(p);
        Class personClass2 = object_getClass(p2);
        struct wq_objc_class *student = (__bridge struct wq_objc_class *)studentClass;
        struct wq_objc_class *person = (__bridge struct wq_objc_class *)personClass2;
        NSLog(@"superclass");
    }
    return 0;
}
