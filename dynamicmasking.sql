use masksmalldb
ALTER TABLE dbo.Customer  
ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",0)');
CREATE USER [devlogin] FOR LOGIN [devlogin]
GRANT SELECT ON dbo.customer TO devlogin;
