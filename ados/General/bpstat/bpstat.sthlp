{smcl}
{* *! version 0.3  03Nov2020}{...}{smcl}
{.-}
help for {cmd:bpstat} {right:()}
{.-}

{title:Title}


bpstat {hline 1} imports statistical series from Banco de Portugal {browse "https://bpstat.bportugal.pt/": BPstat}'s database



{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:bpstat} {it:subcommand}
[{cmd:,} {it:options}]


{marker description}{...}
{title:Description of bpstat}

{pstd}
{cmd:bpstat} allows users to import over 270,000 statistical series from Banco de Portugal BPstat's database. The command uses Python to interface with 
BPstat's API and download series from several data domains (e.g. National Financial Accounts, Balance of Payments, Interest rates, etc.) with 
different frequencies. Users are only allowed to import series from the same domain and frequency. Variables are named as DxxxF#########, where: 

	 - xxx is a three digit number identifying the data domain
	 - F indicates the frequency of the series (A=Annual, B=Biannual, Q=Quarterly, M=Monthly and D=Daily); 
	 - ######## is the unique BPstat numerical code of the series. 
	 
{pstd}
Take as an example the variable named D009M12468894. It belongs to data domain 9 (Cash issuance), has a monthly frequency (M), 
and the BPstat numerical code 12468894. 

{pstd}
This command uses the ancillary file BPSTAT_INFO.zip which contains the BPSTAT_INFO.csv file. The user may extract this latter file to access 
additional information, but should, under no circumstance, delete the zip file.  

{pstd}
{cmd:bpstat} requires a connection to the internet and imports data to a new {help frame}. For a more in-depth look at BPstat's API, please follow this {browse "https://bpstat.bportugal.pt/data/docs":link}.


{synoptset 33}{...}
{marker subcommands}{...}
{synopthdr :subcommands}
{synoptline}
{synopt :{opt use}}the command line version to import BPstat data{p_end}
{synopt :{opt dlg}}the menu-driven approach that launches a dialog box for the user to import BPstat data{p_end}
{synopt :{opt search}}search series based on keywords specified by the user{p_end}
{synopt :{opt describe}}prints the series metadata{p_end}
{synopt :{opt browse}}opens a tab in the default browser with the series web page{p_end}
{synoptline}

{p2colreset}{...}


{marker description_use}{...}
{title:Description of bpstat use}

{pstd}
{cmd:bpstat use} is the command-line version to import BPstat's series.


{marker option_use}{...}
    {title:Options for bpstat use}

{phang}
{opt vars(series)} list of series. This option is mandatory.

{phang}
{opt frame(name)} name of the frame to which the data is imported. If this option is not specified, the default name for the frame is "BPstatFrame".

{phang}
{opt en} sets English as the language for series labels. Default is Portuguese.

{phang}
{opt replace} replaces the frame in memory.



{marker description_dlg}{...}
{title:Description of bpstat dlg}

{pstd}
{cmd:bpstat dlg} is the menu-driven approach. It launches a dialog box to help users import series from Banco de Portugal BPstat's databases.


{marker option_dlg}{...}
    {title:Options for bpstat dlg}

{phang}
{opt frame(name)} name of the frame to which the data is imported. If this option is not specified, the default name for the frame is "BPstatFrame".

{phang}
{opt replace} replaces the frame in memory.



{marker description_search}{...}
{title:Description of bpstat search}

{pstd}
{cmd:bpstat search} is a tool to help find series of interest based on keywords provided by the user. The command searches for keywords in the
series' description. The search is not case sensitive. Since the list of series matched might be long, a data set with the 
series names and description is imported to a new
frame called "SearchFrame". At this point it is useful to note that the same can be achieved by using {cmd:bpstat dlg}. The only difference is that 
by using {cmd:bpstat dlg}, the search is constrained to one domain, while {cmd:bpstat search} uses the whole database.


{marker option_search}{...}
    {title:Options for bpstat search}

{phang}
{opt kw(word1 word2 ...)} is the list of keywords provided by the user. By default, the command returns every series whose description 
contains at least one of the keywords.

{phang}
{opt full:match} changes the search default behaviour. Only series whose description contains the whole string between parenthesis are returned.

{phang}
{opt int:ersection} also changes the search default behaviour. By specifying this option, the command returns series whose description 
contains every word in the list of keywords.

{phang}
{opt en} sets English as the language for series description. Default is Portuguese.



{marker description_describe}{...}
{title:Description of bpstat describe}

{pstd}
{cmd:bpstat describe} describes the series in BPstat's database. This command prints the series metadata.


{marker option_describe}{...}
    {title:Options for bpstat describe}

{phang}
{opt vars(series)} is the list of series. This option is mandatory.

{phang}
{opt en} sets English as the language for series metadata. Default is Portuguese.



{marker description_browse}{...}
{title:Description of bpstat browse}

{pstd}
{cmd:bpstat browse} browses the specified series' web pages.


{marker option_browse}{...}
    {title:Options for bpstat browse}

{phang}
{opt vars(series)} is the list of series. This option is mandatory.



{title:Examples}


Example 1:
Search series whose description contains the words "investment" or "international".

{p 8 16}{inp:. bpstat search, kw(investment international) en}{p_end}


Example 2:
Search series whose description contains the string "international investment".

{p 8 16}{inp:. bpstat search, kw(international investment) full en}{p_end}


Example 3:
Search series whose description contains the words "international" and "investment".

{p 8 16}{inp:. bpstat search, kw(international investment) int en}{p_end}


Example 4:
Describe the two first series returned by the previous command.

{p 8 16}{inp:. bpstat describe, vars(D004Q12473806 D004Q12476170) en}{p_end}


Example 5:
Browse the web page of the series above.

{p 8 16}{inp:. bpstat browse, vars(D004Q12473806 D004Q12476170)}{p_end}


Example 6:
Import series D004Q12473806 D004Q12476170 into frame BPdata. Labels are set to English.

{p 8 16}{inp:. bpstat use, vars(D004Q12473806 D004Q12476170) frame(BPdata) en}{p_end}


Example 7:
Launch BPstat dialog box

{p 8 16}{inp:. bpstat dlg}{p_end}


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
- ttkthemes

For help on the intallation of the required packages in Python, please check the {browse "https://github.com/BPLIM/Tools/tree/master/ados/General/bpstat": Github repository} for the ado.


{title:Author}

{p}
BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
