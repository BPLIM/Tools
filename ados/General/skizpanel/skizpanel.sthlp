{smcl}
{* *! version 0.2 06Feb24}{...}{smcl}
{.-}
help for {cmd:skizpanel} {right:}
{.-}

{title:Title}

{pstd}
{cmd:skizpanel} {hline 1} reduces the size of a panel data set by collapsing repeated observations into a single line.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:skizpanel}
{cmd:} {it:panelvar} {it:timevar} [, {it:options}]

{marker description}{...}
{title:Description}

{pstd}
{opt skizpanel} is a Stata command that compares consecutive observations for individuals in a panel dataset. When the information recorded in the relevant variables is the same, the observations are condensed into a single observation and the 
variable {it:countvar} indicates the number of times this observation repeateds in the original dataset. This is a "skizzed" dataset.

{pstd}
The interpretation of the {it:countvar} depends on the temporal frequency of the data. For example, considering daily data, the {it:countvar} indicates the number of consecutive days in which the observation is repeated.

{marker options}{...}
{title:Options}

{synoptset 45 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{synopt:{ul:{opt var}}{opt iables}({it:varlist}[{bf:, keepvars}({it:first}|{it:last})])}determines the set of 
variables to take into account in the "skiz". By default, all the variables available in the dataset are considered. 
When the option {opt variables} is used the variables not included in the varlist are dropped. 
However, it is possible to keep all the variables in the data by specifying the {opt keepvars} suboption. 
If this suboption is specified, it is important to define if one wants to keep the first or last observation available for these variables. By default, {cmd: skizpanel} keeps the first observation.
{p_end}
{synopt:{opt nogaps}}ignores temporal gaps in the data. By default, the command considers temporal gaps, comparing only time-consecutive observations. When this option is specified, temporal gaps are ignored and the variable {bf:_nmiss} is created indicating how many observations are missing for each collapsed line.
{p_end}
{synopt:{opt ignorecase}}treates all string variables as lower case.
{p_end}
{synopt:{opt skizagain}}performs a new skiz of the data on a panel that was previously "skizzed".
{p_end}
{synopt:{opt append}({it:filename})}appends the file in disk {it:filename.dta} to the {it:dta} file in use. The file in memory must be already "skizzed".
{p_end}
{synopt:{opt countvar}({it:str})}specifies the name of the countvar created. By default, the name is {bf:_nrep}. 
{p_end}
{synopt:{opt report}}reports the differences found in each variable, in order to understand which are the main variables responsible for changing the data.
{p_end}
{synopt:{opt stats}}reports basic descriptive statistics of a previous "skizzed" panel.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker append_option}{...}
{title:Append and Skizagain options}

{pstd}
The {bf:append} option can be useful when the panels to be "skizzed" are of considerable size. For instance, in the case of daily data, you can "skiz" monthly panels and then combine them into a single "skizzed" annual panel using the {bf:append} option. 

{pstd}
The {bf:skizagain} option may be useful if changes are made to a previously "skizzed" panel and we need to "skiz" again.

{pstd}
Both of these options can only be used in previously "skizzed" panels.

{marker examples}{...}
{title:Examples}

{ul:Example 1:} 

{input:    id      date           name           brand}
{hline 54}
{sf:    105     01/01/2021     rice 1kg       brand a}
{hline 54}
{sf:    105     02/01/2021     rice 1kg       brand a}
{hline 54}
{sf:    105     03/01/2021     rice 1kg       brand ab}
{hline 54}
{sf:    105     04/01/2021     rice a 1kg     brand ab}
{hline 54}

{pstd}
Squiz a panel identifying changes over time in all the variables.

{p 8 16}{inp:. skizpanel id date}{p_end}   
{tab}{input:    id      date           name           brand        _nrep}
{tab}{hline 61}
{tab}{sf:    105     01/01/2021     rice 1kg       brand a      2}
{tab}{hline 61}
{tab}{sf:    105     03/01/2021     rice 1kg       brand ab     1}
{tab}{hline 61}
{tab}{sf:    105     04/01/2021     rice a 1kg     brand ab     1}
{tab}{hline 61}

{pstd}
Squiz a panel considering only changes in the variable name.

