
{smcl}
{.-}
help for {cmd:bpstatdlg} {right:()}
{.-}

{title:Title}

bpstatdlg - imports statistical series from Banco de Portugal BPstat's database using a dialog box

{title:Syntax}

{p 8 15}
{cmd:bpstatdlg}, [{it:options}]

{p}

{title:Description}

{p}
{cmd:bpstatdlg} launches a dialog box that allows users to import over 140,000 statistical series from Banco de Portugal BPstat's databases. This command is a menu-driven option for {help bpstatuse}. 
Please refer to {help bpstatuse} for additional information.

{title:Options}

{p 0 4}{opt frame(name)} name of the frame to which the data is imported. If this option is not specified, the default name for the frame is "BPStatFrame".

{p 0 4}{opt replace} replaces the frame in memory.


{title:Examples}

Example 1:
Launch BPstat dialog box

{p 8 16}{inp:. bpstatdlg}{p_end}


Example 2:
Launch BPstat dialog box to import data into frame BPData.

{p 8 16}{inp:. bpstatdlg, frame(BPdata)}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Dependencies}

This command will only work in Stata version 16 as it requires Python integration. Third party packages required in Pyhton (version3.5+):

- requests
- pandas
- ttkthemes

For help on the installation of the required packages in Python, please check the {browse "https://github.com/BPLIM/Tools/tree/master/ados/General/bpstatuse": Github repository} for the ado.


{title:Author}

{p}
BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
