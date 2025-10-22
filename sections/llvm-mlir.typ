#import "../globals.typ": *

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