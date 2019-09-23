
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

{p 0 4}{cmd: csv_file()} provides information on checks that will be performed. If the user does not specify this option, the program will look
for a csv file in the current working directory with the same name as the dataset in memory. Please note that if the program does not find this file,
it won't produce the html files, presenting solely the table mpz (see below) in stata.

{p 0 4} {cmd:out_path()} path for outputs (html files, dataset with inconsistent values). If not specified, output files will be saved in the current working directory.

{p 0 4} {cmd:id()} observation id, which will be equal to _n if not specified.

{p 0 4} {cmd: linesize(#)} equivalent to set linesize #. The default value is 255.

{p 0 4} {cmd: listinc} lists inconsistencies in the html file.

{p 0 4} {cmd: save_obs(#)} is the number of inconsistencies to be saved. Set # = 0 to keep all inconsistent observations.
observations.

{p 0 4} {cmd: mpz(varlist)} creates a table for varlist with missing values, positive values, zeros and observations for which value labels are missing. If absent, the table will contain all 
 variables in the dataset. Set the argument to "nompz" to suppress this output. 

{p 0 4} {cmd: inc_only} hmtl files will only display checks with inconsistent values.

{p 0 4} {cmd: addvars(varlist)} adds varlist to the dataset with inconsistencies (if {cmd: save_obs} was specified).

{p 0 4} {cmd: tvar(var)} timevar.

{p 0 4} {cmd: keepmd} keep stmd files.

{p 0 4} {cmd: merge(merge_options)} merges the master dataset with one provided in merge_options.

{p 0 4} {cmd: verbose} shows the progress of the program.


merge_options 

{p 4 8}{cmd: file()} dataset to be merged with master data.

{p 4 8}{cmd: type()} type of merge (1:1, 1:m or m:1).

{p 4 8}{cmd: key(var1,...)} key variable for merge.

{p 4 8}{cmd: [obs_keep(values)]} observations to keep. values = # to keep observations that satisfy _merge == # or values = #1,#2 to keep observations that satisfy _merge == #1 & _merge == #2
If not specified, all observations will be kept in the merged dataset.

{p 4 8}{cmd: [keep1(var1,var2,...)]} keeps variables from the first dataset. In the merged dataset, these variables will be renamed to d1_"varname".

{p 4 8}{cmd: [keep2(var3,var4,...)]} keeps variables from the second dataset. In the merged dataset, these variables will be renamed to d2_"varname".

Note: When merge is active, if the user does not specify the option csv_file, the program will look for a csv file in the current working directory with the 
name "dataset1name"_vs_"dataset2name".

Note: Variables in checks between datasets (i.e., when merge is active) should contain the prefix d1_ or d2_. It is important to note that the prefix d1_ will always be assigned
to variables from the master dataset.

{title:Instructions on how to write the csv file}

Example:
csv file for dataset auto


check_id	active	check_title						cond					delta	option	list_val
check1		1	Price smaller than 10000				price<10000				1	miss	10
check2		1	rep78 not missing					rep78<.						miss	5
check3		1	weight over length larger than 2			(weight/length)>2				miss	5
check4		1	price greater than mean price by foreign		price>mpbyf				1		5
		0	generating variable squared length			gen sq_length = length^2			miss	
		0	generating variable cubed weight			gen cub_weight = weight^3			
check5		0	Price is missing					missing(price)			
		2	generating variable mean price by foreign		egen mpbyf=mean(price),by(foreign)			
check6		1	Dodge in make						regexm(make,"Dodge")			


Variables check_id, active, check_title, cond, delta, option and list_val should always be present in the file.

Code active is mandatory for every row and translates to 1 for checks, 2 for stata code and 0 for inactive rows.

For active checks (active=1), attributes check_id, check_title and cond are mandatory.

For active stata code (active=2), attribute cond is mandatory.

delta is the optional margin of error for the condition. For delta = 0, the cell should be left unfilled. This option only works for single conditions, so it shouldn´t be combined 
with & and/or | in cond.

option should be "miss" if the user wants to turn missing values into zero for variables in cond. Otherwise, this cell should be left unfilled.

list_val is the number of inconsistent observations to be displayed in the html file. This option only works for single conditions and should be specified only for quantitative variables.


{title:Examples}

Example 1:
Checks for dataset auto with the csv file presented above as the auxiliary file.

{p 8 16}{inp:. sysuse auto, clear}{p_end}
{p 8 16}{inp:. checkmd, csv_file(auto) internal save_obs(10) }{p_end}

Example 2:

{p 8 16}{inp:. sysuse auto, clear}{p_end}
{p 8 16}{inp:. checkmd, csv_file(auto) internal save_obs(10) mpz(nompz) inc_only verbose}{p_end}

Example 3:
Checks for a merged dataset

{p 8 16}{inp:. cd "dir"}{p_end}
{p 8 16}{inp:. sysuse auto, clear}{p_end}
{p 8 16}{inp:. save auto1, replace}{p_end}
{p 8 16}{inp:. replace price = price + 100 if _n > 30}{p_end}
{p 8 16}{inp:. save auto2, replace}{p_end}
{p 8 16}{inp:. use auto1, clear}{p_end}
{p 8 16}{inp:. checkmd, csv_file("dir/auto1_auto2") id(make) internal save_obs(10) merge(file("dir/auto2") type(1:1) key(make) keep1(price) keep2(price))}{p_end}


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

