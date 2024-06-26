###############################################################
#
# Cleaning policy data
# Joshua Eagan
# 2023-10-31
#
###############################################################

# loading packages
library(dplyr)
library(readxl)
library(purrr)

# Statistical mode
mode <- function(x) {
  ux <- unique(x)
  ux = ux[!is.na(ux)]
  ux[which.max(tabulate(match(x, ux)))]
}

# cleaning the policy data

policy_datasets = list()
raw_paths = c("./Data/raw/OBBT/WEB_OBBT.xlsx",
              "./Data/raw/IMD/WEB_IMD-Waiver.xlsx",
              "./Data/raw/NAL/WEB_NAL_1990-2022.xlsx",
              "./Data/raw/GSL/WEB_GSL_1990-2021.xlsx",
              "./Data/raw/Co-prescribing NAL/WEB_Coprescribing_NAL.xlsx",
              "./Data/raw/PDMP 12-2020/WEB_OPTIC_PDMP.xlsx",
              "./Data/raw/Medical Marijuana Policy Data/WEB_MJ Policy.xlsx")
data_names = c("obbt", "imd", "nal", "gsl", "copnal", "pdmp", "mm")
for(i in 1:length(raw_paths)){
  
  # reading in policy data
  policy_datasets[[data_names[i]]] = readxl::read_excel(raw_paths[i], sheet = 2,) %>%
                                        dplyr::select(-starts_with("...")) %>%
                                        rename_with(.fn = ~ paste(data_names[i], .x, sep="_"), 
                                                    .cols = -c(state, year))

}

# looking at the data
purrr::map(policy_datasets, ~names(.x))
purrr::map(policy_datasets, ~dim(.x))

# checking year ranges
purrr::map(policy_datasets, ~ .x %>% pull(year) %>% unique())
# Co-prescribing only available through 2020, GSL through 2021, and NAL through 2022

# do all policy data sets track the same states?
purrr::map(policy_datasets, ~ .x %>% 
             pull(state) %>% unique())

# merging data sets
clean_long = policy_datasets %>% purrr::reduce(dplyr::full_join)

# creating an additional variable needed for the last policy wheel
clean_long$copnal_date_all_prescribe = clean_long$copnal_date_eff_all
clean_long$copnal_date_all_prescribe[clean_long$copnal_nat_mandate != "Mandate prescribing"] = NA

# creating a wide dataset
date_vars = names(clean_long)[grepl("_date", names(clean_long))]

# checking if there are multiple dates within one state/policy
for(i in 1:length(date_vars)){
  
  # making a state level count of the distinct number of dates
  tbl = clean_long %>% select(state, !!sym(date_vars[i])) %>%
    distinct() %>%
    filter(!is.na(!!sym(date_vars[i]))) %>%
    pull(state) %>%
    table()
  
  # printing out the variables and states that have multiple dates
  if(max(tbl) > 1){
    print(paste("multiple policies passed for one state: ", date_vars[i], ": ", names(tbl[tbl>1])))
  } 
}

# for all policies, there is only one non-missing date associated for each state.
# therefore, information will not be lost by transitioning to wide data.
clean_wide = clean_long %>% group_by(state) %>%
  summarize(across(date_vars, mode))
  
# ordering by state and year
clean_long = clean_long %>% arrange(state, year)

# writing output data
write.csv(clean_long, file = "./Data/processed/example_data_long.csv")
write.csv(clean_wide, file = "./Data/processed/example_data_wide.csv")
