#import "template.typ": *
#show: project.with(
  title: "算法小抄",
  authors: (
    (name: "mslxl", email: "i@mslxl.com"),
    (name: "galong", email: "303987897@qq.com"),
  )
)

#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 10pt,
  width: 100%
)

#outline(indent: true)
#import "env.typ"


#set heading(numbering: "I.1.a.")

#include "util/util.typ"
#include "string/string.typ"
#include "range/range.typ"
#include "dp/dp.typ"
#include "graph/graph.typ"
#include "math/math.typ"
#include "game/game.typ"
#include "poly/poly.typ"
#include "model/model.typ"
#include "lib/lib.typ"
#include "other/other.typ"