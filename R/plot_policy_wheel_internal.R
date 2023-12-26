plot_policy_wheel_internal <- function(y, states, df, wheel_opts, policies){
  
  # Establish margins & cell padding
  par(mai=c(0.35, 0.35, 0.35, 0.35), xpd = TRUE)
  circos.par(cell.padding = c(0, 0, 0, 0))
  
  # Add fifty-one sectors (i.e. one for each state + DC)
  circos.initialize(factors = states, xlim = c(0, 1))
  
  # Add tracks (one for each policy)
  replicate(length(policies), circos.track(ylim = c(0,1), track.height = 0.09), simplify = F)
  
  # Add state labels
  for(s in unique(states)) {
    highlight.sector(sector.index = s, track.index = 1,
                     text = s, padding = c(-.5,1,1.5,1), cex = 1.3, text.vjust = .5, col = NA, facing = "downward")
  }
  
  # Label each graph with the correct year (in the middle of the circles)
  text(0,0, labels = print(y), cex = 2.8)
  
  # Add line segments to distinguish between regions
  # for(s in c("CT", "NY", "IL", "DE", "IA", "AL", "AR", "AZ", "CA")) {
  #   circos.segments(x0 = -0.1, y0 = 0, x1 = -0.07, y1 = 5.8, lwd = 3.5, sector.index = s)
  # }
  for(s in c("CT", "NY", "IL", "DE", "IA", "AL", "AR", "AZ", "CA")) {
    circos.segments(x0 = -0.1, y0 = 0, x1 = -0.07, y1 = (1.16*length(policies)), lwd = 3.5, sector.index = s)
  }
  
  
  
  # Label the regions
  # New England
  highlight.sector(sector.index = c("CT", "ME", "MA", "NH", "RI", "VT"), track.index = 1,
                   text = "New England", padding = c(1,0,5,0), cex = 1.4, font = 2,
                   border = NA, col = NA, facing = "bending.inside")
  
  # Mid-Atlantic
  highlight.sector(sector.index = c("NY", "NJ", "PA"), track.index = 1,
                   text = "Mid-Atlantic", padding = c(1,0,5,0), cex = 1.4, font = 2,
                   border = NA, col = NA, facing = "bending.inside",
                   text.vjust = -1)
  
  # East North Central
  highlight.sector(sector.index = c("IL", "IN", "MI", "OH", "WI"), track.index = 1,
                   text = "East North Central", padding = c(1,0,5,0), cex = 1.4,
                   font = 2, border = NA, col = NA, facing = "bending.inside")
  
  # South Atlantic
  highlight.sector(sector.index = c("DE", "FL", "GA", "MD", "NC", "SC", "VA", "DC", "WV"),
                   track.index = 1, text = "South Atlantic", padding = c(1,0,5,0),
                   cex = 1.4, font = 2, border = NA, col = NA, facing = "bending.outside")
  
  # West North Central
  highlight.sector(sector.index = c("IA", "KS", "MN", "MO", "NE", "ND", "SD"),
                   track.index = 1, text = "West North Central", padding = c(1,0,5,0),
                   cex = 1.4, font = 2, border = NA, col = NA, facing = "bending.outside")
  
  # East South Central
  highlight.sector(sector.index = c("AL", "KY", "MS", "TN"), track.index = 1,
                   text = "East South Central", padding = c(1,0,5,0), cex = 1.4, font = 2,
                   border = NA, col = NA, facing = "bending.outside",
                   text.vjust = 1.65)
  
  # West South Central
  highlight.sector(sector.index = c("AR", "LA", "OK", "TX"), track.index = 1,
                   text = "West South Central", padding = c(1,0,5,0), cex = 1.4, font = 2,
                   border = NA, col = NA, facing = "bending.outside")
  
  # Mountain
  highlight.sector(sector.index = c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY"),
                   track.index = 1, text = "Mountain", padding = c(1,0,5,0), cex = 1.4,
                   font = 2, border = NA, col = NA, facing = "bending.inside")
  
  # Pacific
  highlight.sector(sector.index = c("CA", "OR", "WA", "AK", "HI"), track.index = 1,
                   text = "Pacific", padding = c(1,0,5,0), cex = 1.4,
                   border = NA, col = NA, font = 2, facing = "bending.inside")
  
  # Highlight states that implemented legislation by Jan 1 of that year
  lapply(policies, fill_in_cells, y = y,  df = df, wheel_opts = wheel_opts)
  
  circos.clear()
  
}
