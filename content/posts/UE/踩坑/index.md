---
title: "踩坑记录"                                 # 文章标题（必填）
date: 2026-07-17                                 # 发布日期（手动填）
draft: true                                      # 草稿状态（true=不发布，false=发布）
description: ""                                  # 文章描述（SEO + 列表摘要，可选）
tags: [UE,蓝图]                                  # 标签（可选，支持多个）
categories: [UE]                                 # 分类（可选，支持多个）
featureimage: ""                                 # 封面图路径（可选）
showTableOfContents: true                        # 是否显示文章目录
---

> 我是主Unity辅UE，在空闲的时间+公司有需求情况下最近学习了一段时间UE，UE的坑是真的不少

## 蓝图坑

### 计时器
在c++中

### 事件图表变量捕获

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
