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
                              state_var = "state",
                              policy_intervals,
                              nrows = NULL,
                              ncols = NULL,
                              panel_width = 7,
                              panel_height = 6,
                              byrow = TRUE,
                              plot_colors,
                              plot_width = 20, 
                              plot_height = 12,
                              legend_args = list(x = "center",
                                                 xjust = 0.5, y.intersp = 1.3, 
                                                 x.intersp = 1.3, cex = 2, 
                                                 pt.cex = 2.7, bty = "n", ncol = 2),
                              out_file = paste0("policy_wheels_", Sys.Date(),".svg")){

        # some error catching
        if(any(!(policies %in% names(data)))){
          stop("make sure all values in `policies` are variable names in your data.")
        }
  
  
        # configuring default arguments to determine layout of policy wheels if they are not provided
        if(is.null(nrows)){
          nrows = ceiling(length(policy_intervals)/3)
        }
        if(is.null(ncols)){
          ncols = min(length(policy_intervals), 3)
        }
  
        # Order states so that region-names make sense when applied to areas of the policy circle:
        states <- c("OH", "WI", "DE", "FL", "GA", "MD", "NC", "SC", "VA", "DC", "WV", "IA", 
                    "KS", "MN", "MO", "NE", "ND", "SD", "AL", "KY", "MS", "TN", "AR", "LA", 
                    "OK", "TX", "AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "CA", "OR", 
                    "WA", "AK", "HI", "CT", "ME", "MA", "NH", "RI", "VT", "NY", "NJ", "PA", 
                    "IL", "IN", "MI")
  
        # Load data and reshape long. Re-code policies as absorbing states at 5-year 
        # intervals
        df = as.data.frame(data)[c(state_var, policies)]
        df <- melt(setDT(df), id.vars = state_var, variable.name = "policy", value.name = "implemented")
        names(df)[names(df) == state_var] <- "state"

        # Convert implemented category into a 0/1, indicating if policy was implemented within
        # a given year.
        
        df[, implemented := parse_date_time(implemented, orders = c("mdy", "ymd", "B d, y", "y"))]
        df[, year := year(implemented)]
        df <- df[!is.na(year),]
        df[, implemented := as.numeric(implemented)]
        df[, implemented := 1]
        
        # for policies that were passed before the first year of the policy wheel, 
        # make sure they are included
        df$year[df$year < min(policy_intervals)] = min(policy_intervals)
        
        # Set up square dataset, then subset policy database to rows with observations.
        # Merge observations onto the square dataset.
        year_range = min(policy_intervals):max(policy_intervals)
        
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
                                 "i" = 1:length(policies),
                                 "col" = plot_colors)
        
        # setting up output
        if(grepl("\\.svg", out_file)){
          svg(filename = out_file,
              width = plot_width, height = plot_height)
        } else if(grepl("\\.pdf", out_file)){
          pdf(filename = out_file,
              width = plot_width, height = plot_height)
        } else if(grepl("\\.png", out_file)){
          png(filename = out_file,
              width = plot_width, height = plot_height)
        } else {
          stop("currently, only .svg, .png, and .pdf are supported. Please choose a different file extention for `out_file`.")
        }
        
        # Create layout onto which the chart's title, legend, and policy wheels will be pasted onto
        
        # this is flexible to accommodate different wheel amounts
        layout.mat <- matrix(1:(nrows*ncols), ncol = ncols, nrow = nrows, byrow = byrow) # plot matrix
        layout.mat <- rbind(layout.mat, matrix((nrows*ncols)+1, nrow=1, ncol=ncols)) # space for the legend
        layout(layout.mat, respect = TRUE, 
               heights = c(rep(panel_height, nrows), (ceiling(length(policies)/2)*2)*.25),
               widths = rep(panel_width, ncols))
        
        # adding policy wheels to plot
        lapply(policy_intervals, plot_policy_wheel_internal, states,  df, wheel_opts, policies)
        
        # if(!is.null(title)){
        #   plot.new()
        #   plot.window(xlim=c(0,1), ylim=c(0,1))
        #   ll <- par("usr")
        #   text(1, 1, title, cex=1)
        # }

        # Add legend in correct order of colors:
        leg_num = ceiling(length(policies)/2)*2
        col_order <- matrix(leg_num:1, nrow = leg_num/2, ncol = 2, byrow = T)
        
        par(xpd=TRUE)
        plot.new()
        plot.window(xlim = c(0,3), ylim = c(0,5))
        ll <- par("usr")
        
        legend_args = c(list(       legend = wheel_opts$policy[col_order],
                                    col = wheel_opts$col[col_order]),
                                    pch = 15,
                        
                        legend_args)
        do.call(legend, legend_args)
        
        invisible(dev.off())
        
}
