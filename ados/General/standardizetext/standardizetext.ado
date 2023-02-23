*! version 0.2 17Feb2023
* Programmed by Gustavo Iglésias and Marta Silva
* Dependencies: Python 3


program define standardizetext

version 16

syntax varlist(min=1 max=1), GENerate(name) [	///
	ENCoding(str) ///
	SPECialchars ////
	UPper ///
	LOWer ///
	STOPwords(str) ///
]


if ("`encoding'" == "") local encoding "utf-8"



cap confirm var `generate', exact
if !_rc {
	di "{err:variable {bf:`generate'} already defined}"
	exit 110
}

python: standardize_text("`varlist'", "`generate'", "`encoding'", "`specialchars'", "`stopwords'")

qui replace `generate' = trim(stritrim(usubinstr(`generate', "\", " ", .)))
if ("`lower'" == "lower") qui replace `generate' = strlower(`generate')
if ("`upper'" == "upper") qui replace `generate' = strupper(`generate')

end

version 16

python:

import unicodedata
import re
from sfi import Data

def get_pattern():
    return (
        "[" + chr(9) + chr(32) + chr(34) + chr(35) + chr(36)
        + chr(37) + chr(38) + chr(39) + chr(40) + chr(41)
        + chr(42) + chr(43) + chr(44) + chr(45) + chr(46)
        + chr(47) + chr(58) + chr(59) + chr(60) + chr(61)
        + chr(62) + chr(64) + chr(91) + chr(92) + chr(93)
        + chr(94) + chr(95) + chr(96) + chr(123) + chr(124)
        + chr(125) + chr(126) + chr(130) + chr(136) + chr(139)
        + chr(145) + chr(146) + chr(147) + chr(148) + chr(152)
        + chr(155) + chr(164) + chr(165) + chr(167) + chr(168)
        + chr(170) + chr(171) + chr(176) + chr(180) + chr(183)
        + chr(186) + chr(187) + chr(247) + chr(160) + chr(161)
        + chr(162) + chr(163) + chr(169) + chr(173) + chr(179)
        + chr(181) + chr(191) + chr(141) + chr(129) + chr(127)
        + chr(189) + chr(95) + chr(33) + chr(10) + chr(13) + chr(63)
        + chr(39) + chr(44) + chr(45) + chr(46) + chr(174) + chr(150) + "]"
    )

def remove_monkeys(input_str, encoding='utf-8', noboogers=False):
    decoded_str = (bytes(input_str, encoding=encoding)).decode(encoding)
    nfkd_form = unicodedata.normalize('NFKD', decoded_str)
    only_ascii = nfkd_form.encode('ASCII', 'ignore')
    ascii_str = only_ascii.decode('ASCII')
    if noboogers:
        pattern = get_pattern()
        return re.sub(pattern, " ", ascii_str)
    return ascii_str


def standardize_text(var, new_var, encoding='utf-8', noboogers="", stopwords=""):
    varlist = Data.get(var)
    noboogers = True if noboogers == "specialchars" else False
    decoded = [remove_monkeys(item, encoding, noboogers) for item in varlist]
    if stopwords:
        decoded = [removeStopWords(sentence, stopwords.split()) for sentence in decoded]
    Data.addVarStr(new_var, 1)
    Data.store(new_var, None, decoded)
	
	
def removeStopWords(string, words: list):
    pattern = createPattern(words)
    newString = re.sub(pattern, '', string)
    # remove withe space
    newString = re.sub(r'\s{2,}', ' ', newString)
    newString = newString.strip()
    return newString


def createPattern(words):
    patternList = ['\\b{}\\b'.format(word) for word in words]
    
    return '|'.join(patternList)

end