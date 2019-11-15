library(topicmodels)
library(data.table)
library(ggplot2)
#you might need to install gganimate: devtools::install_github("dgrtwo/gganimate")
library(gganimate)


lda_iter_seq <- function(dtm, k, alpha=50/k, n_topterms=10, iter_range=c(0,5,10,25,50,100), seed=1) {
  n = length(iter_range)  
  results = vector('list', n)
  
  for (i in n:1) {
    cat('iter: ', iter_range[i], ' / ', iter_range[n],'\n')
    m <- LDA(dtm, method = 'Gibbs', control = list(seed=seed, alpha=alpha, iter = iter_range[i]), k = k)
    if (i == n) topterms = get_topterms(m, n_topterms)
    results[[i]] = get_termXtopic(m, topterms)
  }
  d = bind_frames(results, frame_labels=iter_range)
}

bind_frames <- function(mlist, frame_labels=1:length(mlist)) {
  dlist = sapply(mlist, melt, simplify = F)
  rowcount = sapply(dlist, nrow)
  d = rbindlist(dlist)  
  setnames(d, old=c('Var1','Var2'), new=c('term','topic'))
  d$frame = rep(frame_labels, rowcount)
  d
}

get_topterms <- function(m, n_topterms) {
  topterms = terms(m, n_topterms)
  unique(unlist(as.list(topterms)))
}

get_termXtopic <- function(m, topterms) {
  termXtopic = t(posterior(m)$terms[,topterms])
  termXtopic / rowSums(termXtopic) ## make relative for clear colors
}


####################################
data("AssociatedPress", package = "topicmodels")
dtm = AssociatedPress[1:500,]

iter_range = c(0:20,30,50,60,70,80,90,100,125,150,175,200,250)
d = lda_iter_seq(dtm, k=5, n_topterms=10, alpha=1, iter_range=iter_range, seed=1)

p = ggplot(data = d, aes(x = topic, y = term)) +
  geom_tile(aes(fill = d$value), colour = "grey50") +
  ggtitle("Iterations: ")+
  transition_manual(frame)
gganimate::animate(p)
