#import "../globals.typ": *

= 编译器与中间表示

在讨论各种具体中间表示之前，先让我们总体看一下编译器和中间表示。

== 什么是编译器？

#slide[
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
  
  编译器是一个 *程序转换工具*:
  - 输入：人类可读的高级语言
  - 输出：机器可执行的低级代码
]

== 正确性优先，优化其次

#slide[
  #columns[
    *编译器的首要任务*
    #text(size: 18pt, weight: "bold", fill: rgb(200, 0, 0))[
      1. 正确性 (Correctness) ✓
    ]
    #text(size: 18pt, weight: "bold", fill: rgb(100, 100, 100))[
      2. 优化 (Optimization)
    ]

    #box(
      fill: rgb(255, 235, 238),
      inset: 1em,
      radius: 5pt,
      [
        错误的优化比没有优化更糟糕！
        
        编译器必须保证：优化后的程序与原程序 *语义等价*
      ]
    )
    
    *优化的挑战*\
    > 不同程序有不同模式, 不同硬件喜欢不同指令, 而编译器处于中间, 选择有限.
    
    *这会导致:*\
    > 通用编译器很难做到完美优化. 因为只有少数转换可以安全默认开启, 而大多数优化需要特定条件


    #align(center)[
      #box(
        fill: rgb(230, 240, 255),
        inset: 1.5em,
        radius: 5pt,
        [
          编译器帮你达到 *80%* 的性能
          
          剩下的 *20%* 需要手工优化
                    
          #text(size: 16pt)[
            这样你可以专注算法和架构, 
            而非底层细节
          ]
        ]
      )
    ]
  ]
]

== 代码表示的递降与递升

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *递降 (Lowering):* 高层次 $->$ 低层次
      
      ```python
      # 高层: 矩阵乘法
      C = A @ B
      ```
      
      ```c
      // 中层: 循环
      for (i=0; i<n; i++)
        for (j=0; j<m; j++)
          for (k=0; k<p; k++)
            C[i][j] += A[i][k] * B[k][j]
      ```
      
      ```asm
      ; 低层: 汇编指令
      mov eax, [esi]
      mul ebx
      add [edi], eax
      ...
      ```
    ],[
      *递升 (Raising):* 低层次 $->$ 高层次
      
      #text(fill: rgb(200, 0, 0))[
        *递升比递降困难得多!*
      ]
      
      *为什么?*
      - 信息逐渐丢失
      - 需要从细节中推断意图
      - 模式识别复杂
      
      *影响:*
      - 越晚的优化越困难
      - 高层信息很宝贵
      - 需要在合适的层次做优化
    ]
  )
]

== 中间表示: 连接抽象层次的桥梁

#slide[#grid(columns: (0.6fr, 1fr), [
  *什么是中间表示 IR?*
  
  IR: Intermediate representation
  
  程序的一种 *内部表示形式*:
  - 介于源码和机器码之间
  - 便于分析和变换
  - 编译器的"工作语言"

  *LLVM IR 示例:*
  ```c
  // C code
  int main() {
    return 0;
  }
  ```
  
],[
    ```llvm
  ; LLVM IR
  define dso_local noundef i32 @main() {
  entry:
    %retval = alloca i32, align 4
    store i32 0, ptr %retval, align 4
    ret i32 0
  }
  ```

  #v(1em)
  
  *IR 的三种形态*
  
  + *内存表示*：便于程序分析, 进行快速访问和修改
  + *字节码:* 紧凑的二进制格式, 便于存储传输      
  + *文本格式:* 便于人类阅读, 用于调试和理解 (如最上面的LLVM IR)

])
]

#slide[
  *IR 设计的权衡*
  
  #grid(
    columns: (0.5fr, 1fr),
    gutter: 2em,
    [
      *理想的设计原则:*
      - 语义清晰明确
      - 操作相互正交
      - 避免信息重复
      - 保持高层信息
      
      #v(1em)
      
      #text(fill: rgb(100, 100, 100))[
        听起来很完美对吧？
      ]
    ],[
      *现实的挑战：*
      
      实际中经常需要 *违反* 这些原则!

      - GPU 的 FMA 指令: 破坏正交性, 但性能必需
      - SPIR-V 的硬件能力声明: 重复信息, 但减少驱动工作
      - C 语言的向量化: 提升抽象层次, 补偿信息缺失

      #text(fill: rgb(200, 0, 0))[
        设计就是权衡！
      ]
    ]
  )
]
