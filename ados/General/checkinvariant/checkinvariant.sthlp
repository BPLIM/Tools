{smcl}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "checkinvariant##syntax"}{...}
{viewerjumpto "Description" "checkinvariant##description"}{...}
{title:Title}

{phang}
{bf:checkinvariant} {hline 2} Check if a variable is invariant within a group

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{opt checkinvariant} {it:varlist} , by({it:varlist}) [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt allowmiss:ing}}Consider as invariant the case where a variable has missing values and a unique non-missing value within each group{p_end}
{synopt:{opt fill}}For the case in allowmissing, replace the missing values with the unique non-missing value within each group{p_end}
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

{pstd}The only dependency of this command is gtools, by Mauricio Caceres, about which you can find at {browse "https://github.com/mcaceresb/stata-gtools"}.

{title:Author}

{pstd}Luís Fonseca, London Business School.

{pstd}Website: {browse "https://luispfonseca.com"}

{title:Website}

{pstd}{cmd:checkinvariant} is maintained at {browse "https://github.com/luispfonseca/stata-misc"}{p_end}
