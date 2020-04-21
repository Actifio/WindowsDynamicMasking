# Windows Dynamic Data Masking


In Microsoft SQL 2016 there is a function called Dynamic Data Masking. Details can be found here:

https://docs.microsoft.com/en-us/sql/relational-databases/security/dynamic-data-masking?view=sql-server-ver15


Once set, then unprivileged users will only be shown masked data, although the underlying data inside the database remains unchanged.

This is different to DataVeil for example that changes the actual data in the DB itself.

Lets say we have a database masksmalldb in which there is a table called dbo.customer with a column called LastName

We do a select and see the data:


**select LastName from dbo.customer**
```
LastName
Kraft
Taylor
Johnson
Howard
Robertson
Kraft
Taylor
Johnson
Howard
Robertson
Kraft
```

We now set a mask on that column

```
ALTER TABLE dbo.Customer  
ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",0)');
```

We now query using an unprivileged user:


**CREATE USER testuser1 WITHOUT LOGIN;**  
**GRANT SELECT ON dbo.customer TO testuser1;**
**EXECUTE AS USER = 'testuser1';**
**SELECT LastName FROM dbo.customer;**  
**REVERT;**
```
LastName
KrXXX
TaXXX
JoXXX
HoXXX
RoXXX
KrXXX
TaXXX
JoXXX
HoXXX
RoXXX
KrXXX
```

We can automate this in a workflow by taking the following steps:

1)  For this example we create a LOGIN for devusers in SQL Server.  
This Login has access to no DBs and has no priviledges in itself.
It is there to attach a database user.   
In this example it is called 'devlogin'

![Image of devlogin creation](https://github.com/Actifio/WindowsDynamicMasking/blob/master/Images/Login.jpg)


2)  We install datamasking.bat into C:\Program Files\Actifio\scripts

The only main modification needed is to change the path name to sqlcmd.exe
You can learn the correct path with the 'where' command like this:

```
C:\Users\av>where sqlcmd.exe
C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\SQLCMD.EXE
```
The bat file also references a SQL script so if you change the name of that script that also needs to be updated.
We could also pass the name of that script down to the Connector via the workflow

3)  We install a SQL script file into C:\Program Files\Actifio\scripts
This contains our masking commands.
In this example we connect to a database called masksmalldb, we alter the table dbo.Customer to mask the column LastName.
We then add a database user devlogin that uses the devlogin login.   We then allow that database user to perform selects on dbo.customer

```
use masksmalldb;
ALTER TABLE dbo.Customer;  
ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",0)');
CREATE USER [devlogin] FOR LOGIN [devlogin]
GRANT SELECT ON dbo.customer TO devlogin;
```

4)  We now create a workflow that calls the bat file created in step two.
In this example we create an OnDemand DirectMount worklow that calls a bat file called dynamicmask.bat

![Image of workflow creation](https://github.com/Actifio/WindowsDynamicMasking/blob/master/Images/workflow.jpg)

5)  We now run the workflow.  A new virtual database is created.  


6)  To test we first login to SQL Management Studio as a fully priviledged user and we can see two tables and all the data in our new virtual Database.

![Image of all data](https://github.com/Actifio/WindowsDynamicMasking/blob/master/Images/fulluserview.jpg)

We then login as devlogin.  Note this uses SQLServer Authentication which needs to be allowed.

![Image of SQL Login](https://github.com/Actifio/WindowsDynamicMasking/blob/master/Images/SQLLogin.jpg)

Looking at the same Virtual database, we can see only one table and the contents of that are partially masked as per rule:

![Image of mask data](https://github.com/Actifio/WindowsDynamicMasking/blob/master/Images/devuserview.jpg)
