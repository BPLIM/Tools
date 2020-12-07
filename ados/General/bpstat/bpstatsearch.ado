*! version 0.3 31Oct2020
* Programmed by Gustavo Iglésias
* Dependencies: Python 3 (requests and pandas)


program define bpstatsearch

version 16

syntax, kw(string) [en FULLmatch INTersection]

if ("`fullmatch'" == "fullmatch") & ("`intersection'" == "intersection") {
	di as error `"Options "fullmatch" and "intersection" cannot be combined"'
	exit 198
}

di

qui frame 
if "`r(currentframe)'" == "SearchFrame" {
	clear
}
else {
	cap frame drop SearchFrame
	frame create SearchFrame
}

if "`en'" == "en" {
	local var = "series_desc_en"
}
else {
	local var = "series_desc_pt"
}

if "`fullmatch'" == "fullmatch" {
    local sp = 1
}
else if "`intersection'" == "intersection" {
    local sp = 2
}
else {
	local sp = 0
}

// Get file path
mata: st_local("filename", findfile("BPSTAT_INFO.zip"))
// Change path for Python
while strpos("`filename'", "\") {
	local filename = subinstr("`filename'", "\", "/", 1)
}

python: search("`filename'", "`kw'", "`var'", `sp')

frame SearchFrame {
    qui count 
	local total = `r(N)'
}

if `total' {
	frame change SearchFrame 
	rename var series
	di `"You are currently on frame "SearchFrame". Type "browse" to find which variables description match your keywords."'
}

end

version 16
python:
import pandas as pd
from sfi import Frame


def move_to_stata(df, variable):
    # create dataset in Stata
    stata_frame = Frame.connect("SearchFrame")
    stata_frame.setObsTotal(len(df))
    stata_frame.addVarStr("var", 1)
    stata_frame.store("var", None, df["var"])
    stata_frame.addVarStrL(variable)
    stata_frame.store(variable, None, df[variable])


def gen_cond(string, var):
    string_list = [item.strip() for item in string.split()]
    cond_list = [f"df.{var}.str.contains('{item}')" for item in string_list]
    
    return " & ".join(cond_list)


def search(file, keywords, var, sp):
    df = pd.read_csv(file, usecols=["var", var])
    df["desc_lower"] = df[var].str.lower()
    keywords = keywords.lower()
    if sp == 1:
        regexp = keywords
        filtered = df[df["desc_lower"].str.contains(regexp)]
    elif sp == 2:
        cond = gen_cond(keywords, "desc_lower")
        filtered = df[eval(cond)]
    else:
        kw_list = [item.strip() for item in keywords.split()]
        regexp = "|".join(kw_list)
        filtered = df[df["desc_lower"].str.contains(regexp)]
    filtered = filtered.drop(columns="desc_lower")
    print(f"{len(filtered)} items match your keywords")

    if len(filtered):
        move_to_stata(filtered, var)
	
	
end
