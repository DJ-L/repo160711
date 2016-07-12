setwd("M:\\DIRX\\R\\EXERCISES")

library(sqldf)

library(plyr)




#Loading features and activity labels
features<-read.csv("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\features.txt",stringsAsFactors=FALSE,header = FALSE,sep = " ")
activity_labels<-read.csv("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\activity_labels.txt",stringsAsFactors=FALSE,header = FALSE,sep = " ")

#Load test data
X_test<-read.table("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\test\\X_test.txt",stringsAsFactors=FALSE,header = FALSE)
y_test<-read.table("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\test\\y_test.txt",stringsAsFactors=FALSE,header = FALSE)
subject_test<-read.table("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\test\\subject_test.txt",stringsAsFactors=FALSE,header = FALSE)

#Load training data
X_train<-read.table("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\train\\X_train.txt",stringsAsFactors=FALSE,header = FALSE)
y_train<-read.table("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\train\\y_train.txt",stringsAsFactors=FALSE,header = FALSE)
subject_train<-read.table("M:\\DIRX\\R\\EXERCISES\\getdata_projectfiles_UCI HAR Dataset\\UCI HAR Dataset\\train\\subject_train.txt",stringsAsFactors=FALSE,header = FALSE)

#Merging test- and train data (This is step 1.)
full_y<-rbind(y_test,y_train)
full_subj<-rbind(subject_test,subject_train)
full_data<-rbind(X_test,X_train)
full_data<-cbind(full_y,full_data)
full_data<-cbind(full_subj,full_data)

#Finding the "mean" or "std" features (This is step 2, first part)
L<-grepl("mean|std",features$V2)
table(L)

#Naming the columns with the feature names and renaming the first column to "Activities" (This is step 2, continuation, and step 4.)
colnames(full_data)<-c("Subject","Activity_code",features$V2)
head(full_data)

#Selecting the mean-variables from the full data (This is step 2, complete)
L <- c(TRUE,TRUE,L) #Extend L with two initial TRUE to allow the Activities variable to remain
data_small <- full_data[,L]
head(data_small)

#Merge on activities names (This is step 3.)
data_small<-sqldf(
                    "select B.V2 as Activity, A.* 
                    from
                    data_small as A
                    left join
                    activity_labels as B
                    on A.Activity_code = B.V1"
)

#Data set with group means by activity and subject (This is step 5.)

data_means<- aggregate(data_small[,4:82], list(Activity=data_small$Activity,Subject = data_small$Subject),mean)
write.table(data_means,file = "data_means.txt",sep = "\t",row.name=FALSE, quote = FALSE)
    
