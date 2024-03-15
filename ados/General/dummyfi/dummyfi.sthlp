{smcl}
{* *! version 0.1 20Sep2023}{...}{smcl}
{.-}
help for {cmd:dummyfi} {right:}
{.-}

{title:Title}

{pstd}
{cmd:dummyfi} {hline 1} creates random data from metadata information and sampled ids.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:dummyfi} {help varlist:varlist}
{cmd:} [, {it:options}],

where {help varlist:varlist} is a (list of) variable(s) that serves as the dataset identifier.

{synoptset 35 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt meta:file(filename)}} is the Excel file where the metadata is 
stored. The user should not provide the file extension. This option is mandatory.
{p_end}
{synopt :{opt masterid(filename)}} is the file with sampled ids and 
time variable (if applicable).
{p_end}
{synopt :{opt do:file(filename)}} saves the commands that are used to 
generate the dummy data to {it:filename}. Defaults to {opt code_dummy}.
{p_end}
{synopt :{opt time:var(varname)}} is the time variable. 
{p_end}
{synopt :{opt seed(#)}} specifies the initial value of the random-number seed used in {opt dofile}.
{p_end}
{synopt :{opt name:dummy(str)}} is the name of the random dataset to be created by the resulting do-file. Defaults to {it:dummy_data}.
{p_end}
{synopt :{opt inv:thresh(num)}} is the threshold for time invariant observations. If the share of 
time invariants for a particular variable in the metadata file is greater than {it:num}, 
then the output do-file will make the variable time invariant. {it:num} is between 0 and 1 and 
defaults to 0.99.
{p_end}
{synopt :{opt zero:thresh(num)}} is the threshold for values equal to zero. If the share of 
zeros for a specific variable in the metadata file is greater than {it:num}, that share will be 
replaced by zero in the output file. {it:num} is between 0 and 1 and 
defaults to 0.8.
{p_end}
{synopt :{opt miss:thresh(num)}} is the threshold for missing values. If the share of 
missing values for a specific variable in the metadata file is greater than {it:num}, that share 
will be replaced by missing in the output file. {it:num} is between 0 and 1 and 
defaults to 0.8.
{p_end}
{synopt :{opt replace}} replaces file {opt dofile} if 
it exists.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt dummyfi} creates a do-file that generates random data using a metadata file 
(see {browse "https://github.com/BPLIM/Tools/tree/master/ados/General/mdata":mdata}) and a file 
with sampled ids provided by the user. 

{pstd}
The first step to generate the random data is to create a metadata file 
using command {opt mdata stats}. The metadata file contains basic 
information about the structure of the data and variables' info and 
statistics that is used to generate the random dataset. The next step is to 
sample the ids (units) using {help sampleid}. The units may be a single 
variable or a combination of variables. Both the metadata and ids files 
are used by this command to create the do-file and then generate the dummy 
data.

{pstd}
The command skips string variables and will not include them in the random dataset.


{title:Examples}

{pstd}
Example 1: Create do-file to generate random data from the {it:nlswork} dataset based on a 10% sample. 

{p 8 16}{inp:. webuse nlswork, clear}{p_end}
{p 8 16}{inp:. mdata stats, save(meta, replace) panel(idcode) time(year)}{p_end}
{p 8 16}{inp:. sampleid idcode, sample(10) time(year) save(nlswork_ID) replace}{p_end}
{p 8 16}{inp:. dummyfi idcode, meta(meta) masterid(nlswork_ID) time(year) do(gen_dummy) name(nlswork_dummy) replace}{p_end}

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