
{smcl}
{.-}
help for {cmd:panelstat} {right:()}
{.-}

{title:Title}

panelstat - Provides a detailed characterization of a panel data set.

{title:Syntax}

{p 8 15}
{cmd:panelstat} {it:panelvar} {it:timevar} [{help if}] [{help in}], [{it:options}]

{p}

{title:Description}

{p}
This command analyzes a panel data set and offers many options to provide a full characterization of the panel structure.
The command is implemented for a typical panel and requires both a panel variable and a time variable.

{title:Options}

General Options

{p 0 4}{opt cont} time variable ignores a time gap common to all panel units in that period. For example, if you have yearly data
from 2000 to 2010 but no observation recorded in 2005, it would ignore the year of 2005 in all calculations

{p 0 4} {opt force1} if the panel has repeated values of {it:timevar} per panel unit it forces the command to run by keeping only one observation per {it:panelvar} X {it:timevar} pair

{p 0 4} {opt force2} similar to {cmd:FORCE1} but ignores all observations with repeated values of {it:timevar} for the same unit identifier

{p 0 4} {opt force3} ignores all observations for an unit identifier that has repeated values of {it:timevar}

{p 0 4} {opt forcestata} by default {it:panelstat} relies on {cmd:gtools}) for faster calculations. This option forces the use of Stata official ados instead

Basic Descriptives

{p 0 4}{opt gaps} characterizes the (temporal) gap structure of the data set

{p 0 4}{opt runs} provides information about complete "runs" on the data, where a "run" is a sequence of consecutive values for the same panel unit

{p 0 4}{opt pattern} shows the most common patterns of the data set

{p 0 4}{opt demog} characterizes the flows of panelvar units that occur between two consecutive time periods: entrants, exiters, incumbents.

{p 0 4}{opt vars} produces a table for all variables in the dataset with information along the panel unit dimension.

{p 0 4}{opt nosum} does not report summary statistics for the panel

{p 0 4}{opt all} selects the five options {cmd: gaps}, {cmd: runs}, {cmd: pattern}, {cmd: demo}, and {cmd: vars}

Advanced Descriptives

{p 0 4} {opt tabovert}({it:varlist}) creates a tabulation of the variables in {it:varlist} along the time dimension. It is meant for use with categorical variables

{p 0 4} {opt statovert}({it:varlist}[, {opt d:etail}]) creates descriptive statistics of the variables in {it:varlist} along the time dimension

{p 4 8} {opt d:etail} provides additional descriptive statistics

{p 0 4} {opt wiv} ({it:varlist}[, {opt k:eep}]) provides statistics for {it:varlist} along the {it:panelvar} dimension. With the option {opt keep} it creates panel unit level variables with stub {it:_wiv_var}

{p 0 4} {opt wtv}({it:varlist}[, {opt k:eep}]) provides statistics for {it:varlist} along the {it:timevar} dimension.  With the option {opt keep} it creates time level variables with stub {it:_wtv_var}

{p 0 4} {opt abs}({it:varlist}[, {opt k:eep} {opt d:if} {opt l:ags}({it:integer}) {opt v:al}({it:integer})]) reports on absolute changes over time for each variable in {it:varlist}

{p 4 8} {opt k:eep} creates variables of type {it:_abs_x_var} indicating the type of change

{p 4 8} {opt d:if} uses first differences instead of levels

{p 4 8} {opt l:ags}({it:integer}) specifies the number of lags to use (default is 1)

{p 4 8} {opt v:al}({it:integer}) sets the threshold value for reporting an abnormal absolute change (default is 10)

{p 0 4} {opt rel}({it:varlist}[, {opt k:eep} {opt den:lag} {opt l:ags}({it:integer}) {opt v:al}({it:integer})]) reports on relative changes over time for each variable in {it:varlist}. 
By default relative changes use in the denominator the average of starting and end point. The denominator is always in absolute value

{p 4 8} {opt k:eep} creates variables of type {it:_rel_x_var} indicating the type of change.

{p 4 8} {opt den:lag} uses only starting point in the denominator.

{p 4 8} {opt l:ags}({it:integer}) specifies the number of lags to use (default is 1)

{p 4 8} {opt v:al}({it:integer}) sets the threshold value for reporting an abnormal relative change (default is 100)

{p 0 4} {opt quantr}({it:varlist}[, {opt k:eep} {opt r:el} {opt l:ow}({it:integer}) {opt u:pper}({it:integer})]) computes year to year changes for quantiles of {it:varlist}. With the option {opt k:eep} it creates variables of type {it:_quantr_var} indicating the type of change.
With the option {opt r:el} it presents the table as row standardized. It is meant for use with continuous variables

{p 4 8} {opt k:eep} creates variables of type {it:_quantr_var} indicating the type of change.

{p 4 8} {opt r:el} reports changes in relative terms.

{p 4 8} {opt m:issing} includes informations about changes to and from missing values.

{p 4 8} {opt l:ow}({it:integer}) sets the threshold value to define quartile 1 (default is 25)

{p 4 8} {opt u:pper}({it:integer}) sets the threshold value to define quartile 4  (default is 75)

{p 0 4} {opt flows}({it:varlist}[, {opt unit}]) decomposes the change in the stock of each variable between two periods into the sum of its flows: increase, decrease, for incumbent, entering and exiting panelvar units

{p 4 8} {opt u:nit} reports an additional table with the number of valid (nonmissing) observations used to compute the flows.

