#import "../globals.typ": *

#let pinit-highlight-block-from(height: 2em, pos: bottom, fill: rgb(0, 180, 255), highlight-pins, point-pin, body) = {
  // some parameters like pin-dx have been changed to fit highlight block
  pinit-point-from(
    fill: fill, pin-dx: 0em, pin-dy: if pos == bottom { 1.0em } else { -1.3em }, body-dx: 0pt, body-dy: if pos == bottom { -1.7em } else { -1.6em }, offset-dx: 0em, offset-dy: if pos == bottom { 0.8em + height } else { -0.6em - height },
    point-pin,
    rect(
      inset: 0.48em,
      stroke: (bottom: 0.12em + fill),
      {
        set text(fill: fill)
        body
      }
    )
  )
}

#let pinit-top(pin-name, text) = {
  pinit-point-from(
    pin-name,
    body-dy: -25pt, body-dx: -25pt,
    offset-dx: 5pt, offset-dy: -45pt, pin-dy: -15pt
  )[#text]
}

#let pinit-bottom(pin-name, text) = {
  pinit-point-from(
    pin-name,
    body-dy: 5pt, body-dx: -25pt,
    offset-dx: 5pt, offset-dy: 45pt, pin-dy: 10pt
  )[#text]  
}

= LLVM: 编译器的解绑与模块化

== LLVM 的革命: 解绑编译器

== LLVM 的局限: 中心化的代价

== AI 时代的挑战

#slide[
=== 硬件多样性爆炸

]


#slide[
=== 信息丢失问题

]


#slide[
=== 碎片化的编译生态

]

= MLIR: 编译器基础设施化

== MLIR 是什么？

#v(1em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    #align(center)[#image("../assets/mlir-identity-03.svg", height: 40%)]

    #v(1em)
    #text(size: 35pt)[
      #pin(1)#highlight(fill: rgb(0, 180, 255).lighten(80%), radius: 5pt)[ML]#pin(2)
      #pin(3)#highlight(fill: rgb(150, 90, 170).lighten(80%), radius: 5pt)[IR]#pin(4)
    ]

    #pinit-highlight-block-from((1, 2), (1, 2), height: 2.5em, pos: bottom, fill: rgb(0, 180, 255))[
      Multi-Level 
      #strike(offset: -5pt, stroke: 1.5pt)[Machine Learning]
    ]

    #pinit-highlight-block-from((3, 4), (3, 4), height: 2.0em, pos: top, fill: rgb(150, 90, 170))[
      Intermediate Representation
    ]
    
    #v(1em)

  ],[
    #text(size: 20pt, weight: "bold", fill: rgb(200, 0, 0))[
      并非"又一个 IR"
    ]
    
    #text(size: 20pt, weight: "bold", fill: rgb(0, 100, 200))[
      而是"构建 IR 的框架"
    ]

    // TODO: 这里要补充说明 MLIR 的定位和作用
    
    #v(1em)

    虽然 MLIR 最初是用于 AI 相关场景, 但其有更广泛的应用场景:
        - 编译器: ClangIR, Polygeist
    - 量子计算: quantum Dialect
    - ...

  ]
)

== Operation: 更细粒度的操作

// TODO: 这个名字应该得改
// TODO: 内容也得改

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    在 LLVM IR 中：
    - *Instruction* 是最基础的单位
    - 指令 $->$ 基本块 $->$ 函数 $->$ 模块
    
    #v(1em)
    
    在 MLIR 中: 
    - *Operation* 不再是最基础的
    - 粒度进一步细化到：
      - *Types*, *Values*, *Attributes*, *Regions* , *Interfaces*
  ],[

    ` pin1 %result  pin2 = pin3  arith.addi  pin4 %a, %b pin5 : pin6  i32 pin7 `

    #pinit-bottom((1, 2))[返回值]
    #pinit-top((3, 4))[操作名]
    #pinit-bottom((4, 5))[操作数]
    #pinit-top((6, 7))[类型]

    #v(3em)

    *Operation 的灵活性:*
    - 任意数量的输入/输出
    - 任意数量的 attributes
    - 包含 regions（嵌套关系）
    - 实现 interfaces（解耦）
  ]
)

== Interface: 解耦优化和实现

// NOTE: 提到

#slide[
  #set text(size: 17pt)
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *问题:* 如何让优化 Pass 尽可能适用于有相似概念的 Operation?

      比如 *循环不变代码外提* (LICM)
      
      *传统方式:* 
      
      ```cpp
      if (op is scf::ForOp) {
        // 处理 scf.for
        hoistInvariantCode(op);
      } else if (op is affine::AffineForOp) {
        // 处理 affine.for
        hoistInvariantCode(op);
      } // ...每种循环都要写一遍
      ```
      
      $->$ 每种循环都要单独处理
    ],[
      *MLIR 方式: Interface*
      
      ```cpp
      void runOnOperation() {
        getOperation()->walk([&](LoopLikeOpInterface loop) {
          moveLoopInvariantCode(loop);
        });
      }
      ```
      $->$ 新循环类型(实现该 Interface)自动获得该优化

      #v(1em)

      除此 LoopLikeOpInterface 外, 还有:
      - CallOpInterface (函数调用)
      - SideEffectInterface (副作用)
      - ...

      // NOTE: CallOpInterface 的话 --inline 里面会用到
      // NOTE: SideEffectInterface 的话 --cse 里面会用到
    ]
  )
]

