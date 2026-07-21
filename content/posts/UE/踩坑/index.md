---
title: "踩坑记录"                                 # 文章标题（必填）
date: 2026-07-17                                 # 发布日期（手动填）
draft: false                                      # 草稿状态（true=不发布，false=发布）
description: ""                                  # 文章描述（SEO + 列表摘要，可选）
tags: [UE,蓝图]                                  # 标签（可选，支持多个）
categories: [UE]                                 # 分类（可选，支持多个）
featureimage: ""                                 # 封面图路径（可选）
showTableOfContents: true                        # 是否显示文章目录
---

> 我是主Unity辅UE，在空闲的时间+公司有需求情况下最近学习了一段时间UE，UE的坑是真的不少

## 蓝图坑

### 计时器
c++用计时器是用下面代码
```cpp
// 由于设置计时器的方法有很多种，这里用匿名，这里主要注意的是句柄
GWorld->GetTimerManager().SetTimer(Handle, [this](){ ... }, 2.f, true);
```

创建计时器的时候是要传入计时器句柄，所以我们可以管理Timer

但是在蓝图中是无法传入句柄，只有传出句柄，在使用过一段时间后我认为蓝图中的计时器节点在设置计时器前会查找当前的Delegate是否存在，**存在就拿去已存在的句柄，后面设置的时候会覆盖掉**这个逻辑会在下图中解释
![](/timer-00.png)
图片中我们Tick一直创建计时器，如果按照代码的思想看这个，理论是不断的创建计时器，在运行后的第2秒后开始不断的print，但是实际是不输出，**每次Tick的时候都会把之前的移除**，导致始终无法流逝2s，一直无法触发，这很反直觉！如果不看源码都会认为每次执行的时候应该是没有去重逻辑的
```
下面由AI翻阅后整理的逻辑顺序

蓝图 SetTimerByEvent 节点
    │
    ▼ 编译展开
UKismetSystemLibrary::K2_SetTimerDelegate()
    │
    ├─ 1. Handle = TimerManager.K2_FindDynamicTimerHandle(Delegate)  ← 去重查找
    │
    └─ 2. TimerManager.SetTimer(Handle, Delegate, Time, ...)         ← 设置/覆盖
```

所以如果像提供在蓝图中实现一个调用每次调用的计时器都是独立的，需要自己扩展
```cpp
.h
// 声明个动态委托
DECLARE_DYNAMIC_DELEGATE(FDelayCallDelegate);

// 方法声明
static FTimerHandle SetTimerByEventEx(float DelayTime, FDelayCallDelegate Callback);

.cpp
// 方法实现
FTimerHandle XXX::SetTimerByEventEx(float DelayTime, FDelayCallDelegate Callback)
{
	FTimerHandle NewHandle;

	if (!GWorld)
	{
		GAME_LOG_ERROR_MSG(TEXT("SetTimerByEventEx 无法获取 World"));
		return NewHandle;
	}

	// 用 FTimerDelegate 包一层，绕过蓝图动态委托的自动去重，实现真正叠加
	FTimerDelegate TimerDel;
	TimerDel.BindLambda([Callback]()
	{
		if (Callback.IsBound())
		{
			Callback.Execute();
		}
	});

	// 延迟小于等于 0 时，UE 会在下一帧触发；否则按指定时间触发
	// 每次都用全新的局部句柄 → 每次都是独立计时器，互不重置、到点必触发
	GWorld->GetTimerManager().SetTimer(NewHandle, TimerDel, FMath::Max(DelayTime, KINDA_SMALL_NUMBER), false);

	// 按值返回句柄（FTimerHandle 是值类型 ID），蓝图可存可不存
	return NewHandle;
}

```

### 在事件图表中变量捕获
> 有时候我们用Timer就是延迟执行某个方法，但是有时候我们的Timer是在事件图表中使用，但是事件图表没有临时变量这种说法，不像在函数中由临时变量，我们想在回调的时候捕获一些变量或者传入一些值（通常是值类型，引用类型这种就不用考虑了）。如下图，结果如何？

> LogBlueprintUserMessages: [Test2_C_2] 100.0

难以置信回调的时候输出100，理论上我用的是Set后的结果（10）而不是用Get来拿，为什么还是拿到的还是X的引用，理论上应该10，毕竟前面set后的结果应该是10的缓存，但是最后输出还是100，所以Set的返回值应该是变量的引用

![](/timer-01.png)

如果要实现快照效果，可以在C++处做个取巧方法
```cpp
float XXX::Snapshoot_Float(float Value)
{
	return Value;
}
```

![](/timer-02.png)

> LogBlueprintUserMessages: [Test2_C_2] 10.0

现在达到需要的效果了

## 显示坑

### 细节面板中重复字段
如果出现下面图片实例问题的
![](/problem-00.png)
**多半是组件字段内联在Actor细节面板中出现的问题，处理结果是隔离掉组件字段的Category的分类与自身对象下的分类建议是不要重叠**

#### 复现问题
**组件代码**

```cpp
UCLASS( ClassGroup=(Custom), meta=(BlueprintSpawnableComponent) )
class FPS_TEST_API UTestActorComponent : public UActorComponent
{
	GENERATED_BODY()

public:	
	UTestActorComponent();
public:
	// 当前血量
	UPROPERTY(VisibleAnywhere, Category = "默认|内部")
	float Hp;
	// 血量最大值
	UPROPERTY(VisibleAnywhere, Category = "默认|内部")
	float HpMax;
};
```

**对象代码**

```cpp
UCLASS()
class FPS_TEST_API ATestActor : public AActor
{
	GENERATED_BODY()
	
public:	
	ATestActor();

public:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
	UTestActorComponent* TestComponent;

	// 当前血量
	UPROPERTY(VisibleAnywhere, Category = "默认|内部")
	float Hp2;
	// 血量最大值
	UPROPERTY(VisibleAnywhere, Category = "默认|内部")
	float HpMax2;

};

ATestActor::ATestActor()
{
	PrimaryActorTick.bCanEverTick = true;
	TestComponent = CreateDefaultSubobject<UTestActorComponent>(TEXT("TestComponent"));
}

```
这边我们是共用了一套 `"默认|内部"`，就会出现如上图的问题
隔离可以如下

```cpp
UCLASS()
class FPS_TEST_API ATestActor : public AActor
{
	GENERATED_BODY()
	
public:	
	ATestActor();

public:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
	UTestActorComponent* TestComponent;

	// 当前血量
	UPROPERTY(VisibleAnywhere, Category = "默认|1|内部")
	float Hp2;
	// 血量最大值
	UPROPERTY(VisibleAnywhere, Category = "默认|1|内部")
	float HpMax2;

};
```

![](/result-00.png)
