---
title: "User Guide to linkbank"
author: "[BPLIM](http://bplim.bportugal.pt/)"
date: "November 04, 2025"
linkbank_version: "2.0.0"
---

## 1. Introduction

`linkbank` is a tool developed by BPLIM to accurately match individual entity records from datasets based on Central Credit Register data (such as CRC and HCRC) with datasets that use different units of analysis, such as SLB (banking groups or stand-alone institutions) or BBS (stand-alone institutions). Its main objectives are: 

1. Ensure consistent linking across datasets with different units of observation
2. Clarify the scope differences between datasets

The tool package includes the following files:

- `linkbank.ado`: Stata program that runs the command
- `linkbank.sthlp`: Help file describing command usage and available options
- `linkbank.dta`: Dataset mapping IDs across datasets, with accompanying explanatory notes
- `README.txt`

### Before Using the Command

Before using `linkbank`, note that:

- It should be applied to the dataset with the most granular information, i.e., the CRC-like datasets.
- The command does not clear previous results from other bases. This means you can add both SLB and BBS IDs to your dataset.
- It supports linking from December 1999 onward.
- It is updated annually to extend its coverage period.
- To check whether your version includes the period you need, run:

```stata
which linkbank
```

The result will look similar to:

```stata
*! linkbank v2.0.0
*! Author: Emma Zhao and Ana Isabel Sa	
*! Date: 04nov2025
*! Description: Link credit data to BBS and SLB data
*! Coverage period: December 1999 to December 2024
```

- If your `linkbank` version does not cover the required period, request an updated release.

## 2. Understanding Dataset Structures

BPLIM datasets on financial institutions are organized at different levels, which can make combining data across datasets challenging. To facilitate this process, BPLIM developed the `linkbank` command, enabling researchers to link and merge data across these levels.

The different datasets are structured as follows:

**Individual level (financial institution)**: Each record corresponds to a financial or credit institution with a unique authorization ID that reports to the Central de Responsabilidade de Crédito (CRC)—the national database for credit operations. This information feeds into several BPLIM credit datasets, such as HCRC and CRC.

**Consolidated level (banking group)**: Each record represents a banking group, identified by the authorization ID of its head institution, as defined by the prudential supervisor. Changes in the group's legal name or structure do not necessarily result in a new entity, provided the head institution retains its original authorization.

Because these datasets differ in scope, not all records can be fully matched across sources. For detailed information on dataset coverage, refer to the respective product manuals.

## 3. Linking to the SLB Dataset

To link CRC-like datasets to SLB institution IDs, use the following command:

```stata
linkbank bankid timeid, base(slb)
```

The command adds two new columns to your dataset: `id_slb` and `note_slb`.

### Output Variables

**`id_slb`**: This variable corresponds to the identifier used in the SLB dataset. Its value depends on the institution's scope:

- It is the same as in the CRC-like dataset if the institution falls within the SLB scope and operates as a stand-alone institution.
- It is different from the CRC-like dataset if the institution is part of a banking group.
- It is missing if the institution is outside the SLB scope.

**`note_slb`**: This variable provides contextual information explaining cases where `id_slb` differs from the original dataset's ID. It can take one of the following values:

- *1 in a banking group*: The institution is part of a banking group and has been mapped to the head institution's ID.
- *2 CRC assets transferred to other bina*: After a merger or acquisition, the transfer of assets from the former entity to the new one in CRC reporting may be delayed and therefore not align with the financial data. In such cases, the assets are mapped to the new entity, even if they are still reported under the old one in the CRC.
- *3 residual assets*: After liquidation, some credits may continue to be reported in the CRC under the liquidated entity. If there is no known transfer of these assets, they are not linked to any `id_slb` and are classified as residual assets.
- *4 out of SLB scope*: The scope may vary over time. For further details, consult the SLB manual.

## 4. Linking to the BBS Dataset

To link CRC-like datasets to BBS institution IDs, use the following command:

```stata
linkbank bankid timeid, base(bbs)
```

The command adds two new columns to your dataset: `id_bbs` and `note_bbs`.

### Output Variables

**`id_bbs`**: This variable corresponds to the identifier used in the BBS dataset. Its value depends on the institution's scope:

- It is the same as in the CRC-like dataset if the institution falls within the BBS scope.
- It is different from the CRC-like dataset if the institution only reports group info.
- It is missing if the institution is outside the BBS scope.

**`note_bbs`**: This variable provides contextual information explaining cases where `id_bbs` differs from the original dataset's ID. It can take one of the following values:

- *1 group report only*: Individual financial information is not available.
- *2 CRC assets transferred to other bina*: After a merger or acquisition, the transfer of assets from the former entity to the new one in CRC reporting may be delayed and therefore not align with the financial data. In such cases, the assets are mapped to the new entity, even if they are still reported under the old one in the CRC.
- *3 residual assets*: After liquidation, some credits may continue to be reported in the CRC under the liquidated entity. If there is no known transfer of these assets, they are not linked to any `id_bbs` and are classified as residual assets.
- *4 out of BBS scope*: The scope may vary over time. For further details, consult the BBS manual.
- *5 out of BBS reporting period*: The BBS dataset is only available from December 2014 onward.

## 5. Important Notes

### Data Preservation

All observations from your original dataset are preserved by `linkbank`. Institutions that cannot be matched will have missing values in the `id_` variable, with an explanation provided in the `note_` variable.

### Multiple Linkages

You can run `linkbank` multiple times on the same dataset to add both BBS and SLB identifiers:

```stata
linkbank bina date, base(bbs)
linkbank bina date, base(slb)
```

This creates four new variables: `id_bbs`, `note_bbs`, `id_slb`, and `note_slb`.

### Understanding Matches

After running `linkbank`, the command produces a table summarizing the distribution of observations across note categories. This output helps interpret the matching results by indicating which observations (`bankid`-`timeid`) received an ID recoding and the reason for it.

### Data Linking Limitations

While links aim to accurately reflect relationships between datasets, perfect matches cannot always be guaranteed.

Transfer-related timing issues: When institution A transfers operations to institution B, there may be a delay between when the transfer appears in financial data versus CRC reporting.

- If immediately reflected in CRC: No problem, as the CRC data is consistent with financial information.
- If reflected with a delay in CRC: For example, a transfer occurs in January 2010 but institution A continues reporting in CRC until August 2010. In this case:

    - Total transfer: The link is adjusted to reflect the complete transfer, with the note *"2 CRC assets transferred to other bina"*
    - Partial transfer: Accurate linking is not feasible, as the transferred portion cannot be isolated in the CRC data
    
    
---

**THE END**