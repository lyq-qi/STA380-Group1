library(tm) 
library(tidyverse)
library(slam)
library(proxy)



#Reading all Folders
readerPlain = function(fname){
  readPlain(elem=list(content=readLines(fname)), 
            id=fname, language='en') 
}

#set up train
train=Sys.glob('~/Desktop/School/UT/Grad/MSBA/Summer/Intro to Machine Learning/2nd Half/data/ReutersC50/C50train/*')

#get all the files
file_list = NULL
labels = NULL
for(author in train) {
  author_name = substring(author, first=29)
  files_to_add = Sys.glob(paste0(author, '/*.txt'))
  file_list = append(file_list, files_to_add)
  labels = append(labels, rep(author_name, length(files_to_add)))
}

all_docs = lapply(file_list, readerPlain)
#clean up file names
mynames = train %>%
  { strsplit(., '/', fixed=TRUE) } %>%
  { lapply(., tail, n=2) } %>%
  { lapply(., paste0, collapse = '') } %>%
  unlist

#Rename the articles
names(all_docs) = mynames

#create a text mining "corpus
documents_raw = Corpus(VectorSource(all_docs))

#some pre-process
my_documents = documents_raw %>%
  tm_map(content_transformer(tolower))  %>%             # make everything lowercase
  tm_map(content_transformer(removeNumbers)) %>%        # remove numbers
  tm_map(content_transformer(removePunctuation)) %>%    # remove punctuation
  tm_map(content_transformer(stripWhitespace))          # remove excess white-space

#remove the stopwords
my_documents = tm_map(my_documents, content_transformer(removeWords), stopwords("en"))

## create a doc-term-matrix from the corpus
DTM_train = DocumentTermMatrix(my_documents)
DTM_train # some basic summary statistics
DTM_train = removeSparseTerms(DTM_train, 0.95) #removes those terms that have count 0 in >95% of docs.  
DTM_train # now ~ 804 terms (versus ~32000 before)

# construct TF IDF weights -- might be useful if we wanted to use these
# as features in a predictive model
tfidf_train = weightTfIdf(DTM_train)
DTM_train <- as.matrix(tfidf_train)
tfidf_train


#Repeat for test
#set up test
test=Sys.glob('~/Desktop/School/UT/Grad/MSBA/Summer/Intro to Machine Learning/2nd Half/data/ReutersC50/C50test/*')

#get all the files
file_list1 = NULL
labels1 = NULL
for(author in test) {
  author_name1 = substring(author, first=29)
  files_to_add1 = Sys.glob(paste0(author, '/*.txt'))
  file_list1 = append(file_list1, files_to_add1)
  labels1 = append(labels1, rep(author_name1, length(files_to_add1)))
}

all_docs1 = lapply(file_list1, readerPlain)
#clean up file names
mynames1 = train %>%
  { strsplit(., '/', fixed=TRUE) } %>%
  { lapply(., tail, n=2) } %>%
  { lapply(., paste0, collapse = '') } %>%
  unlist

#Rename the articles
names(all_docs1) = mynames1

#create a text mining "corpus
documents_raw1 = Corpus(VectorSource(all_docs1))

#some pre-process
my_documents1 = documents_raw1 %>%
  tm_map(content_transformer(tolower))  %>%             # make everything lowercase
  tm_map(content_transformer(removeNumbers)) %>%        # remove numbers
  tm_map(content_transformer(removePunctuation)) %>%    # remove punctuation
  tm_map(content_transformer(stripWhitespace))          # remove excess white-space

#remove the stopwords
my_documents1 = tm_map(my_documents1, content_transformer(removeWords), stopwords("en"))

## create a doc-term-matrix from the corpus
DTM_test = DocumentTermMatrix(my_documents1)
DTM_test # some basic summary statistics
DTM_test = removeSparseTerms(DTM_test, 0.95) #removes those terms that have count 0 in >95% of docs.  
DTM_test # now ~ 819 terms (versus ~32000 before)

#Since train and test are different lengths, make the test length the same as the train 
#Construct TFIDF for test
DTM_test=DocumentTermMatrix(my_documents1,list(dictionary=colnames(DTM_train)))
tfidf_test = weightTfIdf(DTM_test)
DTM_test<-as.matrix(tfidf_test) #Matrix
tfidf_test #804 terms




####
# Dimensionality reduction
####
DTM_train_1 <- DTM_train[,which(colSums(DTM_train) != 0)] 
DTM_test_1 <- DTM_test[,which(colSums(DTM_test) != 0)]

#PCA
pca_tr = prcomp(DTM_train_1,scale=TRUE)
pred_pca=predict(pca_tr,newdata = DTM_test_1)
plot(pca,type='line')
plot(cumsum(pca_tr$sdev^2/sum(pca_tr$sdev^2)))
#Majority (50%) var explained at PC159 so lets use that

pca_ts = prcomp(DTM_test_1,scale=TRUE)

#Classification techniques 

#classification setup
tr = data.frame(pca_tr$x[,1:159]) #x-variables
tr['labels']=labels #y-variable
ts <- data.frame(pca_ts$x[,1:159]) #x-variables
ts['labels1']=labels1 #y-variable

#Random Forest Technique

library(randomForest)
set.seed(848484)
rf<-randomForest(as.factor(labels)~.,data=tr, mtry=5,importance=TRUE)
pred_rf<-predict(rf,data=ts,type="class")
author<-as.factor(ts$labels1)
acc_df<-as.data.frame(cbind(author,pred_rf))
acc_df$same<-ifelse(acc_df$author==acc_df$pred_rf,1,0)
rf_acc = sum(acc_df$same)/nrow(acc_df)
rf_acc
#74.48%


#Naive-Bayes

library(e1071)
set.seed(848484)
nbay = naiveBayes(formula = as.factor(labels) ~ ., data = tr, 
                  laplace = 1)
pred_nbay = predict(nbay, ts, type="class")
author<-as.factor(ts$labels1)
acc_df<-as.data.frame(cbind(author,pred_nbay))
acc_df$same<-ifelse(acc_df$author==acc_df$pred_nbay,1,0)
nbay_acc = sum(acc_df$same)/nrow(acc_df)
nbay_acc
#3.4%

