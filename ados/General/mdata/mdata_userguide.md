# A user guide to `mdata`

**Author**: [BPLIM](http://bplim.bportugal.pt/)  
**Date**: 2021/03/03

## 1. Introduction

`mdata` is a [Stata](https://www.stata.com/) user-written package that provides a set of tools to help users handling metadata. The tools are specified as subcommands of `mdata`:

- **extract** extracts metadata from data in memory

- **apply** applies metadata to data in memory

- **check** checks for inconsistencies in metadata

- **cmp** compares metadata files

- **combine** combines metadata files

- **morph** transforms metadata files to eliminate redundant information

- **uniform** harmonizes information in metadata files

- **clear** removes all metadata from data in memory

Almost every subcommand of this package uses an Excel file to store or retrieve metadata.

Apart from `mdata clear`, all the other commands have options that deserve some further explanation, so we will illustrate their use resorting to practical examples using the Stata example data set **nlsw88**.

### Load the data


```stata
sysuse nlsw88
```

    (NLSW, 1988 extract)
    

### Inspect the data


```stata
%head 5
```


<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>idcode</th>
      <th>age</th>
      <th>race</th>
      <th>married</th>
      <th>never_married</th>
      <th>grade</th>
      <th>collgrad</th>
      <th>south</th>
      <th>smsa</th>
      <th>c_city</th>
      <th>industry</th>
      <th>occupation</th>
      <th>union</th>
      <th>wage</th>
      <th>hours</th>
      <th>ttl_exp</th>
      <th>tenure</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1</th>
      <td>1</td>
      <td>37</td>
      <td>black</td>
      <td>single</td>
      <td>0</td>
      <td>12</td>
      <td>not college grad</td>
      <td>0</td>
      <td>SMSA</td>
      <td>0</td>
      <td>Transport/Comm/Utility</td>
      <td>Operatives</td>
      <td>union</td>
      <td>11.739125</td>
      <td>48</td>
      <td>10.333334</td>
      <td>5.3333335</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2</td>
      <td>37</td>
      <td>black</td>
      <td>single</td>
      <td>0</td>
      <td>12</td>
      <td>not college grad</td>
      <td>0</td>
      <td>SMSA</td>
      <td>1</td>
      <td>Manufacturing</td>
      <td>Craftsmen</td>
      <td>union</td>
      <td>6.4009633</td>
      <td>40</td>
      <td>13.621795</td>
      <td>5.25</td>
    </tr>
    <tr>
      <th>3</th>
      <td>3</td>
      <td>42</td>
      <td>black</td>
      <td>single</td>
      <td>1</td>
      <td>12</td>
      <td>not college grad</td>
      <td>0</td>
      <td>SMSA</td>
      <td>1</td>
      <td>Manufacturing</td>
      <td>Sales</td>
      <td>.</td>
      <td>5.0167227</td>
      <td>40</td>
      <td>17.73077</td>
      <td>1.25</td>
    </tr>
    <tr>
      <th>4</th>
      <td>4</td>
      <td>43</td>
      <td>white</td>
      <td>married</td>
      <td>0</td>
      <td>17</td>
      <td>college grad</td>
      <td>0</td>
      <td>SMSA</td>
      <td>0</td>
      <td>Professional Services</td>
      <td>Other</td>
      <td>union</td>
      <td>9.0338125</td>
      <td>42</td>
      <td>13.211537</td>
      <td>1.75</td>
    </tr>
    <tr>
      <th>5</th>
      <td>6</td>
      <td>42</td>
      <td>white</td>
      <td>married</td>
      <td>0</td>
      <td>12</td>
      <td>not college grad</td>
      <td>0</td>
      <td>SMSA</td>
      <td>0</td>
      <td>Manufacturing</td>
      <td>Operatives</td>
      <td>nonunion</td>
      <td>8.0837307</td>
      <td>48</td>
      <td>17.820513</td>
      <td>17.75</td>
    </tr>
  </tbody>
</table>
</div>



```stata
describe
```

    
    Contains data from C:\Program Files\Stata16\ado\base/n/nlsw88.dta
      obs:         2,246                          NLSW, 1988 extract
     vars:            17                          1 May 2018 22:52
                                                  (_dta has notes)
    --------------------------------------------------------------------------------
                  storage   display    value
    variable name   type    format     label      variable label
    --------------------------------------------------------------------------------
    idcode          int     %8.0g                 NLS id
    age             byte    %8.0g                 age in current year
    race            byte    %8.0g      racelbl    race
    married         byte    %8.0g      marlbl     married
    never_married   byte    %8.0g                 never married
    grade           byte    %8.0g                 current grade completed
    collgrad        byte    %16.0g     gradlbl    college graduate
    south           byte    %8.0g                 lives in south
    smsa            byte    %9.0g      smsalbl    lives in SMSA
    c_city          byte    %8.0g                 lives in central city
    industry        byte    %23.0g     indlbl     industry
    occupation      byte    %22.0g     occlbl     occupation
    union           byte    %8.0g      unionlbl   union worker
    wage            float   %9.0g                 hourly wage
    hours           byte    %8.0g                 usual hours worked
    ttl_exp         float   %9.0g                 total work experience
    tenure          float   %9.0g                 job tenure (years)
    --------------------------------------------------------------------------------
    Sorted by: idcode
    

## 2. `mdata extract`

Using the `describe` command, we get all sort of information, like the type and format of variables, variables' labels, value labels names, etc. The output we get is just a summary of the data in memory. If we used a command like `codebook`, we would get a more in-depth look at the variables in the data set. With `mdata extract`, the first command of the `mdata` package we present, we get all this information exported to an **Excel** file. The basic syntax is as follows:


```stata
mdata extract
```

    
    File metafile.xlsx saved
    

Since we did not specify any option, the metadata is exported by default to file *metafile.xlsx*. Lets look at this file in more detail. The three first sheets are always exported, independently of the data set in memory.  

The sheet **data_features_gen** contains general information about the data set, namely file name, data label, variables used to sort the data, label languages defined, notes and characteristics.

<p align="center">
<figure>
    <img width="617" alt="1_extract_01" src="https://user-images.githubusercontent.com/44852742/110009746-580d8b80-7d15-11eb-8bcb-c9a37eba3457.PNG">
    <figcaption><strong>Figure 2.1</strong></figcaption>
</figure>
</p>
 
The second sheet, **data_features_spec**, displays information on the number of observations, number of variables, data set size, data signature and date of last change.

<p align="center">
<figure>
    <img width="581" alt="1_extract_02" src="https://user-images.githubusercontent.com/44852742/110009748-580d8b80-7d15-11eb-88f2-005472b4cc94.PNG">
    <figcaption><strong>Figure 2.2</strong></figcaption>
</figure>
</p>

A third sheet named **variables** presents a table with information for each variable, namely variable name, label (for every defined language), value labels (if they exist), type, format, notes and characteristics.

<p align="center">
<figure>
    <img width="606" alt="1_extract_03" src="https://user-images.githubusercontent.com/44852742/110009749-58a62200-7d15-11eb-8467-7da0e747ef1c.PNG">
    <figcaption><strong>Figure 2.3</strong></figcaption>
</figure>
</p>


Note that the names of the columns **label_default** and **value_label_default** may change, since the suffix **default** corresponds to language the defined. 

As you probably noticed, the Excel file contains more than three sheets. If the data set has characteristics, notes or value labels defined, then there will be an additional sheet for each of them. There is one sheet per value label, note and characteristic. For value labels, the name of the sheet is **vl_name**, where **name** is the name of the value label. For notes and characteristics, the name of the sheet is **char/note_var**, where **var** is the name of the variable to which the note or characteristic applies. 

We can see that are no characteristics or notes ascribed to any variable, but some variables have value labels defined. For example, value label **occlbl** is defined for variable **occupation**. Let's inspect the contents of worksheet **vl_occlbl**.

<p align="center">
<figure>
    <img width="571" alt="1_extract_04" src="https://user-images.githubusercontent.com/44852742/110009750-58a62200-7d15-11eb-9efe-701908aa97f9.PNG">
    <figcaption><strong>Figure 2.4</strong></figcaption>
</figure>
</p>

Please keep in mind that value labels worsheets' names will always follow the pattern *vl_\<vl_name\>*. Each worksheet for value labels presents a table with two columns, the value and the corresponding label.

There are no characteristics or notes ascribed to any variable, but from **Figure 2.1** we observe that the data set has characteristics, two to be more precise. The contents of these characteristics are stored in worksheet **char__dta**, presented below:

<p align="center">
<figure>
    <img width="612" alt="1_extract_05" src="https://user-images.githubusercontent.com/44852742/110009740-56dc5e80-7d15-11eb-976a-11247265d188.PNG">
    <figcaption><strong>Figure 2.5</strong></figcaption>
</figure>
</p>

Worksheets for characteristics feature a table with two columns, **char** - the name of the characteristic, and **value** - the characteristic's value. In the case presented above, the data set characteristics are set by default by Stata. 

Just to check what a worksheet for notes attached to a variable would look like, we are going to set two notes for variable **age**.


```stata
notes age: age note 1
notes age: age note 2
```

We will export the metadata again. If we were to use the same syntax, `mdata extract`, we will get an error, since *metafile.xlsx* already exists. We can specify a different name or replace the existing file. Both ways demand that we specify the option **meta**. We choose the latter, replacing the existing file.


```stata
mdata extract, meta(metafile, replace)
```

    
    File metafile.xlsx saved
    

<p align="center">
<figure>
    <img width="609" alt="1_extract_06" src="https://user-images.githubusercontent.com/44852742/110009741-5774f500-7d15-11eb-8704-b64bbfd8e529.PNG">
    <figcaption><strong>Figure 2.6</strong></figcaption>
</figure>
</p>

Looking at the **variables** worksheet, we see that variable **age** now has two notes. Let's inspect the worksheet **note_age**.

<p align="center">
<figure>
    <img width="564" alt="1_extract_07" src="https://user-images.githubusercontent.com/44852742/110009743-5774f500-7d15-11eb-8dcd-7dc1807f24f1.PNG">
    <figcaption><strong>Figure 2.7</strong></figcaption>
</figure>
</p>

The worksheet contains only one column with the various notes defined for variable **age**. As you have possibly noticed from **Figure 2.6**, the value of columns **chars** also changed from 0 to 3 for variable **age**. That's because Stata creates characteristics once you assign notes to variables or to the data. 

<p align="center">
<figure>
    <img width="571" alt="1_extract_08" src="https://user-images.githubusercontent.com/44852742/110009745-580d8b80-7d15-11eb-8232-973d604c9945.PNG">
    <figcaption><strong>Figure 2.8</strong></figcaption>
</figure>
</p>

Stata created three characteristics for variable **age**, two whose values are equal to the notes and a third one which is the number of notes assigned to that variable.

`mdata extract` has three more options, namely **problems**, **checkfile** and **truncate**. The first two should only be specified if the user wants to check for problems in the metadata. It basically runs the command `mdata check`, which we will discuss later. Option **truncate** forces the truncation of variables and value labels names if their length is larger than 25 and 27 characters, respectively. If the user does not specify this option, the program will stop once it finds variables or value labels in those circumstances. This limitation exists because Excel imposes a 30 character limit on worksheet's names. The 27 and 25 characters limit stems from the fact that we prefix value label worksheets with *vl_* and characteristics/notes worksheets with *char*/*note*. 

## 3. `mdata check`

In the previous section we learned how to extract the metadata from Stata to an Excel file. But are there problems with the metadata? `mdata check` verifies the integrity of metadata stored in an Excel file, assuming that the structure of that file is the same as the one produced by `mdata extract`. As a first example, we search for inconsistencies in *metafile.xlsx*.

```stata
mdata check, meta(metafile) check(checkfile)
```

    No warnings or inconsistencies found. File checkfile.xlsx will not be saved
    

We can see that we do not have warnings or inconsitencies. So even though we specify option **check**file to save the report, the program does not create such file.

Now imagine that someone had removed one value label sheet by mistake. While this can be done manually, we will use `mata` to remove one worksheet. 


```stata
mata
    book = xl()
    book.load_book("metafile.xlsx")
    book.delete_sheet("vl_marlbl")
    book.close_book()
end
```

    
    ------------------------------------------------- mata (type end to exit) ------
    
    
    :     book.load_book("metafile.xlsx")
    
    :     book.delete_sheet("vl_marlbl")
    
    :     book.close_book()
    
    : end
    --------------------------------------------------------------------------------
    

Once the sheet has been deleted, we check for inconsistencies.


```stata
mdata check, meta(metafile) check(checkfile, replace)
```

    
    worksheet vl_marlbl not found
    
    
      +---------------------------------------------+
      |      worksheet | warnings | inconsistencies |
      |----------------+----------+-----------------|
      | missing_sheets |        0 |               1 |
      +---------------------------------------------+
    
    File checkfile.xlsx saved
    

Now we get an inconsistency instead of a a warning. We will see what sets them apart in a while. First let's take a look at *checkfile.xlsx*.

<p align="center">
<figure>
    <img width="479" alt="2_extract_03" src="https://user-images.githubusercontent.com/44852742/110127335-6ca55e80-7dbd-11eb-976c-69d0cc255e1d.PNG">
    <figcaption><strong>Figure 3.3</strong></figcaption>
</figure>
</p>

<p align="center">
<figure>
    <img width="484" alt="2_extract_04" src="https://user-images.githubusercontent.com/44852742/110127350-7038e580-7dbd-11eb-96ca-7ec770d9eb8a.PNG">
    <figcaption><strong>Figure 3.4</strong></figcaption>
</figure>
</p>

The summary tells us that we have only one problem, **missing_sheets**, which is an inconsitency and the number of missing sheets is on. Inspecting the worksheet **missing_sheets**, we check that **vl_marlbl** is missing, as we would expect. 

So what distinguishes an inconsistency from a warning? As stated in the help file of `mdata check`, 

> The categorization of problems into warnings and inconsistencies is related to the use of `mdata apply`, which performs an integrity check of the metadata before applying it. So an inconsistency is every problem found in the Excel file that stops `mdata apply` from running. On the other hand, warnings flag problems in the metadata, but do not halt the execution of `mdata apply`.

> Inconsistencies include duplicated variables in the meta file, missing sheets, and duplicated labels or duplicated values in value labels. Warnings cover problems such as duplicated data features, missing variable labels, truncated variable labels, missing value labels if there is more than one language defined, as well as problems with value labels other than duplicated labels or values. Most of the value label problems were based on [labelbook](https://www.stata.com/manuals/dlabelbook.pdf), used with option problems.

If you are wondering how we get duplicated values in value labels, that is a pertinent question, since value labels do not have multiple numerical codes. This comes in handy when you use a command like `mdata combine`, which we will see in more detail later. Think for example of a situation where you get data every month and encode *string* variables to save storage space. If you do it every month, it's normal that some values of the *string* variables are encoded using the same numerical code. If you run `mdata extract` every month, you will end up with repeated values. By running `mdata check` on a combined version of all the extracted meta files, we spot these inconsistencies, which allows us to go back and do the encoding properly.

So the organization of warnings and inconsistencies depends on the command `mdata apply`. It's logical that we move on to show the details of that command. 

## 4. `mdata apply`

`mdata apply`, as the name suggests, applies metadata to data in memory. As mentioned before, `mdata apply` runs `mdata check` prior to applying the metadata. It also clears all the metadata using `mdata clear`, so users should be careful when using it. Going back to our metadata file *metafile.xlsx*, we will use it to apply the metadata. But remember that with had an inconsistency in our file, so if you try to run `mdata apply` without making some kind of change to that file you get an error. For the sake of simplicity, we are going to export the meta file again.


```stata
mdata extract, meta(metafile, replace)
```

    
    File metafile.xlsx saved
    


```stata
import excel using "metafile.xlsx", describe
```

    
                   Sheet | Range
      -------------------+-------------------
       data_features_gen | A1:B12
      data_features_spec | A1:B6
               variables | A1:G18
              vl_gradlbl | A1:B3
               vl_indlbl | A1:B13
               vl_marlbl | A1:B3
               vl_occlbl | A1:B14
              vl_racelbl | A1:B4
              vl_smsalbl | A1:B3
             vl_unionlbl | A1:B3
               char__dta | A1:B3
                char_age | A1:B4
                note_age | A1:A3
    

We observe that worksheet **vl_marlbl** is back in the file, so we can proceed with `mdata apply`. If you run the command only with option **metafile**, the metadata is applied to data but you do not have an insight into what changes were made (in this case there are no changes but remember that the command is usually run on data without metadata). For the sake of transparency, the user may specify the option **dofile** to save a copy of the do-file used to apply the metadata.


```stata
mdata apply, meta(metafile) do(metapply)
```

    File metapply.do saved
    

Let's look at the first lines of the file *metapply.do*, using Stata's `type` command.


```stata
type metapply.do, lines(50)
```

    * Data features
    label data "NLSW, 1988 extract"
    sort idcode
    cap label language default, new
    note: 1988 data, extracted from National Longitudinal of Young Woman
    note: For more information on the NLS, see
    note: This dataset is the result of extraction and processing by various
    note: http://www.bls.gov/nls/
    note: people at various times.
    note: who were ages 14-24 in 1968 (NLSW).
    
    
    **** age ****
    
    * Type
    recast byte age
    * Format
    format %8.0g age
    * Variable label - default
    label language default
    label variable age "age in current year"
    * Notes
    note age: age note 1
    note age: age note 2
    
    
    **** c_city ****
    
    * Type
    recast byte c_city
    * Format
    format %8.0g c_city
    * Variable label - default
    label language default
    label variable c_city "lives in central city"
    
    
    **** collgrad ****
    
    * Type
    recast byte collgrad
    * Format
    format %18.0g collgrad
    * Variable label - default
    label language default
    label variable collgrad "college graduate"
    * Value label - default
    label define gradlbl 0 `"0 not college grad"', add
    label define gradlbl 1 `"1 college grad"', add
    label values collgrad gradlbl, nofix
    

There's not much more than this regarding `mdata apply`, so we are going to move to the next command, `mdata cmp`.

## 5. `mdata cmp`

Going back to the situation where we receive data every month, we would think that the structure of the data and its metadata should not change that much from month to month. The way to compare metadata between files is to use `mdata cmp`. We already have a file *metafile.xlsx* storing metadata. We are going to introduce some changes to our current data, extract the resulting metadata, and then compare the files.


```stata
* Add new random variable
gen random = runiform()
* Add new value to variable married, add value label (divorced)
qui replace married = 2 if mod(idcode, 7) == 0
label define marlbl 2 "2 divorced", add
* Change label 
label var idcode "worker id"
* Extract the metadata
mdata extract, meta(metafile2)
```

    
    
    
    
    
    
    File metafile2.xlsx saved
    

Now that we have two Excel files with metadata, we are going to compare them. The files under comparison should be specified in options **oldfile** and **newfile**. The report is saved in an Excel file. The user may use option **export** to specify the name of this file, or it defaults to *metacmp.xlsx*.


```stata
mdata cmp, new(metafile2) old(metafile) 
```

    
    File metacmp.xlsx saved
    

<p align="center">
<figure>
    <img width="578" alt="3_extract_01" src="https://user-images.githubusercontent.com/44852742/110456259-3fa8c280-80c1-11eb-88a8-56c7101abb73.PNG">
    <figcaption><strong>Figure 5.1</strong></figcaption>
</figure>
</p>

Inspecting *metacmp.xlsx*, specifically the **Summary** worksheet, we observe that the changes we have introduced in the data are flagged. We have exactly one inconsistency for variables, variables' labels and value label **mar_vl**. Let's check the contents of each worksheet.

<p align="center">
<figure>
    <img width="413" alt="3_extract_02" src="https://user-images.githubusercontent.com/44852742/110456254-3e779580-80c1-11eb-82b1-29193e5900ac.PNG">
    <figcaption><strong>Figure 5.2</strong></figcaption>
</figure>
</p>

The **Variables** worksheet presents a table with only one row and two columns, **variable** and **desc**. The first column is self-explanatory, the second lets us know that the variable *random* only appears in the new file. If it were only present in the old file, the value in that cell would be *old*. Please notice that values *old* and *new* depend on the files specified in `mdata cmp` through options **oldfile** and **newfile**.



<p align="center">
<figure>
    <img width="413" alt="3_extract_03" src="https://user-images.githubusercontent.com/44852742/110456257-3f102c00-80c1-11eb-857b-0c1b0f961805.PNG">
    <figcaption><strong>Figure 5.3</strong></figcaption>
</figure>
</p>

Worksheet **Variables' label_default** presents a table differences in variables' labels. The suffix **_default** is the label language. The structure of the table is always the same. There is a column with variables that contain differences and two additional columns, in this case *_new_label_default* and *_old_label_default*. *_new_label_default* stands for the the variable label in the new file (*metafile2.xlsx*) defined for label language *default*. The same logic applies to *_old_label_default*.


<p align="center">
<figure>
    <img width="414" alt="3_extract_04" src="https://user-images.githubusercontent.com/44852742/110456258-3f102c00-80c1-11eb-8945-e33aff56d241.PNG">
    <figcaption><strong>Figure 5.4</strong></figcaption>
</figure>
</p>

Finally, worksheet **vl_marlbl** flags differences in value label *marlbl*. Even if we had not defined a new level for *marlbl*, this sheet would signal that the new meta file contains a new value. That is the reason why the table presented has four columns, *value*, *desc*, *label_old* and *label_new*. In the case at hand, value 2 is only present in the new file (*metafile2.xlsx*) and has value label "2 divorced". Please notice that these type of comparison only makes sense for categorical variables.

We have seen a small of example of how to use `mdata cmp`. However, so not forget that we only introduced three small changes in the data. The comparison performed by `mdata cmp` is exhaustive. Every sheet and value in the metadata files are compared. 

We should also be able to combine two meta files. And for that we have `mdata combine`.

## 6. `mdata combine`

`mdata combine`, as the name suggests, combines metadata found in Excel files. The program combines metadata in sheets with the same name found in both files, eliminating duplicated information. As we mentioned when describing `mdata check`, `mdata combine` can generate inconsistencies in metadata files. Think again about the case of a value label that, when combined, has two equal values and different labels. This is an inconsistency and should be flagged. So we recommend that the user runs `mdata check` after combining meta files, so as to find problems in the underlying data.

We are going to combine the two meta files that we have saved, *metafile.xlsx* and *metafile2.xlsx*. The user must specify the two files under options **f1** and **f2**. The name of the combined file may be set with option **metafile**, and defaults to *metafile.xlsx*. 


```stata
mdata combine, f1(metafile) f2(metafile2) meta(meta_comb)
```

    
    Combining meta files metafile.xlsx and metafile2.xlsx
    
    File meta_comb.xlsx saved
    

The result is a combined version of the two meta files. Users are always advised to inspect combined files, particularly if they wish to use the combined file in `mdata apply`. Let's check the result. We are particularly interested in worksheets **variables** and **vl_marlbl**.

<p align="center">
<figure>
    <img width="616" alt="4_extract_01" src="https://user-images.githubusercontent.com/44852742/110483385-94f4cc00-80e1-11eb-95f4-1ec4fe86879c.PNG">
    <figcaption><strong>Figure 6.1</strong></figcaption>
</figure>
</p>

The table shows three rows that are of particular interest, which are flagged by "f1" or "f2" in column *file1*. In this particular worksheet, when the information is combined, the deduplication is performed using columns *variable*, *label_\<lang\>* and *value_label_\<lang\>*, where \<lang\> stands for the label language. Therefore, we get three flags. Two rows have common variables (which would be an inconsistency flagged by `mdata check` and halt the execution of `mdata apply`) because we changed the labels and one row has information about variable **random**. When the information is found in only one of the two metadata files, we flag that row in column file# with "f1" or "f2" depending on the source of the information, according to the files specified in option **f1** and **f2**.


<p align="center">
<figure>
    <img width="581" alt="4_extract_02" src="https://user-images.githubusercontent.com/44852742/110483388-9625f900-80e1-11eb-81e7-da13e439f15e.PNG">
    <figcaption><strong>Figure 6.2</strong></figcaption>
</figure>
</p>

Worksheet **vl_marlbl** contains the same information as in *metafile2.xlsx*, since all we did was add a new value. But we get a flag telling us that the unique row comes from *metafile2.xlsx* (**f2**). It's worth noting that it's possible to have more than one column with the pattern file#. If you were to use the combined meta file and combine it with another meta file, you would end up with columns *file1* and *file2* in the new combined file.

## 7. `mdata morph`

`mdata morph` transforms a metadata file to eliminate redundant information. This only works with value labels. Imagine a situation where you have two variables that have a value label defined for each of them but should in principle share that value label. Let's go back to our example. We have variable **collgrad** with value label **gradlbl**. Now let's add a new variable **bcollgrad** which has the same values and labels as **collgrad**, but refers to the employee's boss college graduation. We know that we should apply the the value label already defined to the new variable, but as this is just an example, for the sake of ilustrative purposes, imagine that we got the data like this.


```stata
qui sysuse nlsw88, clear
* Generate random zeros and ones (ones with higher probability)
set seed 42
gen bcollgrad = uniform() <= .7
* Label bcollgrad
label copy gradlbl bgradlbl
label values bcollgrad bgradlbl
mdata extract, meta(metafile, replace)
```

    
    
    
    
    
    
    
    File metafile.xlsx saved
    

<p align="center">
<figure>
    <img width="596" alt="5_extract_01" src="https://user-images.githubusercontent.com/44852742/110656806-364e5180-81b8-11eb-9a77-6a2f17e06410.PNG">
    <figcaption><strong>Figure 7.1</strong></figcaption>
</figure>
</p>

Looking at the **variables** worksheet, we have the new variable - **bcollgrad** - in the last row, with **bgradlbl** as value label. On the other hand, variable **collgrad** has value label **gradlbl**. We can check worksheets *vl_gradlab* and *vl_bgradlbl* to see that we have duplicated infromation.

<p align="center">
<figure>
    <img width="456" alt="5_extract_02" src="https://user-images.githubusercontent.com/44852742/110514905-b49aed00-80ff-11eb-992c-a310eba8e9b3.PNG">
    <figcaption><strong>Figure 7.2</strong></figcaption>
</figure>
</p>

<p align="center">
<figure>
    <img width="455" alt="5_extract_03" src="https://user-images.githubusercontent.com/44852742/110514908-b5338380-80ff-11eb-85c0-cb70b40a5d68.PNG">
    <figcaption><strong>Figure 7.3</strong></figcaption>
</figure>
</p>

Given that we have duplicated information, we should use `mdata morph` to eliminate redundancies.


```stata
mdata morph (vl_grad = vl_gradlbl vl_bgradlbl), meta(metafile) save(metafile, replace)
```

    
    merging worksheets vl_gradlbl vl_bgradlbl
    
    worksheet vl_grad created
    
    removing worksheets vl_gradlbl vl_bgradlbl
    

The syntax of the command shows what we are doing. Inside the first parentheses, the user specifies the sheets that he or she wants to merge (the right side of the expression), and the new sheet that should be created from those sheets (the left side of the expression). It's important that **the names of the worksheets are of the form vl_\<vlname>**, so it can be used by other tools of package **mdata**. Also, **the name of the new sheet should never have the name of an existing worksheet, including the ones that are being merged**. Users may specify more than one merge.

Option **metafile** is mandatory and specifies the name of the meta file that we want to change. Option **save** is not mandatory and defaults to the name of the file set in option **metafile** plus the suffix *_new*. So, had we not specified option **save**, the changed metafile would be saved as *metafile_new.xlsx*.

<p align="center">
<figure>
    <img width="455" alt="5_extract_04" src="https://user-images.githubusercontent.com/44852742/110663256-2d607e80-81be-11eb-8f3e-34e34db5bcc7.PNG">
    <figcaption><strong>Figure 7.4</strong></figcaption>
</figure>
</p>

Inspecting the file *metafile.xlsx*, the worksheets **vl_bgradlbl** and **vl_gradlbl** no longer exist, since they were replaced by **vl_grad**. Users may specify option **keep** to keep merged worksheets in the meta file. But that's not the only change made to *metafile.xlsx*. Look at worksheet **variables**.


<p align="center">
<figure>
    <img width="572" alt="5_extract_05" src="https://user-images.githubusercontent.com/44852742/110663272-2e91ab80-81be-11eb-82a9-fa4de97c219e.PNG">
    <figcaption><strong>Figure 7.5</strong></figcaption>
</figure>
</p>

As you might have observed, values in column *value_label_default* have changed for rows with variables **collgrad** and **bcollgrad**. Now they have the same value - *grad*, the name of the new value label. This is important if you want to use this file in `mdata apply`. Now the program knows that it should define value label *grad* and apply it to variables **collgrad** and **bcollgrad**. 

## 8. `mdata uniform`

`mdata uniform` is a command that was created with a very particular goal in mind. It serves very specific needs raised by **BPLIM** staff and might not be useful for the general user. Nevertheless, it's worth describing how it works since it's part of the package and it might be useful for people that face the same challenges. To give some perspective, we should describe the problem. 

**BPLIM** gets data every month from data producers. That data contains all type of variables. We are particular interested in categorical data, because this command only applies to that type. Usually those type of variables are not encoded, they come in pairs. One is the code (be it strictly numerical, alphanumerical or containing only letters) and the other is the label. To be efficient storage-wise, we encode every variable using the code and label (creating a value label). When the code contains only numbers there is no problem since the value of the variable corresponds to the actual code. However, when a code contains only letters or letters and numbers, the encoding has to follow some rule. For this task, we use [bpencode](https://github.com/BPLIM/Tools/tree/master/ados/General/bpencode), which was also created by BPLIM. The command has its own logic for the encoding, which is not important for the exposition at hand. 

Now imagine that we get the data in different months. Some values that are present in the most recent batch of data might be missing in the old one. So, it's possible that the encoding assigns identical numerical codes for different values of the same variable. If we worked with data for only one month, no problem would arise, but we want to be able to combine data from different months. A process for harmonization is needed. That is why we created `mdata uniform`. 

Say we get data for two consecutive months. We treat the data, encoding variables that need be encoded. We use `mdata extract` to save the metadata to a file in each month. Then we combine the metadata using `mdata combine`. Because we are cautious, we use `mdata check` to check the integrity of the metadata, only to find that one particular sheet - *vl_lbl* (this name is purely fictitious), has inconsistencies, more specifically duplicated values. If we want to harmonize that worksheet, we would use `mdata uniform`. Let's create some artificial data to illustrate. For simplicity, our data we'll have two variables and two observations, which is sufficient to understand the process.


```stata
* Month 1
/* Variable yesno_lbl has no use in this example, it's here just 
for the user to understand how we label using bpencode */
clear
quietly {
    set obs 2
    * Variable with code
    gen yesno = "Y" in 1
    replace yesno = "N" in 2
    * Variable with label
    gen yesno_lbl = "Yes" in 1
    replace yesno_lbl = "No" in 2    
}
list, noo ab(10)
```

    
    
    
    . list, noo ab(10)
    
      +-------------------+
      | yesno   yesno_lbl |
      |-------------------|
      |     Y         Yes |
      |     N          No |
      +-------------------+
    

We would use [bpencode](https://github.com/BPLIM/Tools/tree/master/ados/General/bpencode) to encode variable **yesno** and label its values using variable **yesno_lbl**. [bpencode](https://github.com/BPLIM/Tools/tree/master/ados/General/bpencode) always uses the original code in the label, so that the label is of the form *code description*. **This is important if you want to use `mdata uniform`, since it uses the code part of the label to harmonize values**. For this mock case we can use [encode](https://www.stata.com/manuals/dencode.pdf) with the same effect.


```stata
* Encode variable
tempvar temp
encode yesno, gen(`temp')
drop yesno yesno_lbl
rename `temp' yesno
* Label variable 
label var yesno "Yes/No"
* Label values
label define yesnolbl 1 "N No" 2 "Y Yes"
label values yesno yesnolbl
* Extract metadata
mdata extract, meta(month1)
```

    
    
    
    
    
    
    
    
    
    File month1.xlsx saved
    

<p align="center">
<figure>
    <img width="454" alt="6_extract_01" src="https://user-images.githubusercontent.com/44852742/110768897-8b897200-824f-11eb-9063-4ffda879ce54.PNG">
    <figcaption><strong>Figure 8.1</strong></figcaption>
</figure>
</p>

Using `mdata extract`, we get worksheet **vl_yesnolbl** in file *month1.xlsx* as we would expect. Now let's move to the second month. Imagine that in this month, we get another value for variable **yesno** and there is no value "N" for any observation. 


```stata
* Month 2
clear
quietly {
    set obs 2
    * Variable with code
    gen yesno = "Y" in 1
    replace yesno = "DN" in 2
    * Variable with label
    gen yesno_lbl = "Yes" in 1
    replace yesno_lbl = "Don't know" in 2    
}
list, noo ab(10)
```

    
    
    
    . list, noo ab(10)
    
      +--------------------+
      | yesno    yesno_lbl |
      |--------------------|
      |     Y          Yes |
      |    DN   Don't know |
      +--------------------+
    


```stata
* Encode variable
tempvar temp
encode yesno, gen(`temp')
drop yesno yesno_lbl
rename `temp' yesno
* Label variable 
label var yesno "Yes/No"
* Label values
label define yesnolbl 1 "DN Don't know" 2 "Y Yes"
label values yesno yesnolbl
* Extract metadata
mdata extract, meta(month2)
```

    
    
    
    
    
    
    
    
    
    File month2.xlsx saved
    

In file *month2.xlsx*, worksheet **vl_yesnolbl** is different.

<p align="center">
<figure>
    <img width="454" alt="6_extract_02" src="https://user-images.githubusercontent.com/44852742/110770533-54b45b80-8251-11eb-839f-ad1a0e1b4e97.PNG">
    <figcaption><strong>Figure 8.2</strong></figcaption>
</figure>
</p>

Now we are going to combine the metadata from both months, because our goal is to have harmonized data.


```stata
mdata combine, f1(month1) f2(month2) meta(comb)
```

    
    Combining meta files month1.xlsx and month2.xlsx
    
    File comb.xlsx saved
    

<p align="center">
<figure>
    <img width="455" alt="6_extract_03" src="https://user-images.githubusercontent.com/44852742/110771247-30a54a00-8252-11eb-9fcc-2f5aaaf34756.PNG">
    <figcaption><strong>Figure 8.3</strong></figcaption>
</figure>
</p>

Looking at worksheet **vl_yesnolbl** in the combined metadata file, we can see that we have a problem. Two rows share the same value. We can use `mdata check` to verify such problems.


```stata
mdata check, meta(comb) check(combcheck)
```

    
    
      +------------------------------------------+
      |   worksheet | warnings | inconsistencies |
      |-------------+----------+-----------------|
      | vl_yesnolbl |        0 |               2 |
      +------------------------------------------+
    
    File combcheck.xlsx saved
    

We see immediately that we get two inconsitencies. Let's look at *combcheck.xlsx*.

<p align="center">
<figure>
    <img width="440" alt="6_extract_04" src="https://user-images.githubusercontent.com/44852742/110773425-a3172980-8254-11eb-80a7-77cca23f3e7d.PNG">
    <figcaption><strong>Figure 8.4</strong></figcaption>
</figure>
</p>

The problem is flagged in worksheet **vl_yesnolbl**, showing that we have two rows with duplicated values. To solve this problem and harmonize the metadata in file *comb.xlsx* we will use `mdata uniform`. This command uses [bpencode](https://github.com/BPLIM/Tools/tree/master/ados/General/bpencode) to recode values. We have to specify the worsheets that should be harmonized, otherwise it will work on every sheet that starts with "vl_".


```stata
mdata uniform, meta(comb) sh(vl_yesnolbl)
```

    
    Encoding __00001V
    
    Codes in sheet vl_yesnolbl harmonized
    
    File comb_new.xlsx saved
    

Since we did not specify option **newfile**, the new metadata file is save in *comb_new.xlsx* (the name of the meta file plus the suffix new). Let's check the contents of *comb_new.xlsx*, specifically worksheet **vl_yesnolbl**.

<p align="center">
<figure>
    <img width="447" alt="6_extract_05" src="https://user-images.githubusercontent.com/44852742/110775797-3ea99980-8257-11eb-98ee-b5ce4583a186.PNG">
    <figcaption><strong>Figure 8.4</strong></figcaption>
</figure>
</p>

We observe that now every row has a different value. But there is another difference. We have values 101, 102 and 103 instead of 1, 2, and 3. That's because [bpencode](https://github.com/BPLIM/Tools/tree/master/ados/General/bpencode) plays safe and adds digits to allow for more categories in the future. And that is how we would use `mdata uniform`. This would only change the metadata files. Since our goal at BPLIM is to harmonize the actual data, we would change the monthly data using `bp_recode`, a command of package [bpencode](https://github.com/BPLIM/Tools/tree/master/ados/General/bpencode) that uses a metadata file to recode values. 

**Dependencies**:

  - [gtools](https://gtools.readthedocs.io/en/latest/)
    
  - [bpencode](https://github.com/BPLIM/Tools/tree/master/ados/General/bpencode)
