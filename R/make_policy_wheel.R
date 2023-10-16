###############################################################
#
# A Function to Plot Policy Wheel Data Visualizations
# Joshua Eagan
# 2023-10-12
# P.I. Beth Ann Griffin
#
###############################################################

# This code adapts code written by Max Griswald into a function

plot_policy_wheels = function(data,
                              policies = NULL,
                              policy_intervals,
                              year_range = NULL,
                              title = NULL,
                              plot_colors,
                              plot_width = 20, 
                              plot_height = 12,
                              legend_args = NULL,
                              out_file = paste0("policy_wheels_", Sys.Date(),".svg")){

        # Order states so that region-names make sense when applied to areas of the policy circle:
        states <- c("OH", "WI", "DE", "FL", "GA", "MD", "NC", "SC", "VA", "DC", "WV", "IA", 
                    "KS", "MN", "MO", "NE", "ND", "SD", "AL", "KY", "MS", "TN", "AR", "LA", 
                    "OK", "TX", "AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "CA", "OR", 
                    "WA", "AK", "HI", "CT", "ME", "MA", "NH", "RI", "VT", "NY", "NJ", "PA", 
                    "IL", "IN", "MI")
  
        # Load data and reshape long. Re-code policies as absorbing states at 5-year 
        # intervals
        df = data
        df <- melt(setDT(df), id.vars = "st_cd", variable.name = "policy", value.name = "implemented")
        
        df[, state := st_cd]
        df[, st_cd := NULL]
        
        # Convert implemented category into a 0/1, indicating if policy was implemented within
        # a given year.
        
        df[, implemented := parse_date_time(implemented, orders = c("mdy", "ymd", "B d, y", "y"))]
        df[, year := year(implemented)]
        df <- df[!is.na(year),]
        df[, implemented := as.numeric(implemented)]
        df[, implemented := 1]
        
        # Set up square dataset, then subset policy database to rows with observations.
        # Merge observations onto the square dataset.
        
        df_square <- expand.grid("state" = states,
                                 "policy" = policies,
                                 "year" = year_range)
        df <- setDT(merge(df_square, df, by = c("state", "policy", "year"), all.x = T))
        
        # Set implemented == T, for all years after the implementation year:
        setorder(df, state, policy, year)
        df[, implemented := nafill(.SD$implemented, "locf"), by = c("state", "policy")]
        df[is.na(implemented), implemented := 0]
        
        # Ordering policies:
        policies <- unique(df$policy)
        
        df <- df[(year %in% policy_intervals) & (implemented == 1),]
        
        # Set up dictionary for policy wheel options:
        wheel_opts <- data.table("policy" = policies,
                                 "i" = 1:6,
                                 "col" = plot_colors)
        
        # setting up output
        if(grepl("\\.svg", out_file)){
          svg(filename = out_file,
              width = plot_width, height = plot_height)
        } else if(grepl("\\.pdf", out_file)){
          pdf(filename = out_file,
              width = plot_width, height = plot_height)
        } else {
          stop("currently, only .svg and .pdf are supported. Please choose a different file extention for `out_file`.")
        }
        
        # Create layout onto which the chart's title, legend, and policy wheels will be pasted onto
        layout.mat <- matrix(c(1,2,3), ncol = 3, nrow = 1)                 # plot matrix
        layout.mat <- rbind(layout.mat, matrix(4, nrow=1, ncol=3)) # space for the legend
        
        layout(layout.mat, respect = TRUE, heights = c(6, 1), widths = c(5, 5, 5))
        
        lapply(policy_intervals, plot_policy_wheel_internal)
        
        if(!is.null(title)){
          plot.new()
          plot.window(xlim=c(0,1), ylim=c(0,1))
          ll <- par("usr")
          text(1, 1, title, cex=1)
        }

        # Add legend in correct order of colors:
        col_order <- matrix((3*2):1, nrow = 3, ncol = 2, byrow = T)
        
        par(xpd=TRUE)
        plot.new()
        plot.window(xlim = c(0,3), ylim = c(0,5))
        ll <- par("usr")
        do.call(legend, legend_args)
        
        dev.off()
        
}
