set.seed(2466)

options(
  digits = 3,
  dplyr.print_max = 6,
  dplyr.print_min = 6
)

knitr::opts_chunk$set(
  cache = TRUE,
  collapse = TRUE,
  comment = "#>",
  fig.align = 'center',
  fig.asp = 0.618,  # 1 / phi
  fig.show = "hold"
)

# Stamps plots with a tag and line 
# Idea from Claus Wilke's "Data Visualization" https://serialmentor.com/dataviz/
stamp <- function(tag = "bad", tag_color = "#B33A3A", tag_size = 16, tag_padding = 1,
                  line_color = "#B33A3A", line_size = 3)
{
  list(
    annotate(
      geom = "segment",
      x = Inf,
      xend = Inf,
      y = -Inf,
      yend = Inf,
      color = line_color,
      size = line_size
    ),
    theme(
      plot.tag = element_text(color = tag_color, size = tag_size),
      plot.tag.position = "topright"
    ),
    labs(
      tag =
        str_pad(tag, width = str_length(tag) + tag_padding, side = "left")
    )
  )
}

