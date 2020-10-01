# folder contents & archive
# BPLIM Team
# 1 Oct 2020

folder_archive <- function(input_path,project,output_path){
  
  #*******************************************************************
  #                       Required Packages
  #*******************************************************************
  
  if ("fs" %in% rownames(installed.packages()) == FALSE){
    stop("Please install the required package 'fs' and try again!")
  }
  if ("haven" %in% rownames(installed.packages()) == FALSE){
    stop("Please install the required package 'haven' and try again!")
  }
  if ("zip" %in% rownames(installed.packages()) == FALSE){
    stop("Please install the required package 'haven' and try again!")
  }
  library(fs)
  library(haven)
  library(zip, warn.conflicts = FALSE)
    
  #*******************************************************************
  #                     Log file to save the tree
  #*******************************************************************
  
  setwd(output_path)
  output_file <- paste(project,"_",Sys.Date(),sep="")
  log_file <- paste(output_file,".txt",sep="")
  sink(log_file)
  dir_tree(input_path)
  list_of_files <- list.files(input_path,
                      pattern = ".txt$|.ado$|.do$|.log$|.R$|.py$", 
                      recursive = T)
  print("Files to archive:")
  print(list_of_files)
  sink()
    
  #*******************************************************************
  #        Create a dataset with file characteristics
  #*******************************************************************
    
  #Export the files information
  info_file <- paste(output_file,".dta",sep="")
  write_dta(data.frame(dir_info(input_path,recurse=TRUE)),
            info_file)
  
  #*******************************************************************
  #     Create a folder with the structure and files to archive
  #*******************************************************************  
  
  output_archive <- paste(project,"_Arquivo",sep="")
  dir.create(output_archive)
  setwd(output_archive)
    
  list_of_dirs <- list.dirs(input_path,
                            recursive = T,
                            full.names = F)
  for (d in list_of_dirs){
    if (d!=""&d!=".hidden") dir.create(d)
  }
  for (f in list_of_files){
    out <- "."
    ind <- max(gregexpr("/",f)[[1]])
    if (ind!=-1){
      out <- substr(f,1,ind-1)
    }
    file.copy(paste(input_path,"/",f,sep=""),
              out,
              recursive = T)
  }
  
  #*******************************************************************
  #         Create the zip file with all the information
  #*******************************************************************  
  
  #Create a zip file with:
  #tree, file characteristics, folder structure and files to archive
  setwd(output_path)
  zip::zip(paste(output_archive,".zip",sep=""),
           files=c(log_file,info_file,output_archive))
  file.remove(log_file,info_file)
  unlink(output_archive,recursive = T)
  print(log_file)
  print(info_file)
  print(output_archive)
  message(paste("The folder",project,
                "has been successfully archived!"))

  #*******************************************************************

}