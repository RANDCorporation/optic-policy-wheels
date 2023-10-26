# Below fills in policy wheel cells by year and policy
fill_in_cells <- function(p, y, df, wheel_opts){
  
  state_implementors <- unique(df[policy == p & year == y]$state)
  
  track_index <- wheel_opts[policy == p]$i
  track_color <- wheel_opts[policy == p,]$col
  
  for (s in state_implementors){
    draw.sector(get.cell.meta.data("cell.start.degree", sector.index = s),
                get.cell.meta.data("cell.end.degree", sector.index = s),
                rou1 = get.cell.meta.data("cell.top.radius", track.index = track_index),
                rou2 = get.cell.meta.data("cell.bottom.radius", track.index = track_index),
                col = track_color)
  }
}
