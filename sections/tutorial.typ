#import "../globals.typ": *

= 编译器与中间表示

在讨论各种具体中间表示之前，先让我们总体看一下编译器和中间表示。

== 什么是编译器？

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *编译器的本质*
      
      #align(center)[
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1.5pt,
          
          node((0, 0), [高级语言], corner-radius: 5pt, fill: rgb("#e3f2fd")),
          edge("->", [编译器], label-pos: 0.5, label-side: center),
          node((2, 0), [机器语言], corner-radius: 5pt, fill: rgb("#e8f5e9")),
        )
      ]
      
      #v(1em)
      
      编译器是一个 *程序转换工具*：
      - 输入：人类可读的高级语言
      - 输出：机器可执行的低级代码
      
    ],[
      *为什么需要编译器？*
      
      #text(weight: "bold", fill: rgb(0, 100, 200))[
        解决复杂性问题
      ]
      
      - 人脑 vs 机器：思维方式差异巨大
      - 抽象 vs 具体：高级概念 vs 底层指令
      - 效率 vs 精确：开发效率 vs 执行效率
      
      #v(1em)
      
      #box(
        fill: rgb(255, 249, 196),
        inset: 1em,
        radius: 5pt,
        [
          编译器让我们用 *人类的方式* 思考，
          让机器用 *机器的方式* 执行
        ]
      )
    ]
  )
]

== 抽象：人类应对复杂性的方式

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *复杂性爆炸*
      
      - 现代软件：百万行代码
      - 硬件复杂：多核、GPU、专用芯片
      - 应用多样：AI、游戏、系统软件...
      
      #v(1em)
      
      人脑处理能力有限，怎么办？
      
      #v(1em)
      
      #text(size: 20pt, weight: "bold", fill: rgb(200, 0, 0))[
        答案：抽象 (Abstraction)
      ]
    ],[
      *抽象的威力*
      
      ```python
      # 高级抽象
      result = matrix_multiply(A, B)
      ```
      
      vs
      
      ```asm
      # 底层实现（简化版）
      mov eax, [A]
      mov ebx, [B] 
      mul ebx
      # ... 数百行汇编代码
      ```
      
      #v(1em)
      
      抽象帮助我们：
      - 忽略无关细节
      - 关注核心逻辑
      - 减少认知负担
    ]
  )
]

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *从抽象到模型*
      
      抽象产生 *模型 (Model)*：
      
      - *机器模型*：CPU、内存、寄存器
      - *数据模型*：数组、链表、树
      - *计算模型*：函数、循环、条件
      
      #v(1em)
      
      模型提供 *语义 (Semantics)*：
      - 明确的规则和含义
      - 可预测的行为
      - 严谨的推理基础
    ],[
      *编译器的特殊性*
      
      其他领域：设计 + 艺术
      
      编译器领域：*理论 + 数学*
      
      #v(1em)
      
      为什么？因为需要 *证明正确性*
      
      #v(1em)
      
      #box(
        fill: rgb(255, 235, 238),
        inset: 1em,
        radius: 5pt,
        [
          错误的优化比没有优化更糟糕！
          
          编译器必须保证：优化后的程序与原程序 *语义等价*
        ]
      )
    ]
  )
]

== 正确性优先，优化其次

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *编译器的首要任务*
      
      #text(size: 18pt, weight: "bold", fill: rgb(200, 0, 0))[
        1. 正确性 (Correctness) ✓
      ]
      #text(size: 18pt, weight: "bold", fill: rgb(100, 100, 100))[
        2. 优化 (Optimization)
      ]
      
      #v(1em)
      
      *为什么正确性第一？*
      - 程序必须按预期工作
      - 错误的快速代码毫无意义
      - 调试错误编译极其困难
      
      #v(1em)
      
      *如何保证正确性？*
      - 明确的语义定义
      - 严格的变换规则
      - 大量的测试验证
    ],[
      *编译器的内部结构*
      
      #align(center)[
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1.5pt,
          
          node((0, 0), [源代码], corner-radius: 5pt, fill: rgb("#e3f2fd")),
          edge("->", [Pass 1], label-pos: 0.5, label-side: center),
          
          node((0, 1), [IR₁], corner-radius: 5pt, fill: rgb("#fff3e0")),
          edge("->", [Pass 2], label-pos: 0.5, label-side: center),
          
          node((0, 2), [IR₂], corner-radius: 5pt, fill: rgb("#f3e5f5")),
          edge("->", [Pass 3], label-pos: 0.5, label-side: center),
          
          node((0, 3), [目标代码], corner-radius: 5pt, fill: rgb("#e8f5e9")),
        )
      ]
      
      每个 Pass 后都要 *验证* 正确性！
    ]
  )
]

#slide[
  *优化的挑战*
  
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *问题：*
      - 不同程序有不同模式
      - 不同硬件喜欢不同指令
      - 编译器处于中间，选择有限
      
      #v(1em)
      
      *现实：*
      - 只有少数转换可以安全默认开启
      - 大多数优化需要特定条件
      - 通用编译器很难做到完美优化
    ],[
      *80/20 法则*
      
      #align(center)[
        #box(
          fill: rgb(230, 240, 255),
          inset: 1.5em,
          radius: 5pt,
          [
            编译器帮你达到 *80%* 的性能
            
            剩下的 *20%* 需要手工优化
            
            #v(0.5em)
            
            #text(size: 14pt)[
              这样你可以专注于算法和架构，
              而不是底层细节
            ]
          ]
        )
      ]
    ]
  )
]

