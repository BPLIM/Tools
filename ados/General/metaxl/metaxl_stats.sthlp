{smcl}
{* *! version 0.1 21May2024}{...}{smcl}
{.-}
help for {cmd:metaxl stats} {right:}
{.-}

{title:Title}

{pstd}
{cmd:metaxl stats} {hline 1} extract statistics to metadata files

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:metaxl stats}
{cmd:} [, {it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt meta:file(filename)}} is an existing metadata file. If option {opt save} 
is not set, statistics and frequencies are added to this file. The user should not 
provide the file extension (.xlsx).
{p_end}
{synopt :{opt exc:ludevars(varlist)}} sets the variables for which 
the statistics will not be exported.
{p_end}
{synopt :{opt nof:req(varlist)}} sets the categorical variables 
(those that have a value label) for which the frequencies will 
not be exported. Set this option to {it:_all} in case you 
do not want to export frequencies.
{p_end}
{synopt :{opt time:var(varname)}} provides a time variable to 
compute additional statistics, namely the minimum and maximum 
dates for each variable.
{p_end}
{synopt :{opt panel:vars(varlist)}} computes the percentage of time invariant 
observations for each variable within unique values of 
{it:varlist}. The user must provide a time variable (option 
{opt timevar}).
{p_end}
{synopt :{opt save(filename [, replace])}} saves metadata, statistics and 
frequencies to {it:filename}. If option {opt metafile} is not set, 
the command will first extract the metadata (see {help metaxl_extract:metaxl extract}) 
to {it:filename} and then export the 
statistics and frequencies. Otherwise, it copies the 
contents of {opt metafile} to {it:filename}, 
exporting the statistics afterwards. The user should 
not provide the file extension.  
Sub-option {opt replace} overwrites the file if it exists. 
This option is mandatory if the user does not provide an 
existing metadata file (option {opt metafile}).
{p_end}
{synopt :{opt stats(statistics)}} specifies which statistics are 
to be exported. Possible statistics are the ones returned 
as scalars by command {help summarize}. By default, the command 
exports the mean ({it:mean}), the standard deviation ({it:sd}), the median 
({it:p50}) and percentiles 5 and 95 ({it:p5} and {it:p95}). Set this 
option to {it:_all} to export all possible statistics. 
{p_end}
{synopt :{opt weight(varname)}} sets a weighting variable to calculate the 
statistics (see {help weight}).
{p_end}
{synopt :{opt miss:detail}} reports information about extended 
missing values (see {help missing:missing}).
{p_end}
{synopt :{opt replace:stats}} replaces statistics and frequencies 
on the metadata file in case they exist.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt metaxl stats} is a Stata command that computes variables' 
statistics/frequencies and exports them to an Excel file. It is part 
of the {help metaxl} package.

{pstd}
The user may use an existing metadata file created with 
{help metaxl_extract:metaxl extract} (see option {opt metafile}) 
and add the statistics computed from data in memory. It is also 
possible to create a new file with metadata and statistics. In this case, 
{opt metaxl stats} calls {help metaxl_extract:metaxl extract} to save the 
metadata and then adds the statistics.

{pstd}
The command skips string variables and computes the statistics for 
numeric variables. The statistics reported (which may be modified) are 
limited to the ones returned as scalars by command {help summarize}. The 
share of zeros, negatives and missings are also included. If the user 
specifies a time variable (see option {opt timevar}), the command computes 
the minimum and maximum date for each variable. It will also compute the share 
of time invariant observations for each variable if the user specifies panel variables 
(option {opt panelvars}).

{pstd}
For categorical variables (those that have a value label), an additional column named 
freq_{it:var} is created in the value label worksheet. The column displays the relative 
frequency for each possible level of the variable. Note that one value label may be 
applied to many variables, so the number of additional columns might be greater than one. 


{title:Examples}

{pstd}
Create metadata file with default statistics (mean sd p5 p50 p95) and save it to "meta_auto.xlsx".

{p 8 16}{inp:. sysuse auto, clear}{p_end}
{p 8 16}{inp:. metaxl stats, save(meta_auto)}{p_end}

{pstd}
Change metadata file "meta_auto.xlsx" by adding all possible statistics.  

{p 8 16}{inp:. sysuse auto, clear}{p_end}
{p 8 16}{inp:. metaxl extract, meta(meta_auto)}{p_end}
{p 8 16}{inp:. metaxl stats, meta(meta_auto) stats(_all)}{p_end}

{pstd}
Create metadata file "meta_nls.xlsx" with default and time statistics (min and max date and 
time invariant share).

{p 8 16}{inp:. webuse nlswork, clear}{p_end}
{p 8 16}{inp:. metaxl stats, save(meta_nls) time(year) panel(idcode)}{p_end}

{pstd}
Create metadata file "meta_nls.xlsx" with default and time statistics, 
except for variables idcode and year. Also, do not report levels' shares for variable 
race. 

{p 8 16}{inp:. webuse nlswork, clear}{p_end}
{p 8 16}{inp:. metaxl stats, save(meta_nls) time(year) panel(idcode) exc(idcode year) nof(race)}{p_end}

{title:Remarks}

{pstd}
Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Dependencies}

{pstd}
{cmd:gtools} package by Mauricio Bravo{p_end}


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!

