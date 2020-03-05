
{smcl}
{.-}
help for {cmd:bpstatuse} {right:()}
{.-}

{title:Title}

bpstatuse - imports statistical series from Banco de Portugal BPstat's database

{title:Syntax}

{p 8 15}
{cmd:bpstatuse}, {it:vars(series list)} [{it:options}]

{p}

{title:Description}

{p}
{cmd:bpstatuse} allows users to import over 140,000 statistical series from Banco de Portugal BPstat's database. The command uses Python to interface with 
BPstat's API and download series from several data domains (e.g. National Financial Accounts, Balance of Payments, Interest rates, etc.) with 
different frequencies. Users are only allowed to import series from the same domain and frequency. Variables are named as DxxxF#########, where: 

	 - xxx is a three digit number identifying the data domain
	 - F indicates the frequency of the series (A=Annual, B=Biannual, Q=Quarterly, M=Monthly and D=Daily); 
	 - ######## is the unique BPstat numerical code of the series. 

Take as an example the variable named D009M12468894. It belongs to data domain 9 (Cash issuance), has a monthly frequency, and the BPstat numerical code 12468894. 
This command uses the ancillary file BPSTAT_INFO.zip which contains the BPSTAT_INFO.csv file. The user may extract this latter file to access additional information, but should, under no circumstance, delete the zip file. 
Additional information about the statistical series may be obtained by launching {help bpstatdlg} or directly from {browse "https://bpstat.bportugal.pt/": BPstat webpage}
{cmd:bpstatuse} requires a connection to the internet and imports to a new {help frame}.  


{title:Options}

{p 0 4}{opt vars()} list of series. 

{p 0 4}{opt frame(name)} name of the frame to which the data is imported. If this option is not specified, the default name for the frame is "BPstatFrame".

{p 0 4}{opt en} sets English as the language for series labels. Default is Portuguese.

{p 0 4}{opt replace} replaces the frame in memory.


{title:Examples}

Example 1:
Import series D009M12468894.

{p 8 16}{inp:. bpstatuse, vars(D009M12468894)}{p_end}


Example 2:
Import series D009M12468894 into frame BPdata. Labels are set to English.

{p 8 16}{inp:. bpstatuse, vars(D009M12468894) frame(BPdata) en}{p_end}


Example 3:
Import series D009A12469115, D009A12469040, and D009A12469012 into frame BPdata, replacing the one in memory.

{p 8 16}{inp:. bpstatuse, vars(D009A12469115 D009A12469040 D009A12469012) frame(BPdata) replace}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Dependencies}

This command will only work in Stata version 16, as it requires Python integration. Third party packages required in Pyhton (version3.5+):

- requests
- pandas

For help on the intallation of the required packages in Python, please check the {browse "https://github.com/BPLIM/Tools/tree/master/ados/General/bpstatuse": Github repository} for the ado.


{title:Author}

{p}
BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
