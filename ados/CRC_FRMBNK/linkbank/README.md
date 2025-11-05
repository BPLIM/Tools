# LINKBANK:  Creates linking IDs for financial institutions in Central Credit Register (CRC) and related datasets for merging with Bank Balance Sheet (BBS) or Historical Series of the Portuguese Banking Sector (SLB)


Last Version: 2.0.0

Release Date: 04Nov2025


`linkbank' is a [Stata](http://www.stata.com/) tool developed by BPLIM to accurately match individual entity records from datasets based on Central Credit Register data (such as CRC and HCRC) with datasets that use different units of analysis, such as SLB (banking groups or stand-alone institutions) or BBS (stand-alone institutions). Its main objectives are:

1) Ensure consistent linking across datasets with different units of observation

2) Clarify the scope differences between datasets


The 2.0.0 version replaces older versions, as well as similar commands like mergebbs, mergecrc, and mergecrcslb.


Requirements: It requires a crosswalk table (.dta file) containing the updated merge instructions. The file is version specific and is available upon request on BPLIM's external server.


## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