{p 8 16}{inp:. skizpanel id date, var(name)}{p_end} 
{tab}{input:    id      date           name           _nrep}
{tab}{hline 48}
{tab}{sf:    105     01/01/2021     rice 1kg       3}
{tab}{hline 48}
{tab}{sf:    105     04/01/2021     rice a 1kg     1}
{tab}{hline 48}

{pstd}
Squiz a panel considering only changes in the variable name, but keeping the first observation for the other variables.

{p 8 16}{inp:. skizpanel id date, var(name, keepvars(first))}{p_end} 
{tab}{input:    id      date           name           brand        _nrep}
{tab}{hline 61}
{tab}{sf:    105     01/01/2021     rice 1kg       brand a      3}
{tab}{hline 61}
{tab}{sf:    105     04/01/2021     rice a 1kg     brand ab     1}
{tab}{hline 61}

{pstd}
Squiz a panel considering only changes in the variable name, but keeping the last observation for the other variables.

{p 8 16}{inp:. skizpanel id date, var(name, keepvars(last)) countvar(count)}{p_end} 
{tab}{input:    id      date           name           brand         count}
{tab}{hline 62}
{tab}{sf:    105     01/01/2021     rice 1kg       brand ab      3}
{tab}{hline 62}
{tab}{sf:    105     04/01/2021     rice a 1kg     brand ab      1}
{tab}{hline 62}

{ul:Example 2:} 

{input:    id      date           name           brand}
{hline 54}
{sf:    105     01/01/2021     rice 1kg       brand a}
{hline 54}
{sf:    105     05/01/2021     rice 1kg       brand a}
{hline 54}
{sf:    105     06/01/2021     rice 1kg       brand a}
{hline 54}
{sf:    105     07/01/2021     rice a 1kg     brand a}
{hline 54}

{pstd}
Squiz a panel considering changes in all the variables and time gaps.

{p 8 16}{inp:. skizpanel id date}{p_end}   
{tab}{input:    id      date           name           brand        _nrep}
{tab}{hline 61}
{tab}{sf:    105     01/01/2021     rice 1kg       brand a      1}
{tab}{hline 61}
{tab}{sf:    105     05/01/2021     rice 1kg       brand a      2}
{tab}{hline 61}
{tab}{sf:    105     07/01/2021     rice a 1kg     brand a      1}
{tab}{hline 61}

{pstd}
Skiz a panel considering changes in all the variables, but not time gaps.

{p 8 16}{inp:. skizpanel id date, nogaps}{p_end}   
{tab}{input:    id      date           name           brand        _nrep     _miss}
{tab}{hline 71}
{tab}{sf:    105     01/01/2021     rice 1kg       brand a      3         3}
{tab}{hline 71}
{tab}{sf:    105     07/01/2021     rice a 1kg     brand a      1         0}
{tab}{hline 71}

{ul:Example 3:} 

{it:jan2021.dta}

{input:    id      date           name           brand        _nrep}
{hline 61}
{sf:    105     28/01/2021     rice 1kg       brand a      3}
{hline 61}
{sf:    105     31/01/2021     rice a 1kg     brand a      1}
{hline 61}

{it:feb2021.dta}

{input:    id      date           name           brand        _nrep}
{hline 61}
{sf:    105     01/02/2021     rice a 1kg     brand a      5}
{hline 61}
{sf:    105     06/01/2021     rice a 1kg     brand ab     6}
{hline 61}

{pstd}
Combine two previously skiz panels into a single panel, considering changes in all the variables.

{p 8 16}{inp:. use "jan2021.dta", clear}{p_end} 
{p 8 16}{inp:. skizpanel id date, append("feb2021.dta")}{p_end}   
{tab}{input:    id      date           name           brand        _nrep}
{tab}{hline 61}
{tab}{sf:    105     28/01/2021     rice 1kg       brand a      3}
{tab}{hline 61}
{tab}{sf:    105     31/01/2021     rice a 1kg     brand a      6}
{tab}{hline 61}
{tab}{sf:    105     06/02/2021     rice a 1kg     brand ab     6}
{tab}{hline 61}

{marker remarks}{...}
{title:Remarks}

{pstd}
Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.

{marker dependencies}{...}
{title:Dependencies}

{pstd}
{cmd:egenmore} package by Nicholas J. Cox{p_end}

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!