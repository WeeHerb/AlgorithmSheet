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
      align(
        start,
        [*注意 !*\ #body]
      )
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

#let label_page(label_name, show_content: true) = [
  #locate(loc => 
  {
    let target = label(label_name)
    let target_elem = query(target, loc).at(0)
    link(target)[
      #target_elem.location().position().page
      页
      #if show_content [
        #target_elem.body
      ]
    ]
  })
]