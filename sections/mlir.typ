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

= MLIR: 编译器基础设施化

// TODO: 这个副标题也得改

== MLIR 是什么？

#grid(
  columns: (1fr, 1fr),
  [
    #align(center)[#image("../assets/mlir-identity-03.svg", height: 20%)]

    #v(1em)
    #text(size: 35pt)[
      #pin(1)#highlight(fill: rgb(0, 180, 255).lighten(80%), radius: 5pt)[ML]#pin(2)
      #pin(3)#highlight(fill: rgb(150, 90, 170).lighten(80%), radius: 5pt)[IR]#pin(4)
    ]

    #pinit-highlight-block-from((1, 2), (1, 2), height: 2.5em, pos: bottom, fill: rgb(0, 180, 255))[
      Multi-Level 
      #strike(offset: -5pt, stroke: 1.5pt)[Machine Learning]#footnote("MLIR stands for one of “Multi-Level IR” or “Multi-dimensional Loop IR” or “Machine Learning IR” or “Mid Level IR”, we prefer the first.")
    ]

    #pinit-highlight-block-from((3, 4), (3, 4), height: 2.0em, pos: top, fill: rgb(150, 90, 170))[
      Intermediate Representation
    ]
    #v(1em)

  ],[
    #text(weight: "bold", fill: rgb(200, 0, 0))[
      并非"又一个 IR"
    ]
    #text(weight: "bold", fill: rgb(0, 100, 200))[
      而是"构建 IR 的框架"
    ]

    // TODO: 这里要补充说明 MLIR 的定位和作用
    MLIR 是一个编译器框架, 可以让不同领域的编译器能在同一套中间表示和优化框架上协作, 从而更快更容易地构建新的编译器.
    
    虽然 MLIR 最初是用于 AI 相关场景, 但其有更广泛的应用场景:
    - 编译器: ClangIR, Polygeist
    - 量子计算: quantum Dialect, QIR
    - ...

  ]
)

== Operation: 更细粒度的操作

// TODO: 这个名字应该得改
// TODO: 内容也得改

#grid(
  columns: (1.1fr, 1fr),
  gutter: 2em,
  [
    *Operation (Op)* 是语义的基本单位
    - 指令, 函数, 模块等全部被建模成 Op
    - 没有固定的 Op 集合, 鼓励按领域自定义
    - Op 接收/产生的 SSA 值分别称为操作数与结果, 所有值都带类型 (类似 LLVM IR)
  ],[
    #v(3em)
    ` pin1 %result  pin2 = pin3  arith.addi  pin4 %a, %b pin5 : pin6  i32 pin7 `

    #pinit-bottom((1, 2))[返回值]
    #pinit-top((3, 4))[操作名]
    #pinit-bottom((4, 5))[操作数]
    #pinit-top((6, 7))[类型]

    #v(3em)

    #image("../assets/op.png")
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

      $->$ 每种循环都要单独处理: `scf::ForOp`, `scf::ParallelOp`, `affine::AffineForOp`, ...
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

== Dialect: 不同层级概念的建模

#slide[

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *什么是 Dialect?*\
    基本可以理解为一个*命名空间*.在这个命名空间中, 我们可以定义一系列互补协作的操作, 及其所需的类型#footnote[虽然类型一般已经在 Builtin Dialect 中定义了]和属性.

    比如对于一个内存操作相关的 Dialect, 可能会包含:
    - `LoadOp`/`StoreOp` (内存加载/存储)
    - `AllocaOp`/`DeallocOp` (内存分配/释放)
    - `MemRefType` (内存引用类型)

  ],[
    *为什么需要 Dialect?* \
    _水平维度上解耦_: 完整 IR $->$ *多个局部 IR*
    - 每个 Dialect 针对特定领域
    - 使用时 *按需组合*, 不再全盘接收
    - 去中心化, 灵活扩展

    _垂直维度上解耦_: 对不同*层级*的概念建模
    - *高层*: 声明式(做什么)
    - *中层*: 结构化(怎么做)
    - *低层*: 命令式(具体指令)
  ],[
  ]
)

]

// NOTE: Dialect 比较类似于 RISC-V 中模块化的拓展 
// NOTE: Dialect 相较于库来说, 更像模板一些 

#let dialect_hierarchy_image = image("../assets/codegen-dialect-hierarchy.svg", height: 87%)

#slide[
  
  #grid(
    columns: (1fr, auto),
    gutter: 2em,
    [
      Dialects 生态一览
      
      *高层 Dialect* (描述模型)
      - `tf` / `tflite`: TensorFlow
      - `mhlo`: XLA HLO
      - `torch`: PyTorch
      - `tosa`: Tensor Operator Set

      *中层 Dialect*
      - `linalg`: 线性代数抽象
      - `tensor`: 张量操作
      - `memref`: Buffer 操作
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
      - `arith` / `math`: 整数/浮点数计算
      - `scf`: 结构化控制流 (for/if)
      - `cf`: 基础块和控制流
      - `vector`: 向量计算
      
      *边界 Dialect*
      - `llvm`: 对接 LLVM IR
      - `spirv`: 对接 SPIR-V
    ],[
      #dialect_hierarchy_image
    ]
  )
]

#slide[
  #align(center)[#image("../assets/mlir_dialects.png", height: 89%)]
]

// NOTE: 生态仍在扩张演进, 但组织结构已相对稳定

== Lowering: 渐进式递降
#slide[

#grid(
  columns: (1fr, 0.1fr),
  gutter: 2em,
  columns[
    即以较小的步幅, 依次经过多个抽象级别, 从较高级别的表示降低到最低级别

    _为什么需要渐进式?_

    // TODO: 这里的内容也得改
    
    这对于领域特定编译器(Domain-specific compiler)尤其重要, 因为:

    *领域特定语言的特点:*
    - 高度抽象的声明式语言
    - 只描述 *做什么*，不说 *怎么做*
    
    *目标硬件的要求:*
    - 具体的命令式机器指令
    - 精确控制每个操作
    
    #text(fill: rgb(200, 0, 0))[
      $->$ 抽象差距巨大, 一步跨越太难!
    ]

    *优势:*
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
    - 单一的, 不可分割的 IR
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
