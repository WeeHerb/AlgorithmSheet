// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "", authors: (), date: none, body) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)

  set text(font: "Source Han Sans SC", lang: "zh")

  show heading: it => [
    #pad(bottom: -10pt, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]

  set page(
    margin: (x: 0pt, y: 0pt),
  )
  box(
    width: 100%,
    height: 57%,
    inset: 0pt,
    fill: olive.lighten(60%),
    box(
      width: 100%,
      height: 95%,
      inset: 0pt,
      fill: olive.lighten(60%),
      image(
        width: 100%,
        "cover.png"
      )
    )
  )

  pad(x: 64pt, bottom: 32pt, top: 12pt)[
    // Title row.
    #align(left)[
      #block(text(weight: 700, 2.15em, title))
      #v(1.5em, weak: true)
      _#date _

    ]

    // Author information.
    #columns(2, gutter: 24pt)[
      #pad(
        x: 2em,
        y: 0.5em,
        text(
          fill: luma(100),
          grid(
            columns: (auto,auto),
            gutter: 1em,
            ..authors.map(author => ([
              - *#author.name*  
            ], [_<#author.email>_])
            ).join(),
          )
        )
      )
      #colbreak()
      #align(end)[
        #image(
          width: 128pt + 64pt,
          "side.png"
        )
      ]
    ]

    #v(1fr)
    #rect(
      inset: 8pt,
      fill: rgb("e4e5ea"),
      width: 100%,
      radius: 6pt,
      align(center)[
        #emph[
        "在没有结束前，总要做很多没有意义的事，这样才可以在未来某一天，用这些无意义的事去堵住那些讨厌的缺口"
        ]
      ]
    )
    
  ]



  // Main body.

  set par(justify: true)
  
  set footnote(numbering: "*")
  counter(page).update(1)

  body
}
