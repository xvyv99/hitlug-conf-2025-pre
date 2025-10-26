# MLIR: 通用编译栈的积木

这个仓库包含 2025 年安同校园行哈工大站中题目为 **MLIR: 通用编译栈的积木**(抱歉, 临时改的题目, 海报中的题目是 **MLIR: AI 编译栈的积木**) 分享的演示文稿, 使用 Typst 构建.

## 构建文档
```sh
typst compile ./main.typ
```

## 仓库结构
- `main.typ`: 演示入口, 包含全局配置与章节引入.
- `globals.typ`: 包导入与常用宏定义.
- `sections/`: 按主题拆分的幻灯片内容 (`tutorial`, `llvm`, `mlir`, `practice-future` 等).
- `assets/`: 图像与其他静态资源.
- `refs.bib`: 参考文献.

## License

CC BY 4.0
