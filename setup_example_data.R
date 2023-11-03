###############################################################
#
# Cleaning policy data
# Joshua Eagan
# 2023-10-31
# P.I. Beth Ann Griffin
#
###############################################################

# loading packages
library(tidyverse)
library(curl)

# Statistical mode
mode <- function(x) {
  ux <- unique(x)
  ux = ux[!is.na(ux)]
  ux[which.max(tabulate(match(x, ux)))]
}

# if the policy data needs do be downloaded, do that

# this needs to be troubleshooted- 403 errors from the curl preventing this
if(!dir.exists("./data/raw/NAL")){

  urls = c("https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68648/RAND_EP68648-OBBT.zip",
           "https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP69157/RAND_EP69157-IMD.zip",
           "https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68090/RAND_EP68090-NAL.zip",
           "https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68218/RAND_EP68218-GSL.zip",
           "https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68090/RAND_EP68090_Coprescrib-NAL.zip",
           "https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68218/RAND_EP68218-PDMP.zip",
           "https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP67480/RAND_EP67480-MMPD.zip")
  
  for(i in 1:length(urls)){

    # curling data from RAND website
    url <- urls[i]
    local_file <- paste0("./data/raw/", sub(".*/", "", url))
    curl_download(url, destfile = local_file)
    
    # Open a connection to the zip file
    zip_con <- unz(local_file)
    
    # Extract the contents of the zip file to a local directory
    extract_dir <- "./data/raw/"
    files <- list.files(zip_con)
    for (file in files) {
      unz(zip_file, file, exdir = extract_dir)
    }
    
    # Close the connection to the zip file
    close(zip_con)
  }
  
}

# cleaning the policy data

policy_datasets = list()
raw_paths = c("./data/raw/OBBT/WEB_OBBT.xlsx",
              "./data/raw/IMD/WEB_IMD-Waiver.xlsx",
              "./data/raw/NAL/WEB_NAL_1990-2022.xlsx",
              "./data/raw/GSL/WEB_GSL_1990-2021.xlsx",
              "./data/raw/Co-prescribing NAL/WEB_Coprescribing_NAL.xlsx",
              "./data/raw/PDMP 12-2020/WEB_OPTIC_PDMP.xlsx",
              "./data/raw/Medical Marijuana Policy Data/WEB_MJ Policy.xlsx")
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
write.csv(clean_long, file = "./data/processed/example_data_long.csv")
write.csv(clean_wide, file = "./data/processed/example_data_wide.csv")
