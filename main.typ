#import "./globals.typ": *

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.title,
  navigation: none,
  config-info(
    title: [MLIR: 通用编译栈的积木],
    // subtitle: [打造可复用的 AI 基础设施],
    author: [xvyv99],
    date: [2025-10-25],
    institution: [HITLUG],
    slide-level: 1,
  ),
  config-common(new-section-slide-fn: new-section-slide),
  primary: rgb("#005476"),
)

#set text(
  font: ("Palatino", "STFangsong"), 
  lang: "zh",
  weight: "medium",
)

#show: show-cn-fakebold
#show emph: text.with(font: ("Palatino", "Kaiti SC"))

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show raw: it => {
  show regex(" pin\d "): it => pin(eval(it.text.slice(4)))
  it
}

#title-slide-patched()

#outline-slide-patched()

#include "sections/tutorial.typ"
#include "sections/llvm.typ"
#include "sections/mlir.typ"
// #include "sections/example.typ"
#include "sections/practice-future.typ"

// TODO: Reference slide

#focus-slide[
  #set text(size: 35pt)
  感谢聆听
]
