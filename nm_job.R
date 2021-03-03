## get data partitioned and run the nm per fold

nm_job <- function(xfile, yfile, K, otdir){
  #get data
  load(xfile) # it returns df/matrix X
  load(yfile) # it returns df/matrix Y

  # get sub ids
  subids = X[,'sub']
  X = subset(X, select = -(sub)) # drop sub column


  # creating folds
  print('partitioning data')
  folds = createFolds(seq(length(subids)), K)

  # iterate over K folds
  for(k in 1:K){
    print(paste("processing fold", k, ":"))

    idx = folds[[k]]
    sublist = subids[idx]
    x = X[-sublist, ] # training set x
    xx = X[sublist, ] # testing set x
    y = Y[-sublist, ] # training set y
    yy = Y[sublist, ] # testing set y; true response

    # normalize data
    x = scale(x, scale = T, center = T)
    xx = scale(xx, scale = T, center = T)
    y = scale(y, scale = T, center = T)
    yy = scale(yy, scale = T, center = T)

    ## estimate nm
    # make empty matrices to stack results
    EVA.df = matrix(nrow = 1, ncol = 3)
    DEV.df = matrix(nrow = 1, ncol = 2)

    # model estimate
    nruns = seq(ncol(y))
    # model estimation can fail due to initiation values
    # repeat runs until all model estimations are completed
    while(length(nruns) > 0){
      # fit model per feature (eg, each column of Y)
      for(col in 1:ncol(yy)){
        if(col %in% nruns){
          y.train = y[, col]
          y.test = yy[, col]

          #run model
          print(paste('## estimating feature', col))
          try(nm_func(x, y.train, xx), silent=TRUE)

          # if estimation succeeded
          suppressWarnings(
            if(exists('alc.md')){
              #remove current ft number from nrun
              nruns = nruns[nruns != col]

              # calculate model fit metrics
              RMSE = sqrt(mean((alc.md$mean - y.test)^2))
              r = as.numeric(cor.test(alc.md$mean, y.test, method = 'pearson')$estimate)
              # calculate individual deviations
              Zdev = (y.test-alc.md$mean)/sqrt(alc.md$var)

              # stack output
              EVA.df = rbind(EVA.df, cbind(RMSE, r, col))
              DEV.df = rbind(DEV.df, cbind(as.numeric(Zdev), rep(col, length(Zdev))))

              # clean up old model
              rm('alc.md')

            }else{
              print('!! FAILED !! will repeat.', sep='')
            }
          )
        }

      }
    }

    # structure data
    EVA.df = as.data.frame(EVA.df[-1, ])
    names(EVA.df) = c('RMSE', 'Pearson.r', 'nfeature')
    DEV.df = as.data.frame(DEV.df[-1, ])
    names(DEV.df) = c('deviation', 'nfeature')
    # add sub idx
    DEV.df = cbind(sub = idx, DEV.df)

    #save output
    filename = file.path(otdir, paste('fold', k, '_md_metrics.Rda', sep = ''))
    save(file = filename, EVA.df)
    filename = file.path(otdir, paste('fold', k, '_deviations.Rda', sep = ''))
    save(file = filename, DEV.df)

    }



}
