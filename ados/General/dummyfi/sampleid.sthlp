{smcl}
{* *! version 0.1 28Sep2023}{...}{smcl}
{.-}
help for {cmd:sampleid} {right:}
{.-}

{title:Title}

{pstd}
{cmd:sampleid} {hline 1} samples observations based on id variables from data in memory

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:sampleid} {help varlist:varlist}
{cmd:} [, {it:options}],

where {help varlist:varlist} is a (list of) variable(s) that serves as the dataset identifier.

{synoptset 35 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt sample(#)}} samples {it:#}% of unique combinations of {help varlist}. 
May be combined with option {opt masterid}. In such cases, if the percentage of 
unique ids selected from {opt masterid} is less than the one specified in 
{opt sample}, the difference is sampled from the data in memory.
{p_end}
{synopt :{opt time:var(varname)}} is the time variable. If there is a time variable 
in the original data, the command will keep the time structure of the data.
{p_end}
{synopt :{opt masterid(filename)}} provides a file with unique combinations of 
id variables. This is helpful when you want to use the same entities across 
different datasets.
{p_end}
{synopt :{opt mastervars(varlist)}} provides a different {it:varlist} to select 
ids from {opt masterid}. The variables specified in this option must be a subset 
of the variables found in the {opt masterid} file. These variables will be used 
to merge with {opt masterid}, so any variable that does not appear in that file 
will cause the command to crash. If the id variables are the same as in 
{opt masterid}, just pass them to {help varlist}.
{p_end}
{synopt :{opt seed(#)}} specifies the initial value of the random-number 
seed used by {help sample} and {help runiform()}.
{p_end}
{synopt :{opt save(filename)}} saves the sampled IDs (and time variable) in {it:filename}.
{p_end}
{synopt :{opt replace}} replaces the ID files if it exists.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt sampleid} samples observations based on id variables from data in memory. 
The command samples {it:#%} of unique combinations of {help varlist}. 
Alternatively, a file with previously sampled ids may be provided 
with option {opt masterid}, in order to select the same ids for different 
datasets. The output is a Stata dataset with ids (and time variable if 
specified).

{pstd}
This command is the first step to generate random data using command 
{browse "https://github.com/BPLIM/Tools/tree/master/ados/General/dummyfi":dummyfi}. 
It creates a random sample of unique ids, which is then fed to {cmd:dummyfi} to 
generate a random version of the data using information collected from the data's 
metafile 
(see {browse "https://github.com/BPLIM/Tools/tree/master/ados/General/mdata":mdata}). 
The goal is to create random data with the same structure as the one in the 
original file. If option {opt timevar} is set, the time variable will be saved with 
sampled ids to keep the time structure of the data.

{pstd}
It is possible to use a subset of the variables saved in an ID file, combining 
options {opt masterid} and {opt mastervars}. In this case, the command is going 
to select unique combinations of {opt mastervars} from file {opt masterid}, 
using them to select rows from the data in memory.

{title:Examples}


{pstd}
Example 1: Sample 20% of idcodes from dataset {it:nlswork}, 
save them in file "nlswork_ID", along with 
time variable {it:year}.

{p 8 16}{inp:. webuse nlswork, clear}{p_end}
{p 8 16}{inp:. sampleid idcode, sample(20) time(year) save(nlswork_ID)}{p_end}

{pstd}
Example 2: Select ids from an ID dataset. If the 
percentage of matched ids is less than 25%, sample the difference from the data 
in memory. Save the data in "nlswork_ID" 

{p 8 16}{inp:. webuse nlswork, clear}{p_end}
{p 8 16}{inp:. !mv nlswork_ID.dta nlswork_ID_old.dta}{p_end}
{p 8 16}{inp:. sampleid idcode, masterid(nlswork_ID_old) sample(25) time(year) save(nlswork_ID)}{p_end}

{title:Remarks}

{pstd}
Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!