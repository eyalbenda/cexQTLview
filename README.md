# ceXQTLview

Viewer for ceX-QTL fitness data
## Getting Started

A simple shiny app to view fitness peaks from ceX-QTL experiments described in: https://www.biorxiv.org/content/early/2018/09/27/428870

### Quick start
Install prerequisite packages in R (running from RStudio is recommended)
```
install.packages(c("shiny","shinyWidgets","ggplot2","viridis","ggthemes","dplyr","shinycssloaders"))
```

You can then run the app directly from the repository using runGithub
```
library(shiny)
runGitHub("cexQTLview","eyalbenda")
```