== 代码表示的递降与递升

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *递降 (Lowering)*
      
      高层次 → 低层次
      
      ```python
      # 高层：矩阵乘法
      C = A @ B
      ```
      
      ↓
      
      ```c
      // 中层：循环
      for (i=0; i<n; i++)
        for (j=0; j<m; j++)
          for (k=0; k<p; k++)
            C[i][j] += A[i][k] * B[k][j]
      ```
      
      ↓
      
      ```asm
      ; 低层：汇编指令
      mov eax, [esi]
      mul ebx
      add [edi], eax
      ```
    ],[
      *递升 (Raising)*
      
      低层次 → 高层次
      
      #v(1em)
      
      #text(fill: rgb(200, 0, 0))[
        *递升比递降困难得多！*
      ]
      
      #v(1em)
      
      *为什么？*
      - 信息逐渐丢失
      - 需要从细节中推断意图
      - 模式识别复杂
      
      #v(1em)
      
      *影响：*
      - 越晚的优化越困难
      - 高层信息很宝贵
      - 需要在合适的层次做优化
    ]
  )
]

== 耦合问题与解耦方案

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *强耦合的问题*
      
      传统编译器：
      - 语言 ↔ 硬件 强绑定
      - 单一中间表示
      - 难以支持新需求
      
      #v(1em)
      
      *结果：*
      - 添加新语言：重写整个编译器
      - 支持新硬件：修改所有前端
      - 特殊需求：很难满足
      
      #text(fill: rgb(200, 0, 0))[
        → 开发成本高，创新困难
      ]
    ],[
      *解耦的方案*
      
      模块化编译器：
      - 前端 ↔ 后端 解耦
      - 多层次中间表示
      - 按需组合功能
      
      #v(1em)
      
      *优势：*
      - 新语言：只需写前端
      - 新硬件：只需写后端
      - 专用优化：独立开发
      
      #text(fill: rgb(0, 100, 0))[
        → 开发效率高，生态繁荣
      ]
    ]
  )
]

== 中间表示：连接抽象层次的桥梁

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *什么是中间表示 (IR)？*
      
      程序的一种 *内部表示形式*：
      - 介于源码和机器码之间
      - 便于分析和变换
      - 编译器的"工作语言"
      
      #v(1em)
      
      *历史演进：*
      - 早期：单一 IR
      - 现代：多层级 IR
      - 示例：Clang → AST → LLVM IR → MC
    ],[
      *IR 的三种形态*
      
      1. *内存表示*：便于程序分析
         - 数据结构：树、图、链表
         - 快速访问和修改
      
      2. *字节码*：便于存储传输
         - 紧凑的二进制格式
         - 跨平台交换
      
      3. *文本格式*：便于人类阅读
         - 调试和理解
         - 测试和验证
         
      #v(1em)
      
      不同 IR 侧重不同形态
    ]
  )
]

#slide[
  *IR 设计的权衡*
  
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *理想的设计原则：*
      
      - ✓ 语义清晰明确
      - ✓ 操作相互正交
      - ✓ 避免信息重复
      - ✓ 保持高层信息
      
      #v(1em)
      
      #text(fill: rgb(100, 100, 100))[
        听起来很完美对吧？
      ]
    ],[
      *现实的挑战：*
      
      实际中经常需要 *违反* 这些原则！
      
      #v(0.5em)
      
      *例子1：* GPU 的 FMA 指令
      - 破坏正交性，但性能必需
      
      *例子2：* SPIR-V 的能力声明
      - 重复信息，但减少驱动工作
      
      *例子3：* C 语言的向量化
      - 提升抽象层次，补偿信息缺失
      
      #v(1em)
      
      #text(fill: rgb(200, 0, 0))[
        设计就是权衡！
      ]
    ]
  )
]

== 编译器作为效率工具

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *开发效率 vs 执行效率*
      
      手写汇编：
      - ✓ 最高执行效率
      - ✗ 开发效率极低
      - ✗ 维护成本极高
      - ✗ 容易出错
      
      #v(1em)
      
      高级语言 + 编译器：
      - ✓ 高开发效率
      - ✓ 大部分执行效率
      - ✓ 易于维护
      - ✓ 不容易出错
    ],[
      *广义的编译*
      
      不只是传统编译器！
      
      #v(1em)
      
      *例子：数据处理*
      ```
      Apache Beam 
        ↓ (编译)
      Spark/Flink 任务
        ↓ (编译)  
      机器指令
      ```
      
      #v(1em)
      
      *核心思想：*
      分层抽象 + 自动转换 = 效率提升
    ]
  )
]

== 总结：编译器的本质

#slide[
  #align(center)[
    #box(
      fill: rgb(240, 248, 255),
      inset: 2em,
      radius: 10pt,
      width: 80%,
      [
        #text(size: 18pt, weight: "bold")[
          编译器是管理复杂性的工具
        ]
        
        #v(1em)
        
        通过 *抽象* 和 *模型* 让人类能够：
        - 用自然的方式表达想法
        - 获得机器级别的执行效率
        - 避免陷入底层细节
        
        #v(1em)
        
        通过 *中间表示* 和 *变换* 连接：
        - 不同的抽象层次
        - 不同的应用领域  
        - 不同的硬件平台
      ]
    )
  ]
  
  #v(2em)
  
  #align(center)[
    #text(size: 16pt, fill: rgb(100, 100, 100))[
      接下来我们看看具体的中间表示是如何实现这个目标的...
    ]
  ]
]
