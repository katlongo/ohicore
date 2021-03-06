# See: https://gist.github.com/bbest/8173863

# remove old packages
for (p in c('ohicore','ohigui','rCharts')){  
  if (p %in% rownames(installed.packages())){
    lib = subset(as.data.frame(installed.packages()), Package==p, LibPath, drop=T)
    remove.packages(p, lib)  
  }
}

# install dependencies
for (p in c('devtools')){
  if (!require(p, character.only=T)){
    install.packages(p)
    require(p, character.only=T)
  }
}

# install packages
install_github('ohi-science/rCharts')
install_github('ohi-science/ohicore')

# get scenarios and launch
library(ohicore)
get_scenarios('ohi-science/ohi-global', '~/ohi-global')
launch_app('~/ohi-global/eez2013')