== Dialect

// TODO: 加个副标题
// TODO: 加点相关 Dialect 里面的 op 示例

#let dialect_hierarchy_image = image("../assets/codegen-dialect-hierarchy.svg", height: 87%)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *什么是 Dialect?*
    
    一组逻辑相关的集合：
    - *Operations* (操作), *Types* (类型), *Attributes* (属性)
  
    #v(1em)
    
    *为什么需要 Dialect?*

    _水平维度上解耦_: 完整 IR $->$ *多个局部 IR*
    - 每个 Dialect 针对特定领域
    - *按需组合*, 不再全盘接收
    - 去中心化
    
  ],[
    *关键特性:*
    - 高层: *完整* (complete), 准确描述边界
    - 中层: *部分* (partial), 可混用可组合
    - 底层: *受限* (constrained), 对接外部 IR
  ],[
  ]
)

// NOTE: Dialect 比较类似于 RISC-V 中模块化的拓展 
// NOTE: Dialect 相较于库来说, 更像模板一些 

#slide[
  
  #grid(
    columns: (1fr, auto),
    gutter: 2em,
    [
      Dialects 生态一览
      
      *高层 Dialect* (描述模型)
      - _tf_ / _tflite_: TensorFlow
      - _mhlo_: XLA HLO
      - _torch_: PyTorch
      - _tosa_: Tensor Operator Set

      *中层 Dialect*
      - _linalg_: 线性代数抽象
      - _tensor_: 张量操作
      - _memref_: Buffer 操作
    ],[
      #dialect_hierarchy_image
    ]
  )
  
]

#slide[
  #grid(
    columns: (1fr, auto),
    gutter: 2em,
    [
      *底层 Dialect*
      - _arith_ / _math_: 整数/浮点数计算
      - _scf_: 结构化控制流 (for/if)
      - _cf_: 基础块和控制流
      - _vector_: 向量计算
      
      *边界 Dialect*
      - _llvm_: 对接 LLVM IR
      - _spirv_: 对接 SPIR-V
    ],[
      #dialect_hierarchy_image
    ]
  )
]

// NOTE: 生态仍在扩张演进, 但组织结构已相对稳定

== Lowering: 渐进式递降
#slide[

#grid(
  columns: (0.8fr, 1fr, 0.1fr),
  gutter: 2em,
  [
    _为什么需要渐进式?_
    
    *领域专用语言的特点：*
    - 高度抽象的声明式语言
    - 只描述 *做什么*，不说 *怎么做*
    
    *目标硬件的要求：*
    - 具体的命令式机器指令
    - 精确控制每个操作
    
    #text(fill: rgb(200, 0, 0))[
      $->$ 抽象差距巨大, 一步跨越太难!
    ]
  ],[
    _垂直维度上解耦_: 对不同*层级*的概念建模
    - *高层*: 声明式(做什么)
    - *中层*: 结构化(怎么做)
    - *低层*: 命令式(具体指令)

    *优势: *
    - 分离各层次关注的问题
    - 每层都可以独立优化
    - 信息逐级保留
    - 更易开发和维护

  ],[
    #set text(size: 14pt)
    #let margin = 1.4

    #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1.5pt,
      
      node((0, 0), [高层 Dialect\ (linalg)], corner-radius: 5pt, fill: rgb("#e3f2fd")),
      edge("->", text(size: 15pt)[硬件指令,\ 便于代码生成], label-pos: 0.5, label-side: center),
      
      node((0, margin), [中层 Dialect\ (scf/affine)], corner-radius: 5pt, fill: rgb("#fff3e0")),
      edge("->", text(size: 15pt)[循环结构,\ 便于循环优化], label-pos: 0.5, label-side: center),

      node((0, 2*margin), [低层 Dialect\ (vector/llvm)], corner-radius: 5pt, fill: rgb("#f3e5f5")),
      edge("->", text(size: 15pt)[硬件指令,\ 便于代码生成], label-pos: 0.5, label-side: center),

      node((0, 3*margin), [机器码], corner-radius: 5pt, fill: rgb("#e8f5e9")),
    )
    ]
  ]
)

]

== LLVM IR vs MLIR: 中心化 vs 去中心化

#grid(
  columns: (0.8fr, 1fr),
  gutter: 2em,
  [
    *LLVM IR 的方式:*
    
    #v(0.5em)
    
    - 天然 *中心化*
    - 唯一完备的中间表示
    - 单一的、不可分割的 IR
    - 偏好 *统一* 的编译流程

    
    #v(0.5em)
    
    #text(fill: rgb(150, 0, 0))[
      $->$ 修改困难，演进缓慢
    ]
  ],
  [
    *MLIR 的方式:*
    
    #v(0.5em)
    
    - 天然 *去中心化*
    - 没有中心地位的 IR
    - 选取和组合现有 Dialect 来形成整体的流程
    - 偏好 *离散* 的编译流程
    
    #v(0.5em)
    
    #text(fill: rgb(0, 100, 0))[
      $->$ 按需组合，灵活扩展
    ]
  ]
)

#align(center)[
  #box(
    fill: rgb(230, 240, 255),
    inset: 1em,
    radius: 5pt,
    [
      #text(size: 16pt)[
        技术栈越往上越多样化（用户需求各异）
        
        技术栈越往下越需要模块化和定制化（硬件多样性）
      ]
    ]
  )
]
