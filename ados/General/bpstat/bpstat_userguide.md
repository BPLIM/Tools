---
title: A user guide to `bpstat`
author: BPLIM
date: 2024/07/10
format:
  html:
    toc: true
    code-copy: true
    theme: default
    self-contained: true
jupyter: nbstata
---

# Introduction

`bpstat` is a [Stata](https://www.stata.com/) user-written package that allows users to import over 290,000 statistical series from Banco de Portugal [BPstat](https://bpstat.bportugal.pt/)'s database. 

The following subcommands are available with `bpstat`: 

- **use** is the command-line version to import BPstat's series
- **dlg** is the menu-driven approach that launches a dialog box for the user to import BPstat data
- **search** search series based on keywords specified by the user
- **describe** prints the series metadata
- **browse** opens a tab in the default browser with the series web page

The command uses Python to interface with BPstat's API and download series from several data domains (e.g. National Financial Accounts, Balance of Payments, Interest rates, etc.) with different frequencies. Users are only allowed to import series from the same domain and frequency. Variables are named as DxxxF#########, where:

- *xxx* is a three digit number identifying the data domain
- *F* indicates the frequency of the series (A=Annual, B=Biannual, Q=Quarterly, M=Monthly and D=Daily); 
- *########* is the unique BPstat numerical code of the series.

Take as an example the variable named D009M12468829. It belongs to data domain 9 (Cash issuance), has a monthly frequency (M), and the BPstat numerical code is 12468829.

This command uses the ancillary file *BPSTAT_INFO.zip* which contains the *BPSTAT_INFO.csv* file. The user may extract this latter file to access additional information, but should, under no circumstance, delete the zip file.

`bpstat` requires a connection to the internet and imports data to a new frame. For a more in-depth look at BPstat's API, please follow this [link](https://bpstat.bportugal.pt/data/docs).

## Installation

`bpstat` is not available in SSC. To install run the following in Stata:

```{stata}
net install bpstat, from("https://github.com/BPLIM/Tools/raw/master/ados/General/bpstat/")
```

**Dependencies:**

This package uses Python embedded code wich is available exclusively in Stata 16 and later versions. Furthermore, `bpstat` will only work with Python 3.6+

- **Third party packages required in Python:**
   - pandas
   - requests
   -  ttkthemes (only for the menu-driven approach)

- **Installation of the required packages:**
   - Using Python's pip installer (from the Terminal/Command Prompt):
     
          >pip install requests
          >pip install pandas
          >pip install ttkthemes

   - If you have the Anaconda distribution, you may also use the Anaconda Prompt, typing: [1]
     
           >conda install -c anaconda requests
           >conda install -c anaconda pandas
           >conda install -c gagphil1 ttkhemes
     [1] Note that the first two packages come pre-installed with Anaconda, so you probably will not need to use these two lines.


For help on the intallation of the required packages in Python, please check the [Github repository](https://github.com/BPLIM/Tools/tree/master/ados/General/bpstat)  for the ado.

## Syntax

bpstat subcommand [, options]

## `bpstat use`

`bpstat use` is the command-line version to import BPstat's series.

**Options for `bpstat use`:**

 - **vars**(*series*)  list of series. This option is mandatory.
 - **frame**(*name*) name of the frame to which the data is imported. If this option is not specified, the default name for the frame is "BPstatFrame".
 - **en** sets English as the language for series labels. Default is Portuguese.
 - **replace** replaces the frame in memory.
  
Here is an example syntax to import data using the command-line version:

```{stata}
 bpstat use, vars(D009M12468829) frame(BPstatFrame) en 
```

This command imports the statistical series identified by D009M12468829 from the BPstat database into Stata, storing it in a data frame called BPstatFrame, with variable label in English. This allows you to perform data analysis on this specific series within Stata.

Below are some examples of analysis that you can perform:

**Descriptive Statistics**

```{stata}
frame change BPstatFrame
summarize D009M12468829
```

**Time Series Plot**

Since `bpstat` automatically sets the dataset as time series using `tsset`, we can do the time series plot by running the following in Stata:

```{stata}
tsline D009M12468829
frame change BPstatFrame
```

<img width="566" alt="01_plot" src="https://github.com/BPLIM/Tools/assets/51088103/cdee96e4-190c-4905-8bb1-62757e91f652">

This data can be used for various statistical and econometric analysis, helping you to extract insights and make informed decisions based on the imported series.

##  `bpstat dlg`

 `bpstat dlg` is the menu-driven approach. It launches a dialog box to help users import series from Banco de Portugal BPstat's databases, allowing users to interact with the database in a more visual and user-friendly manner. 

**Options for `bpstat dlg`:**

- **frame**(*name*) name of the frame to which the data is imported. If this option is not specified, the default name for the frame is "BPstatFrame".
 - **replace** replaces the frame in memory.

To open the dialog box for importing BPstat data, you need to run the following in Stata:

```bpstat dlg, replace```

When you run this command, you need to choose whether you prefer the metadata in English or Portuguese and then click on continue


<img width="239" alt="02_menu_lang" src="https://github.com/BPLIM/Tools/assets/51088103/2665e877-0909-4723-8c07-6020b81e9b81">  

After choosing the language, you need to select the domain you wish to work with. You can search for data series using keywords, making it easier to find relevant data without needing to know the exact variable IDs.



<img width="573" alt="03_menu_domains" src="https://github.com/BPLIM/Tools/assets/51088103/c03b4236-3765-4fe4-825d-e07b26fb51d2">

Finally, you need to choose the variables you want to import. You can do this by clicking on the options or by typing the variable name in the search bar.


<img width="621" alt="04_menu_series" src="https://github.com/BPLIM/Tools/assets/51088103/a2a67cee-1034-4722-81f1-5d31a99f4326"> 

The BPstat DataLink GUI (Graphical User Interface) will show the details about each series, helping you to make informed decisions.

 Once you have made your selection and specified the options, the GUI will import the selected data into a Stata data frame. The respective command line (`bpstat use`) is automatically displayed in the output window.  You can then proceed to analyze the data.

 
 ```
 D009M12468829
Successful request
Series imported: 1 of 1

bpstat use, vars(D009M12468829) frame(BPstatFrame) en replace
 ```
  The `bpstat dlg` command is a powerful tool for users who prefer a graphical interface to interact with the BPstat database. It simplifies the process of finding, selecting, and importing data, making it accessible to a broader range of users and enhancing the overall user experience in Stata.

## `bpstat search`

`bpstat search` is a tool to help find series of interest based on keywords provided by the user. The command searches for keywords in the series' description. The search is not case sensitive. Since the list of series matched might be long, a data set with the series names and description is imported to a new frame called "SearchFrame". At this point it is useful to note that the same can be achieved by using `bpstat dlg`. The only difference is that by using `bpstat dlg`, the search is constrained to one domain, while `bpstat search` uses the whole database.

The search results will include a list of series identifiers and descriptions that match the query, helping you to identify relevant data for your analysis.

**Options for `bpstat search` :**

 - **kw**(*word1 word2 ...*) is the list of keywords provided by the user. By default, the command returns every series whose description contains at least one of the keywords.
 - **fullmatch** changes the search default behaviour. Only series whose description contains the whole string between parenthesis are returned.
 - **intersection** also changes the search default behaviour. By specifying this option, the command returns series whose description contains every word in the list of keywords.
 - **en** sets English as the language for series description. Default is Portuguese.

**Example 1.1**

Search series whose description contains the words "investment" or "international":

```{stata}
bpstat search, kw(investment international) en
```

`browse`

<img width="948" alt="05_search1" src="https://github.com/BPLIM/Tools/assets/51088103/bcc02f3d-450a-400c-908b-c34bb78bb87e"> 

This command searches the BPstat database for statistical series that include either "investment" or "international" in their descriptions. It returns a list of these series, providing a way to identify potentially relevant series for your research or analysis.

By searching for multiple keywords, you can capture a wide range of series that might be relevant to your analysis, increasing the chances of finding useful data.

**Example 1.2**

Search series whose description contains the string "international investment":

```{stata}
bpstat search, kw(international investment) full en
```

`browse`

<img width="947" alt="06_search2" src="https://github.com/BPLIM/Tools/assets/51088103/4d04133c-eaeb-462f-929d-375017d7b45a">


This command searches the BPstat database for statistical series that include "international investment" in their descriptions. It returns a list of these series along with metadata, providing a comprehensive overview of each series.

By searching for specific keywords within descriptions, you can identify series that are highly relevant to your area of interest, saving time compared to manual browsing. 

**Example 1.3**

Search series whose description contains the words "international" and "investment":

```{stata}
bpstat search, kw(international investment) int en
```

```browse```

<img width="946" alt="07_search3" src="https://github.com/BPLIM/Tools/assets/51088103/c0cec839-be9d-43d8-8f68-36711987da24">

This command searches the BPstat database for statistical series that include both "international" and "investment" in their descriptions. It returns a list of these series, allowing you to focus on the data that is most relevant to topics involving international investments.

By ensuring that both keywords are present, you narrow down the search results to series that are specifically relevant to international investment.

## `bpstat describe`

 `bpstat describe` describes the series in BPstat's database. This command prints the series 

**Options for `bpstat describe`:**

- **vars** (*series*) is the list of series. This option is mandatory.
- **en** sets English as the language for series metadata. Default is Portuguese.

**Example 2.1**

Describe the two first series returned by the previous command:

```{stata}
 bpstat describe, vars(D004Q12476167 D004Q12471839) en
```

This allows you to get more information about specific series from the search results, providing detailed metadata about the selected series, including descriptions, units, and periodicity.

Once you have described the series and understand their characteristics, you can import the data for further analysis with the command `bpstat use`.

## `bpstat browse`

`bpstat browse` browses the specified series' web pages.

**Options for `bpstat browse`:**

 - **vars**(*series*) is the list of series. This option is mandatory.

To browse the web page of the series from example 5.1, you need to run the followin command in Stata:

```{stata}
bpstat browse, vars(D004Q12476167 D004Q12471839)
```

This will lead to a series on the BPstat database titled ["IIP-Other inv-Net assets-SDR-Exchange Rate Changes-Qtly-M€"](https://bpstat.bportugal.pt/serie/12471839), which is the web page for the series identified by D004Q12476167 and D004Q12471839. These web pages contain detailed information about the series, including metadata, source information, and possibly additional context or documentation.

Why is this useful? Firsty, it directly access comprehensive metadata about the series, such as definitions, methodologies, and data collection processes. Secondly, with that you can understand the source of the data, which can help in evaluating the reliability and relevance of the data for your analysis. You can also gain additional context and documentation that may not be included in the brief metadata provided within Stata. This can include notes on data revisions, updates, and other important details. Finally, sometimes, the web pages might provide links to related data series or additional resources that are not directly accessible through the Stata command that could be useful for your analysis.

**Updating**

Please make sure `bpstat` is always up to date with the latest available version. In order to do so, run the following command in Stata:

```{stata}
net install bpstat, from("https://github.com/BPLIM/Tools/raw/master/ados/General/bpstat/") replace 
```

