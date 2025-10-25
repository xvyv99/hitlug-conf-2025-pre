#import "../globals.typ": *

= LLVM: 编译器的解绑与模块化

== LLVM 的革命: 解绑编译器

#grid(
  columns: (0.8fr, 1fr),
  gutter: 2em,
  [
    *前 LLVM 时代的问题*
    
    编译器 *特设且高度耦合*:
    - 虽分三段 (前端/中端/后端)
    - 但针对特定语言或硬件
    - 模块间没有明确界限
    - 不同编译器栈基本不共用代码
    - 无法组合现有前端或后端
    
    #v(0.5em)
    
    #text(fill: rgb(200, 0, 0))[
      $->$ 无法发挥三段式编译器优势
    ]
  ],[
    *LLVM 的突破*
    
    依靠 *解绑* 带来巨大变革:
    - LLVM IR 处于核心地位
    - 使用 CFG + 基础块 + SSA
    - *完备的* 独立表示
    - 作为前后端间的单一桥梁
    
    #text(fill: rgb(0, 100, 0))[
      $->$ 完全解绑编译器前后端
    ]

    #let v_x = 0.9;
    #let v_y = 0.8;

    #set text(size: 14pt)
    #diagram(

      node-stroke: 1pt,
      edge-stroke: 1.5pt,
      spacing: (3em, 2em),
      
      node((0, 0), [C/C++ (Clang)], corner-radius: 5pt, fill: rgb("#e3f2fd")),
      node((0, v_y), [Fortran (Flang)], corner-radius: 5pt, fill: rgb("#e3f2fd")),
      node((0, 2*v_y), [Haskell (GHC)], corner-radius: 5pt, fill: rgb("#e3f2fd")),
      
      node((v_x, v_y), [LLVM IR], corner-radius: 5pt, fill: rgb("#fff3e0")),
      
      node((2*v_x, 0), [x86_64], corner-radius: 5pt, fill: rgb("#e8f5e9")),
      node((2*v_x, v_y), [ARM], corner-radius: 5pt, fill: rgb("#e8f5e9")),
      node((2*v_x, 2*v_y), [RISC-V], corner-radius: 5pt, fill: rgb("#e8f5e9")),

      edge((0, 0), (v_x, v_y), "->"),
      edge((0, v_y), (v_x, v_y), "->"),
      edge((0, 2*v_y), (v_x, v_y), "->"),

      edge((v_x, v_y), (2*v_x, 0), "->"),
      edge((v_x, v_y), (2*v_x, v_y), "->"),
      edge((v_x, v_y), (2*v_x, 2*v_y), "->"),
    )
  
  ]
)

== LLVM 的革命: 模块化设计
#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      *组织成库*
      
      - 定义不同模块间的分界
      - 提供合适的 API
      - 选择和组合不同功能
      
      #v(1em)
      
      *催生大量工具:*
      - Clang-Format (代码格式化)
      - Clang-Tidy (静态分析)
      - LLDB (调试器)
      - ...
    ],[
      *文本表示的威力*
      
      *UNIX 哲学*: 简单工具 + 文本管道
      
      ```sh
      cat <file> | cut -f2 | sort | uniq -c
      ```
      
      #v(0.5em)
      
      LLVM IR 的文本表示:
      - 串联各个转换 Pass#footnote[Pass: 编译器中的一个独立转换单元, 负责特定的优化或代码生成任务.]
      - 方便查看中间状态
      - FileCheck 测试编译器
      - 输入可读文本并检查输出
    ]
  )
  
]

== LLVM 的局限: 中心化的代价

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    *问题 1: 中心化导致演进困难*
    
    - LLVM IR 处于 *绝对中心地位*
    - 所有工具、流程都依赖它
    - 修改需满足 *极高条件*:
      - 长时间高强度讨论
      - 各利益相关者同意
      - 避免意想不到的间接效应
    
    #v(0.5em)
    
    #text(fill: rgb(150, 0, 0))[
      $->$ 改动缓慢，特殊需求难满足
    ]
  ],[
    *问题 2: 衍生版本泛滥*
    
    常见方式: *分裂 LLVM，创建衍生版*
    
    - 每天 100 次提交到上游
    - 不追踪 $->$ 偏离严重，无法合并
    - 持续追踪 $->$ 专门人力投入
    
    #v(0.5em)
    
    #text(fill: rgb(150, 0, 0))[
      $->$ 全球范围内大量重复劳动
    ]
  ]
)

== LLVM 的局限: 演进 vs 兼容性

#slide[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    align(horizon)[
      *LLVM IR 的设计权衡*
      
      - 能够协同演进 IR 和编译器
      - 对质量提升至关重要
      - 兼容性保证较弱, 允许不兼容的变动
      
      *真正的使用场景:*
      
      > 作为不同 *软件模块* 间的表示

      #text(weight: "bold", fill: rgb(200, 0, 0))[
        不适合的使用场景:
      ]
      
      > 作为程序的 *传送格式* 给硬件驱动

    ],[
      *教训: SPIR $->$ SPIR-V*

      SPIR 最初基于固定版本的 LLVM IR, 通过 intrinsic 和 metadata 扩展来支持 OpenCL. 
      
      但这种方案在兼容性和硬件集成方面问题频发, 迫使 Khronos Group 重新设计了独立的 SPIR-V 格式, 专门为 GPU 传输和跨版本兼容性优化.
    ]
  )
]

== AI 时代的挑战

#slide[
  *场景：一行 PyTorch 代码的旅程*

  ```python
  output = model(input)  # 看起来很简单
  ```

  但它可能运行在: CPU, GPU, TPU, NPU, 以及各种定制芯片...

  #v(1em)

  #grid(
    columns: (1.2fr, 1fr, 1fr),
    gutter: 1.5em,
    [
      *硬件多样性爆炸*
      - LLVM IR 设计于 CPU 时代
      - AI 需要张量操作和并行计算
      - 每种硬件都有独特特性
      
      #text(fill: rgb(200, 0, 0))[
        $->$  抽象层次太低
      ]
    ],[
      *信息丢失问题*
      // TODO: 修改此处例子使其更贴切
      降级到 LLVM IR 后变成几千行指令, 编译器看不出这是矩阵乘法
      
      #text(fill: rgb(200, 0, 0))[
        $->$ 错失优化机会
      ]
    ],[
      *编译生态碎片化*
      - 每个框架重复造轮子
      - 硬件厂商多重适配
      
      #text(fill: rgb(200, 0, 0))[
        $->$  巨大重复投入
      ]
    ]
  )
]
