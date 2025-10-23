#import "../globals.typ": *

= Example: GEMM 的降级之旅

== 第一步: 来算矩阵乘法

GEMM: General Matrix Multiply (通用矩阵乘法)
- 深度学习中 80% (大概吧, 我也不清楚)的计算时间都花在矩阵乘法上

我们以 Buddy Compiler 中的 Pass 作为工具, 看它是如何一步步把高层的矩阵乘法算子, 降级为最终的汇编代码的.

开始的算子长这样:
```mlir
func.func @sgemm(%a : memref<?x?xf32>, %b : memref<?x?xf32>, %c : memref<?x?xf32>) {
  linalg.matmul
    ins(%a, %b: memref<?x?xf32>, memref<?x?xf32>)
    outs(%c: memref<?x?xf32>)
}
```

通过 `convert-linalg-to-affine-loops` 这个 Pass, 可以将这个 linalg.matmul 降级为显式的循环表示:

#text(size: 18pt)[

```mlir
func.func @sgemm(%arg0: memref<?x?xf32>, %arg1: memref<?x?xf32>, %arg2: memref<?x?xf32>) {
  %c1 = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %0 = call @rtclock() : () -> f64
  %dim = memref.dim %arg0, %c0 : memref<?x?xf32>
  %dim_0 = memref.dim %arg0, %c1 : memref<?x?xf32>
  %dim_1 = memref.dim %arg1, %c1 : memref<?x?xf32>
  affine.for %arg3 = 0 to %dim {
    affine.for %arg4 = 0 to %dim_1 {
      affine.for %arg5 = 0 to %dim_0 {
        %3 = affine.load %arg0[%arg3, %arg5] : memref<?x?xf32>
        %4 = affine.load %arg1[%arg5, %arg4] : memref<?x?xf32>
        %5 = affine.load %arg2[%arg3, %arg4] : memref<?x?xf32>
        %6 = arith.mulf %3, %4 : f32
        %7 = arith.addf %5, %6 : f32
        affine.store %7, %arg2[%arg3, %arg4] : memref<?x?xf32>
      }
    }
  }
  %1 = call @rtclock() : () -> f64
  %2 = arith.subf %1, %0 : f64
  vector.print %2 : f64
  return
}
```
]

== 第二步: 怎么算? 并行化

== 第三步: 并行! 用上 SIMD

== 终点: 汇编代码

// NOTE: 须说明为什么不直接用算子库
