The csv file
==============


`checkmd` relies on a csv file where the user provides information about the checks he or she wants to perform. For illustrative purposes, we will show the columns and input values of that file in a table, but please keep in mind that the command always uses a csv formatted file.

The table presented below is an example of some conditions one could test if using the *auto* dataset.

| check_id   |   active | check_title                               | cond                               |   delta | misstozero   |   list_val |   ignoremiss |   ignore |
|:-----------|---------:|:------------------------------------------|:-----------------------------------|--------:|:---------|-----------:|-------------:|---------:|
| auto_1     |        1 | Price smaller than 10000                  | price<10000                        |       1 | 1     |          5 |              |          |
| auto_2     |        1 | rep78 not missing                         | rep78<.                            |         |          |            |              |          |
| auto_3     |        1 | weight over length larger than 2          | (weight/length)>2                  |         | 1     |          5 |              |          |
| auto_4     |        1 | price greater than mean price by foreign  | price>mpbyf                        |       1 |       |          5 | 1            |          |
|            |        2 | generating variable mean price by foreign | egen mpbyf=mean(price),by(foreign) |         |          |            |              |          |
| auto_5     |        1 | Dodge in make                             | regexm(make,"Dodge")               |         |          |            |              |          |

**checkid:** the identifier for the checks. It is used as an ID to summarize information about inconsistent values and, if specified, as the name for the dataset with inconsistencies. This field is mandatory for checks.

**active:** code used to signal what rows are checks (1) and which rows represent stata code run before the checks (2). It is also possible to ignore the row completely (0). This field is mandatory for every row.

**check_title:** the title of the check. Mandatory for checks (rows where active = 1).

**cond:** actual stata code, which may be the condition we want to test (rows where active = 1) or the code the user wishes to run prior to assessing the conditions (rows where active = 2). Please note that the code for every row where active = 2 is run first, and only then are the checks performed.

**delta:** margin of error that may be specified by the user in quantitative checks. As an example, it does not make sense to specify a value for delta for check *auto_5*. Any value is acceptable. In our example, we specify a margin of error of 1 for checks *auto_1* and *auto_4*

**misstozero:** sets missing values as zeros for all variables in the check if applicable. Again, this option should only be used with quantitative checks. In order to activate this option, the user must input 1 in this column. Take *auto_1* as an example. In this check, missing values of variable *price* will be set as 0.

**list_val:** number of the largest inconsistencies (absolute value) listed in the html file. Requires that the user specifies the option *listinc*. Should only be used with quantitative checks. In checks *auto_1*, *auto_3* and *auto_4*, 5 (max) of the largest inconsistent values will be listed in the html file.

**ignoremiss:** ignores rows where one of the variables is missing. These rows will be considered consistent values. In order to activate this option, the user must input 1 in this column. Should not be combined with **misstozero**. In check *auto_4*, rows where variable *price* or variable *mpbyf* is missing are automatically ignored, meaning they are in practice consistent values.

**ignore:** a more general case than **ignoremiss**, ignores rows where the condition, which is valid Stata code, is true. For example, imagine that we are testing if A equals B for panel data between 2000 and 2010, but we only want to find differences after 2005. Then, we would simply input the following condition in this field: *date_var* <= 2005. It looks counter intuitive, but remember that this is not an if condition. We are ignoring observations before 2006 or, to be more precise, considering this observations to be consistent values.