{p 0 4} {opt fromto}({it:var}, {opt f:rom}({it:integer}) [{opt t:o}({it:integer}) {opt s:ave} {opt m:issing} {opt k:eep} {opt a:scend} {opt d:escend}]) produces a table with the number of panel units that have the same movement across categories of {it:varlist} from
time period defined by {opt f:rom}({it:integer}) to the following period. Arguments of {opt f:rom}({it:integer}) and {opt t:o}({it:integer}) must be valid values of {it:timevar}. It is meant for use with categorical variables

{p 4 8} {opt k:eep} creates variables of type {it:_ft_var} flagging the different types of events.

{p 4 8} {opt t:o}({it:integer}) the period to which the change is calculated. If not specified it uses the period immediately after {opt f:rom}({it:integer})

{p 4 8} {opt s:ave} saves a Stata file with the table

{p 4 8} {opt m:issing} adds missing values to the table

{p 4 8} {opt a:scend} sorts the table from lowest to highest frequency

{p 4 8} {opt d:escend} sorts the table from highest to lowest frequency

{p 0 4} {opt return}({it:var}, {opt f:rom}({it:integer})} [{opt t:o}({it:integer}) {opt m:iddle}({it:integer}) {opt w:ithin}({it:integer}) {opt s:ave} {opt k:eep}]) produces a table with the number of panel units that change values of {it:var} and then come back to the original value. Given three distinct time periods, {it:a},{it:b}, and {it:c} the command reports on all panel units that had the same value of {it:var} at time period {it:a} and {it:c} but a different value at point {it:b}. Arguments of {opt f:rom({it:integer}), {opt m:iddle({it:integer}) and {opt t:o({it:integer}) must be valid values of {it:timevar}.

{p 4 8} {opt m:iddle(it:integer)} if not specified it uses the period immediately after {opt f:rom}({it:integer})

{p 4 8} {opt t:o({it:integer}) if not specified it uses the period immediately after {opt m:iddle}({it:integer})

{p 4 8} {opt s:ave} saves a Stata file with the table

{p 4 8} {opt k:eep} creates a variable ({it:_flag_var}) indicating all observations considered for the table

{p 4 8} {opt w:ithin}({it:integer}) value in percentage (default is 0). If selected than it checks if the value of {it:var} at point {it:c} is within the range [a-within*a,a+within*a] and the value of var at {it:b} is outside the range.

{p 4 8} {opt a:scend} sorts the table from lowest to highest frequency

{p 4 8} {opt d:escend} sorts the table from highest to lowest frequency

{p 0 4} {opt trans}({it:varlist}[, {opt k:eep}]) calculates the share of panel units that have the same movement across categories of {it:varlist} from t-1 to t. It is meant for use with categorical variables

{p 4 8} {opt k:eep} creates variables of type {it:_quantr_var} indicating the type of change.

{p 4 8} {opt m:issing} includes missing values in the analysis, that is, considers transitions from missing to valid values of var.

{p 4 8} {opt l:ow}({it:integer}) sets the threshold value to define the lower class (default is 5)

{p 4 8} {opt u:pper}({it:integer}) sets the threshold value to define the upper class  (default is 95)

{p 0 4} {opt checkid}({it:var}[, {opt k:eep}]) compares the variable with {it:panelvar} to check whether variable can be used as an alternative {it:panelvar}. 

{p 4 8} {opt k:eep} creates variable of type {it:_check_var} indicating the type of change. 

{p 0 4} {opt demoby}({it:var}[, {opt k:eep} {opt m:issing}]) calculates changes over time across {it:var}. It can be used to check movements of panel units across units of {it:var}.

{p 4 8} {opt k:eep} creates the variable _demoby_var identifitying for each observation whether it is the first time it shows up in the data (first), if it moves across the units of {it:var} (mover), if it remains in the same units of {it:var} (stayer) or if it returns to a previous unit of {it:var}.

{p 4 8} {opt m:issing} reports information for missing values

Changing Parameters

{p 0 4}{opt setmaxpat}({it:integer}) specifies the number of patterns to display. Affects the behavior of option {opt pattern}. Default is 10

{p 0 4}{opt settransl}({it:integer}) used with option {opt trans}. Specifies the lower threshold used in the table. Default is 5

{p 0 4}{opt settransu}({it:integer}) used with option {opt trans}. Specifies the upper threshold used in the table. Default is 95


Miscellaneous

{p 0 4}{opt excel}({it:filename}[, {opt replace} {opt modify}]}) outputs results to an excel file

{p 4 8} {opt replace} replaces existing excel file

{p 4 8} {opt modify} modifies an existing excel file

{p 0 4} {opt keepm:axgap}({it:new varname}) create a variable containing the largest gap size for each panel unit

{p 0 4} {opt keepn:gaps}({it:new varname}) creates a variable containing the number of gaps for each panel unit

{title:Examples}

Example 1:
Basic characterization of a panel.

{p 8 16}{inp:. panelstat id time}{p_end}

Example2:
Full characterization of a panel.

{p 8 16}{inp:. panelstat id time, all}{p_end}

Example3:

{p 8 16}{inp:. webuse nlswork}{p_end}
{p 8 16}{inp:. panelstat idcode year, nosum tabovert(union)}{p_end}
{p 8 16}{inp:. panelstat idcode year, fromto(south, from(82) keep missing)}{p_end}

{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.

{title:Dependencies}

option {opt checkid} requires installation of package {cmd:group2hdfe} (version 1.01 03jul2014) by Paulo Guimaraes
if available the code takes advantage of the excellent {cmd:gtools} package by Mauricio Bravo

{title:Author}

{p}
Paulo Guimaraes, BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:pguimaraes2001@gmail.com":pguimaraes2001@gmail.com}

I appreciate your feedback. Comments are welcome!
