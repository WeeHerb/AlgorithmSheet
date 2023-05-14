#import "template.typ": *
#show: project.with(
  title: "算法小抄",
  authors: (
    (name: "mslxl", email: "i@mslxl.com"),
  ),
  date: "March 28, 2023",
)

#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 10pt,
  width: 100%
)

#outline(indent: true)
#import "env.typ"


#set heading(numbering: "I.1.a.")

#include "util/content.typ"
#include "string/content.typ"
#include "range/content.typ"
#include "dp/content.typ"
#include "graph/graph.typ"
#include "math/math.typ"
#include "game/game.typ"
#include "poly/content.typ"
#include "lib/content.typ"
#include "other/conetnt.typ"