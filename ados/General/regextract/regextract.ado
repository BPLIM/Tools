*! version 0.1 11May2022
* Programmed by Gustavo Iglésias
* Dependencies: Python 3 (pandas)


program define regextract

version 16

syntax varname(str), REGex(str) GENerate(str)

python: extract("`varlist'", "`regex'", "`generate'")


end

version 16
python:
import pandas as pd
from sfi import Data

def extract(var, regex, new_var):
    var_dict = Data.getAsDict(var)
    df = pd.DataFrame(var_dict)
    extract = df[var].str.extract(regex)
    cols = extract.shape[1]
    if cols == 1:
        extract[0] = extract[0].fillna("")
        Data.addVarStr(new_var, 1)
        Data.store(new_var, None, extract[0])
    else:
        for col in extract.columns:
            j = col + 1
            extract[col] = extract[col].fillna("")
            Data.addVarStr(f"{new_var}{j}", 1)
            Data.store(f"{new_var}{j}", None, extract[col])	
end