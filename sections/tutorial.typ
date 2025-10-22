#import "../globals.typ": *

= 编译器与中间表示

== 抽象: 人类应对复杂性的方式

== 正确性优先, 优化其次

== 中间表示: 连接抽象层次的桥梁

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

== 不是 IR, 而是构建 IR 的框架

MLIR (Multi-Level Intermediate Representation) 

#strike[Machine Learning Intermediate Representation (bushi)]

== 核心概念 1: Dialect

== 核心概念 2: Operation

== 核心概念 3: 渐进式递降

= Example: GEMM 的降级之旅

== 第一步: 我要算矩阵乘法

== 第二步: 怎么算? 分块 + 循环

== 第三步: 并行! 用上 SIMD

== 终点: 汇编代码

= 理论到实践: MLIR 落地了吗?

== DSL: 降低异构编程门槛

== 硬件适配: $"N"plus"M"$ 而非 $"N"times"M"$

== 研究创新: 原型与快速验证

= MLIR 未来与展望
