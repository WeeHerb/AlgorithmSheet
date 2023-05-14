#let print = false

#let explain(body) = if( not print) [ 
  #block(
    width: 100%,
    stroke: 1pt,
    inset: 4pt,
    [
      #rect(
        fill: luma(200),
        [解释(非打印内容)]
      )
      #body
    ]
  )
]

#let alert(body) = {
  set text(white)
  align(
    end,
    rect(
      fill: red,
      inset: 8pt,
      radius: 4pt,
      [*小心!*\ #body],
    )
  )
}

#let todo(content) = {
  set text(white)
  rect(
    fill: orange,
    width: 100%,
    inset: 12pt,
    [*TODO*

      #content
    ]
  )
}
