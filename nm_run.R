## run nm job
# xfile: abs path to the .Rda file containing matrix/dataframe of independent vars
# yfile: abs path to the .Rda file containing matrix/dataframe of dependent vars
# xfile and yfile should have the same row number, representing the same subs
# K: number of folds for cross validation

# get working dir
path = getwd()

#get packages/functions
pkgs = c('laGP', 'caret')
#install.packages(pkgs)
invisible(suppressMessages(lapply(pkgs, require, character.only = TRUE)))
source('nm_job.R')
source('nm_func.R')

##specify parameters
K = 10
xfile = file.path(path, 'input_x.Rda') # columns=subid+predictors
yfile = file.path(path, 'input_y.Rda') # columns=responses

# run the job
nm_job(xfile, yfile, K, path)
print("#####################")
print('Mission Completed!')
print("#####################")
