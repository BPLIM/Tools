
{smcl}
{.-}
help for {cmd:ireepanel} {right:()}
{.-}

{title:Title}

ireepanel - Creates a panel data set of the Fast and Exceptional Enterprise Survey - COVID-19 (COVID-IREE) using the data files for each survey's edition made available by BPLIM.

{title:Syntax}

{p 8 15}
{cmd:ireepanel}, [{it:options}]

{p}

{title:Description}

{p}
This command constructs a panel data set of the Fast and Exceptional Enterprise Survey - COVID-19 (COVID-IREE) by appending the data files for each survey's edition made available by BPLIM.
{cmd:ireepanel} recodes the missing values of the questions that were not included in a given edition of the survey to ".a" and applies labels and value labels.
The user should however take into account that the data comparability is affected by the change in the reference period (from a week to a fortnight) from Edition 19 onwards and by the reformulation of some questions over time. For more details please refer to the data manual.
The ado has the option {opt type} that allows to arrange the panel data in the long or wide format and the option {opt save} to save the panel data set in a separate data file.

The command only works with the anonymized data sets of the Fast and Exceptional Enterprise Survey - COVID-19 made available by BPLIM.


{title:Options}

{p 0 4}{opt edition(numlist)} allows to specify the editions of the survey to be included in the panel data set (eg. 152020 and 162020). At least two editions must be specified. The default option is {it:all} and considers all the editions of the survey (editions 152020 to 232020).

{p 0 4}{opt mpath()} this option should be used to specify the path where the data files of each survey's edition are stored. The default path is the current working directory.

{p 0 4}{opt type()} should be used to specify the format of the panel data. It may be either long or wide. {it:long} is the default option and organizes the data such that each observation corresponds to a firm in a given edition of the survey.
The option {it:wide} will construct the panel with one row for each firm and each variable in the data will be indexed by the survey's edition. The option {it:wide} relies on {cmd:gtools} for a faster implementation.

{p 0 4}{opt save(filename)} saves the panel data in a data set named {it:filename} in the path defined by the user or in the current working directory in case the path is not specified.


{title:Examples}

Example 1:
Assembles the panel data set in the long format using all editions available from a specific folder:

{p 8 16}{inp:. ireepanel, mpath(/bplimext/projects/p000_JDOE/initial_dataset/)}{p_end}

Example2:
Assembles and saves the panel data set in the long format using all editions available and reading and writing to specific folders:

{p 8 16}{inp:. ireepanel, mpath(/bplimext/projects/p000_JDOE/initial_dataset/) save(/bplimext/projects/p000_JDOE/work_area/IREE_1523_JUL20.dta)}{p_end}

Example3:
Creates the panel data set in the wide format using the data available for editions 15 to 18 and reads the data from the current folder:

{p 8 16}{inp:. ireepanel, edition(152020 162020 172020 182020) type(wide)}{p_end}


{title:Dependencies}

{cmd:descsave} (version 16.0 08 April 2020) by Roger Newson

{cmd:gtools} (version 1.5.1 24Mar2019) by Mauricio Bravo


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Author}

{p}
BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

I appreciate your feedback. Comments are welcome!
