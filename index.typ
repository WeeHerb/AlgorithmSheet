#import "template.typ": *
#show: project.with(
  title: "算法模板",
  date: include("build_time.txt"),
  authors: (
    (name: "mslxl", email: "i@mslxl.com"),
  )
)


#set page(
  margin: auto,
  numbering: "I"
)
// #counter(page).update(1)
#outline(indent: true)

#set page(
  margin: auto,
  numbering: "1"
)
// #counter(page).update(1)
#import "env.typ"

#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 10pt,
  width: 100%
)
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