
{smcl}
{.-}
help for {cmd:checkmd} {right:()}
{.-}
 
{title:Title}

checkmd - verifies logical conditions provided by a structured csv file, exporting the results to an html file

{title:Syntax}

{p 8 15}
{cmd:checkmd} [{help if}] , [{it:options}]

{p}

{title:Description}

{p} 
This command verifies logical conditions provided by a csv file within a dataset or between datasets. 
Two html documents are produced: one that presents detailed information about each check and other that contains the summary for all checks performed.
Instructions on how to write the csv file will be provided in this document.
 
{title:Options}

General Options

{p 0 4}{opt csv_file()} provides information on checks that will be performed. If the user does not specify this option, the program will look
for a csv file in the current working directory with the same name as the dataset in memory. Please note that if the program does not find this file,
it won't produce the html files, presenting solely the table mpz (see below) in stata.

{p 0 4}{opt out_path()} path for outputs (html files, dataset with inconsistent values). If not specified, output files will be saved in the current working directory.

{p 0 4}{opt id()} observation id, which will be equal to _n if not specified.

{p 0 4}{opt linesize(#)} equivalent to set linesize #. The default value is 255.

{p 0 4}{opt listinc} lists inconsistencies in the html file.

{p 0 4}{opt save_obs(#)} is the number of inconsistencies to be saved. Set # = 0 to keep all inconsistent observations.
observations.

{p 0 4}{opt mpz(varlist)} creates a table for {it: varlist} with missing values, positive values, zeros and observations for which value labels are missing. If absent, the table will contain all 
 variables in the dataset. Set the argument to "nompz" to suppress this output. 

{p 0 4}{opt inc_only} hmtl files will only display checks with inconsistent values.

{p 0 4}{opt addvars(varlist)} adds {it: varlist} to the dataset with inconsistencies (if {opt save_obs} was specified).

{p 0 4}{opt tvar(var)} summarizes the inconsistencies along the dimensions of {it: var}.

{p 0 4}{opt keepmd} keeps intermediate stmd files.

{p 0 4}{opt verbose} shows the progress of the program.


{title:Instructions on how to write the csv file}

For help on how to fill in the csv file that the user should provide to support this command, please refer to the {browse "https://github.com/BPLIM/Tools/blob/master/ados/General/checkmd/csv_guide.md":command's Github page}.


{title:Examples}

Example 1:
Checks for dataset auto with the csv file presented above as the auxiliary file, listing inconsistent values
and saving 10 inconsistencies per check (in case they exist) to an external dataset.

{p 8 16}{inp:. sysuse auto, clear}{p_end}
{p 8 16}{inp:. checkmd, csv_file(auto) listinc save_obs(10) }{p_end}

Example 2:
Checks for dataset auto with the csv file presented above as the auxiliary file, listing inconsistent values 
but only displaying checks with inconsitencies. 

{p 8 16}{inp:. sysuse auto, clear}{p_end}
{p 8 16}{inp:. checkmd, csv_file(auto) listinc inc_only }{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 

{title:Dependencies}

{cmd:markstat} (version 2.2.0 7may2018) by Germán Rodríguez
{cmd:package matrixtools} by Niels Henrik Bruun
{cmd:gtools} package by Mauricio Bravo


{title:Author}

{p}
BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

I appreciate your feedback. Comments are welcome!

