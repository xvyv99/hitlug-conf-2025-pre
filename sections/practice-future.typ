#import "../globals.typ": *

= 从理论到实践: MLIR 落地了吗?

== DSL: 降低异构编程门槛

#slide[

#let ir_color = rgb("#e1f5fe")

DSL: Domain-Specific Language 领域特定语言

// TODO: 需要修改措辞
+ *Triton*#footnote[注意, 此处的 Triton不是指 NVIDIA 推出的开源推理服务框架]: OpenAI 开源的 GPU 编程语言和编译器, 基于 MLIR 构建, 专为高性能深度学习内核设计. 其底层采用 MLIR 来实现高效的代码生成和优化.
- 目前 `torch.compile` 后端就是用的 Triton
- SGLang 也有 Triton 算子来做 backend 的选项
#diagram(
  node-stroke: 1pt,
  edge-stroke: 1.5pt,
  
  node((0, 0), [Triton DSL], corner-radius: 5pt, fill: rgb("#ffcdd2")),
  edge("->"),
  node((1, 0), [TTIR], corner-radius: 5pt, fill: ir_color),
  edge("->"),
  node((2, 0), [TTCIR], corner-radius: 5pt, fill: ir_color),
  edge("->"),
  node((3, 0), [TTGIR], corner-radius: 5pt, fill: ir_color),

  node((4, 0), [Nvidia], corner-radius: 5pt, fill: rgb("#c8e6c9")),
  node((4, 0.5), [AMD], corner-radius: 5pt, fill: rgb("#c8e6c9")),
  node((4, 1), [CPU], corner-radius: 5pt, fill: rgb("#c8e6c9")),

  {
		let tint(c) = (stroke: c, fill: rgb(..c.components().slice(0,3), 5%), inset: 8pt)
		node(enclose: ((1,0), (3.27, 0.5)), ..tint(teal), corner-radius: 5pt)
    node((2, 0.4), [MLIR Lowering], stroke: none)
	},

  edge((3, 0), (4, 0), "->"),
  edge((3, 0), (4, 0.5), "->"),
  edge((3, 0), (4, 1), "->"),
)

]

#slide[

#grid(
  columns:(1fr, 1fr),
  [
    2. *CuTe*: 是一种基于 Python 的 DSL, 用于数值计算和 GPU 代码的动态编译, 同样基于 MLIR.
    - 编译速度更快(相比 cutlass)
    - FlashAttention 4 采用的便是 CuTe
  ],[
    #image("../assets/cute.png", height: 50%)
]
)

#grid(
  columns:(1fr, 0.6fr),
  [
    3. *Mojo*: 是一门结合 Python 易用性与 C++ 性能的编程语言, 基于 MLIR 构建, 支持高性能且可移植的 GPU 编程, 同时保持与 Python 的运行时互操作性.
  ],[
    #image("../assets/mojo.png", width: 70%)
]
)

]

== 硬件适配: $"N"plus"M"$ 而非 $"N"times"M"$

#slide[
  
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *寒武纪: triton-linalg#footnote[微软有个类似的项目 triton-shared, 也是将 triton 转换为 `linalg` Dialect]*
      
      #align(center)[
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1.5pt,
          
          node((0, 0), [Triton DSL], corner-radius: 5pt, fill: rgb("#fff3e0")),
          edge((0, 0), (0, 1), "->", [转换]),
          node((0, 1), [MLIR\ `linalg` Dialect], corner-radius: 5pt, fill: rgb("#e1f5fe")),
          edge((0, 1), (0, 2), "->", [下降]),
          node((0, 2), [MLU指令], corner-radius: 5pt, fill: rgb("#e8f5e9")),
        )
      ]
    ],[
      *算能: TPU-MLIR*
      
      #align(center)[
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1.5pt,

          node((-0.8, -0.8), [TensorFlow], corner-radius: 5pt, fill: rgb("#fff3e0")),
          node((-0.2, -0.8), [Pytorch], corner-radius: 5pt, fill: rgb("#fff3e0")),
          node((0.5, -0.8), [PaddlePaddle], corner-radius: 5pt, fill: rgb("#fff3e0")),

          edge((-1, -0.8), (0, 0), "->"),
          edge((-0.2, -0.8), (0, 0), "->"),
          edge((0.6, -0.8), (0, 0), "->"),

          node((0, 0), [ONNX 模型], corner-radius: 5pt, fill: rgb("#ffcdd2")),
          edge("->", [导入]),
          node((0, 0.8), [MLIR \ TPU Dialect], corner-radius: 5pt, fill: rgb("#e1f5fe")),
          edge("->", [下降]),
          node((0, 1.6), [TPU 指令], corner-radius: 5pt, fill: rgb("#e8f5e9")),
        )
      ]
    ]
  )
  
]

== 研究创新: 原型与快速验证

造 Dialect 就行, 而不用重写整个编译栈:
- Tawa: Automatic Warp Specialization for Modern GPUs with Asynchronous References

// TODO: 添加例子

= MLIR 未来与展望

== 太自由的代价: 去中心化的一体两面

#slide[
  // TODO: 这部分得修改, 看起来怪怪的

  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      
      #text(fill: rgb("#2e7d32"), weight: "bold")[技术民主化]
      - 任何团队都能定义自己的 Dialect
      - 降低创新门槛, 快速验证想法
      - 避免单一巨头垄断技术路线
      - 促进社区多元化发展

    ],[
      #text(fill: rgb("#d32f2f"), weight: "bold")[协调失灵]
      - Dialect 数量两年内翻了五倍
      - 缺乏统一的兼容性测试
      - 没有权威的参考实现栈
      - 转换工具各自为政, 互不相通
    ]
  )
]

== 未来展望: 标准化与协作

#slide[
  
  // TODO: 这部分得修改, 看起来怪怪的

  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *LLVM 社区的治理重构*
      
      + *Area Governance*: 将 MLIR 拆分为 Core 和 Dialects 两个治理域
      + *技术边界清晰化*: 核心 IR 与应用扩展分离管理
      + *RFC 驱动的演进*: 重大变更需要社区共识

      #text(fill: rgb("#1976d2"), weight: "bold")[目标]: 防止恶化，但不能自动创造统一
    ],[
      *可能的解决路径*
      
      #text(fill: rgb("#388e3c"), weight: "bold")[1. 分层标准化策略]
      - 底层：MLIR Core 保持稳定和中立
      - 中层：建立若干个 Reference Stack 
      - 上层：允许差异化和创新
      
      #text(fill: rgb("#f57c00"), weight: "bold")[2. 激励对齐机制]
      - 建立跨公司的技术利益共同体
      - 通过标准认证降低集成成本
      - 让协作成为商业上的理性选择
    ]
  )
]

