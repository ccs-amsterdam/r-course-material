## From: https://www.r-bloggers.com/latent-dirichlet-allocation-under-the-hood/
## Generate a corpus

rawdocs <- c('dirichlet topic models',
             'words assigned to topic models',
             'dirichlet assigned topic',
             'dirichlet topic words',
             'topic models assigned words',
             'fashion models clothes',
             'clothes to models',
             'clothes to fashion',
             'fashion models',
             'jedi to the star',
             'star wars the movie')

#rawdocs = rawdocs[1:9]

## PARAMETERS
K <- 3 # number of topics
alpha <- .5 # hyperparameter. single value indicates symmetric dirichlet prior. higher=>scatters document clusters
eta <- .001 # hyperparameter
iterations <- 100 # iterations for collapsed gibbs sampling.  
seed = 1

set.seed(seed)
# 0. Prepare data: generate a list of documents
docs <- strsplit(rawdocs, split=' ', perl=T) 
## Assign WordIDs to each unique word
vocab <- unique(unlist(docs))
## Replace words in documents with wordIDs
for(i in 1:length(docs)) docs[[i]] <- match(docs[[i]], vocab)

# initialize:
## 1. Randomly assign topics to words in each doc.  2. Generate word-topic count matrix.
wt <- matrix(0, K, length(vocab)) # initialize word-topic count matrix
colnames(wt) = vocab
ta <- sapply(docs, function(x) rep(0, length(x))) # initialize topic assignment list
for(d in 1:length(docs)){ # for each document
  for(w in 1:length(docs[[d]])){ # for each token in document d
    ta[[d]][w] <- sample(1:K, 1) # randomly assign topic to token w.
    ti <- ta[[d]][w] # topic index
    wi <- docs[[d]][w] # wordID for token w
    wt[ti,wi] <- wt[ti,wi]+1 # update word-topic count matrix     
  }
}
wt
heatmap(wt)
# Now we generate a document-topic count matrix where the counts correspond to the number of tokens assigned to each topic for each document.

dt <- matrix(0, length(docs), K)
for(d in 1:length(docs)){ # for each document d
  for(t in 1:K){ # for each topic t
    dt[d,t] <- sum(ta[[d]]==t) # count tokens in document d assigned to topic t   
  }
}
dt

for(i in 1:iterations){ # for each pass through the corpus
  for(d in 1:length(docs)){ # for each document
    for(w in 1:length(docs[[d]])){ # for each token 
      t0 <- ta[[d]][w] # initial topic assignment to token w
      wid <- docs[[d]][w] # wordID of token w
      
      dt[d,t0] <- dt[d,t0]-1 # we don't want to include token w in our document-topic count matrix when sampling for token w
      wt[t0,wid] <- wt[t0,wid]-1 # we don't want to include token w in our word-topic count matrix when sampling for token w
      
      ## UPDATE TOPIC ASSIGNMENT FOR EACH WORD -- COLLAPSED GIBBS SAMPLING MAGIC.  Where the magic happens.
      denom_a <- sum(dt[d,]) + K * alpha # number of tokens in document + number topics * alpha
      denom_b <- rowSums(wt) + length(vocab) * eta # number of tokens in each topic + # of words in vocab * eta
      p_z <- (wt[,wid] + eta) / denom_b * (dt[d,] + alpha) / denom_a # calculating probability word belongs to each topic
      t1 <- sample(1:K, 1, prob=p_z/sum(p_z)) # draw topic for word n from multinomial using probabilities calculated above
      
      ta[[d]][w] <- t1 # update topic assignment list with newly sampled topic for token w.
      dt[d,t1] <- dt[d,t1]+1 # re-increment document-topic matrix with new topic assignment for token w.
      wt[t1,wid] <- wt[t1,wid]+1 #re-increment word-topic matrix with new topic assignment for token w.
      
      #if(t0!=t1) print(paste0('doc:', d, ' token:' ,w, ' topic:',t0,'=>',t1)) # examine when topic assignments change
    }
  }
}

wt
heatmap(wt)
wt