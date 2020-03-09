{smcl}
{* *! version 1.0  10sep2019}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "checkinvariant##syntax"}{...}
{viewerjumpto "Description" "checkinvariant##description"}{...}
{viewerjumpto "Examples" "checkinvariant##examples"}{...}
{viewerjumpto "Author" "checkinvariant##author"}{...}
{viewerjumpto "Website" "checkinvariant##website"}{...}
{title:Title}

{phang}
{bf:checkinvariant} {hline 2} Check if a variable is invariant within a group

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{opt checkinvariant} [{it:varlist} , by({it:varlist}) {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt allowmiss:ing}}Consider as invariant the case where a variable has missing values and a unique non-missing value within each group{p_end}
{synopt:{opt fill}}Replaces missing values with the unique non-missing value within each group. Requires {opt allowmiss:ing}{p_end}
{synopt:{opt dropinvar:iant}}Drops the invariant variables (including the filled ones when fill is called){p_end}
{synopt:{opt dropvar:iant}}Drops the variant variables{p_end}
{synopt:{opt keepinvar:iant}}Keeps the invariant variables (including the filled ones when filled is called) and the {it:by} variables{p_end}
{synopt:{opt keepvar:iant}}Keeps the variant variables and the {it:by} variables{p_end}
{synopt:{opt verb:ose}}Print results as each variable is checked{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}This command checks whether a given variable is constant or varies within the unique values of another group of variables. It is useful to ensure that panel datasets are coherent (e.g. attributes that should be constant within unit or time period indeed are).

{pstd}The command also returns scalars and macros with the number and lists of variant and invariant variables that can be used in subsequent commands.

{pstd}The only dependency of this command is gtools, by Mauricio Caceres, about which you can find at {browse "https://github.com/mcaceresb/stata-gtools"}.

{pstd}In the repository where the {cmd:checkinvariant} is maintained, you can find a file with tests for the command that should verify that it is working properly. This can be particularly useful if you intend to make extensions to the command.

{marker examples}{...}
{title:Examples}

sysuse auto, clear
gen brand = make
replace brand = regexr(brand, " .*", "")
checkinvariant, by(brand)

{marker author}{...}
{title:Author}

{pstd}Luís Fonseca, London Business School.

{pstd}Website: {browse "https://luispfonseca.com"}

{marker website}{...}
{title:Website}

{pstd}{cmd:checkinvariant} is maintained at {browse "https://github.com/luispfonseca/stata-misc"}{p_end}
