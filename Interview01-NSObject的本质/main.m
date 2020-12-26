//
//  main.m
//  Interview01-NSObject的本质
//
//  Created by 琦魏 on 2020/12/26.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>
/**
 1.NSObject对象在内存中占用多少内存
 */
//typedef struct objc_class *Class;
//struct NSObject_IMPL {
//    Class isa;
//};
//
//struct Person_IMPL {
//    struct NSObject_IMPL NSObject_IVARS; //占8个字节
//    int age;//占4个字节
//};//结构体占12个字节,但实际上由于字节对齐的原因会导致实际结构体的大小为16.计算方式是:结构体的大小=结构体成员变量中内存占用最大的 *倍数

@interface Person : NSObject
{
    @public
    int age;
    int height;
    int width;
}

@end

@implementation Person



@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        Person *obj = [[Person alloc] init];
        obj->age = 5;
        obj->height = 8;
        obj->width = 12;
        /**
         首先我们分析为什么一个NSObject对象在使用class_getInstanceSize获取到的对象内存大小为8？
         我们可以通过 xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-arm64.cpp，查找到NSObject的类的结构。可以看到NSObject类在经过编译成c++后，其实是一个结构体。而结构体中只有一个
         Class（typedef struct objc_class *Class;） 指针。指针的大小在64位机器上就是8个字节，32位上就是4个字节。我们可以实现Person类来验证。当添加一个int 类型的成员变量后会发现class_getInstanceSize获得的内存大小为16，malloc_size获得的大小也为16.从上我们可以看出对象的大小受到成员变量的个数和类型决定。那如何通过编译产物的结构体来计算对象的大小呢？那就是和计算结构体的大小是一致的。
         */
        
        /**
         size_t class_getInstanceSize(Class cls)
         {
             if (!cls) return 0;
             return cls->alignedInstanceSize();
         }
         
         // May be unaligned depending on class's ivars.
         uint32_t unalignedInstanceSize() const {
             ASSERT(isRealized());
             return data()->ro()->instanceSize;
         }

         // Class's ivar size rounded up to a pointer-size boundary.
         uint32_t alignedInstanceSize() const {
             return word_align(unalignedInstanceSize());
         }
         BOOL
         class_addIvar(Class cls, const char *name, size_t size,
                       uint8_t alignment, const char *type);
         static Class realizeClassWithoutSwift(Class cls, Class previously)
         可以看到class_getInstanceSize获得内存大小就是实际成员变量的内存大小,可以查看class_addIvar方法会发现再新增成员变量时会增加instanceSize.还有data()->ro()->instanceSize,成员变量的内存大小在经过编译后就已经是确定的.后面具体讲isa和类的底层结构时会说到.
         
         */
        NSLog(@"instance size: %zd",class_getInstanceSize([Person class]));
        /**
         我们再分析为什么通过malloc_size获取到的内存占用大小为16个字节
         这个调用的时c函数获取到的时系统实际上为这个对象分配的内存大小,在成员变量增加时你会发现用这个函数获得的内存大小都是16的倍数.这个牵扯到系统内存的优化和内存对齐.可以通过打印对象地址,然后通过Debug->Debug Workflow->View Memory查看实际的内存分配,会发现都是16个字节的倍数.可以看到图中32位中有我们设置过obj成员变量的值.后面有很多0,然后其他对象的内存开始布局.但是实例变量的内存大小很容易计算得出占20个字节,字节对齐后时24,但系统会分配32个字节给你使用.
         */
        
        /**
         查看内存的方法还可以通过lldb的 memory read来查看对象的内存分配,可以通过memory write来为对象的成员变量写入值,但是你要准确知道成员变量在内存中的准确位置.当设置完对象的成员变量的值后,读取和打印对象的值都已经变化了.
         */
        NSLog(@"mallc size :%zd",malloc_size((__bridge void *)obj));
        
    }
    return 0;
}
