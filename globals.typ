#import "@preview/touying:0.6.1": *
#import themes.dewdrop: *

#import "@preview/cuti:0.3.0": show-cn-fakebold

#import "@preview/numbly:0.1.0": numbly
#import "@preview/pinit:0.2.2": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge


#let blob(pos, label, tint: white, ..args) = node(
	pos, align(center, label),
	width: auto,
	fill: tint.lighten(60%),
	stroke: 1pt + tint.darken(20%),
	corner-radius: 5pt,
	..args,
)

#let bold-text(txt) = text(weight: "bold")[#txt]

#import "./patch.typ": outline-slide-patched, title-slide-patched, new-section-slide
