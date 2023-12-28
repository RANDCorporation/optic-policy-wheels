
# OPTIC Covariates Data Management

* Programmers: Joshua Eagan, Max Griswald
* PI: Beth Ann Griffin
* Created Date: 10/12/2023
* PPT: HCPCC010D

---

### Description

This repository contains code used to create policy wheel data visualizations.

---

### Programs:

* **demo.Rmd** - This R Markdown tutorial demonstrates how to create policy wheel data visualizations. It will eventually be incorporated into a vignette for a policy wheels shiny app.
* **R/make_policy_wheel.R** - This program creates policy wheel data visualizations with custom user data
* **R/plot_policy_wheel_internal.R** - This function is not called by the user directly- it is called "under the hood" of `make_policy_wheel` and creates the circular shell for each individual policy wheel.
* **R/fill_in_cells.R** - This is called by `plot_policy_wheel_internal.R`. It takes the user data and fills each cell of the policy wheel according to the dates policies were enacted.
* **app.R** - Policy wheel shiny app- under development

---

### Instructions:

To reproduce the demo, follow these steps:

1. pull this repository to your machine using [git pull](https://github.com/git-guides/git-pull) or by clicking the green drop down button that says code on this page, selecting `Download ZIP`, and unzipping that file somewhere on your computer.
2. Download the zip files from each of the following URLs to the Data/raw folder of the repository your just downloaded. Unzip them into Data/raw- they should be named correctly by default.

* https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68648/RAND_EP68648-OBBT.zip
* https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP69157/RAND_EP69157-IMD.zip
* https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68090/RAND_EP68090-NAL.zip
* https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68218/RAND_EP68218-GSL.zip
* https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68090/RAND_EP68090_Coprescrib-NAL.zip
* https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP68218/RAND_EP68218-PDMP.zip
* https://www.rand.org/content/dam/rand/pubs/external_publications/EP60000/EP67480/RAND_EP67480-MMPD.zip

3. Make sure a [modern version of R and R Studio](https://posit.co/download/rstudio-desktop/) are installed on your computer (we use `R version 4.3.2`).
4. Make sure to have the proper toolchain installed: linux: GCC and GNU Make, mac: [xcode](https://developer.apple.com/xcode/resources/), windows: [rtools](https://cran.r-project.org/bin/windows/Rtools/rtools43/files/rtools43-5863-5818.exe). Run `Sys.which("make")` from R to check that this was successful.
5. Launch R Studio, and open the `policy_wheels.Rproj` in the repository you obtained in step 1.
6. Run the line `renv::restore()` in the console (lower left hand corner of R studio). This installs some software dependencies. Follow the instructions in the console until this is finished running. If this fails, try [updating R and R Studio](https://posit.co/download/rstudio-desktop/) (selecting all the default settings) and double check that you have the proper toolchain installed (step 4).
7. Open the file `setup_example_data.R`, and run that file from start to finish. This creates the data you will be using in the demo. 
8. Open the `demo.Rmd` file- run this file from start to finish by pressing the knit button or (ctrl + shift + k)



