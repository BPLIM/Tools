# folder_archive: R-Script to archive a folder and document its contents

`folder_archive` is a function in [R](https://www.r-project.org/) that allows you to archive projects that are no longer being used by researchers both on the internal server and external BPLIM server.

## Source Code

To use the R-Script `folder_archive.R` you only need to open it in R or [RStudio](https://rstudio.com/). You can send the entire script to the R console. To do that, click the Source button in the top-right corner of the editor window or choose Code→Source File... and choose the R-Script. 

## Parameters

After reading the code you can use the function `folder_archive` with three parameters:

- ##### input_path
  Path of folder to archive
  
- ##### project
  The name you want to assign to the project to be archived. It can be the same or different from the original name of the project.
  
- ##### output_path
  Path to the directory where you want to save the archive.

## Output 

When you execute the function `folder_archive` you obtain the following message: *"The folder 'project' has been successfully archived!"*.

As a result of the function it is created a zip-file 'project_Arquivo.zip' which contains three elements:

- a directory 'project_Arquivo' with the folder structure in 'input_path' and all files with the extension '*txt*', '*ado*', '*do*', '*log*', '*R*' or '*py*';
- a file 'project_date.txt' with the tree structure of the archived folder and the names of the archived files;
- a file 'project_date.dta' with all the characteristics of the files in the folder to archieve, such as name, size, type, permissions, users, etc.
 
## Example 

To archieve the project 'p000_Teste' of the external server and save it in the 'Archieve' area of the internal server, you just need to execute the following line of the code: 
`folder_archive("/bplimext/data/p000_Teste","p000_Teste","/bplimext/data/archieve")`

## Author

**BPLIM Team**
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
