/*
Mini AdventureWorksDW seed for Azure SQL Database.

This script creates a minimal subset of AdventureWorksDW-style tables
and loads a small amount of data so MCP tools can query something meaningful.

It is intentionally small so it runs quickly and works in Azure SQL Database.
*/

-- Dimension tables
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimCustomer (
        CustomerKey       INT            NOT NULL PRIMARY KEY,
        FirstName         NVARCHAR(50)   NOT NULL,
        LastName          NVARCHAR(50)   NOT NULL,
        EmailAddress      NVARCHAR(100)  NULL,
        City              NVARCHAR(50)   NULL,
        StateProvince     NVARCHAR(50)   NULL,
        CountryRegion     NVARCHAR(50)   NULL
    );
END

IF OBJECT_ID('dbo.DimProduct', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimProduct (
        ProductKey        INT            NOT NULL PRIMARY KEY,
        EnglishProductName NVARCHAR(100) NOT NULL,
        Color             NVARCHAR(20)   NULL,
        Size              NVARCHAR(10)   NULL,
        StandardCost      DECIMAL(18,2)  NOT NULL,
        ListPrice         DECIMAL(18,2)  NOT NULL,
        ProductSubcategory NVARCHAR(100) NULL,
        ProductCategory    NVARCHAR(100) NULL
    );
END

IF OBJECT_ID('dbo.DimDate', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimDate (
        DateKey           INT           NOT NULL PRIMARY KEY,  -- YYYYMMDD
        FullDateAlternateKey DATE       NOT NULL,
        CalendarYear      INT           NOT NULL,
        CalendarQuarter   INT           NOT NULL,
        MonthNumberOfYear INT           NOT NULL,
        EnglishMonthName  NVARCHAR(20)  NOT NULL
    );
END

-- Fact table
IF OBJECT_ID('dbo.FactInternetSales', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactInternetSales (
        SalesOrderNumber  NVARCHAR(20)  NOT NULL,
        SalesOrderLineNumber INT        NOT NULL,
        OrderDateKey      INT           NOT NULL,
        CustomerKey       INT           NOT NULL,
        ProductKey        INT           NOT NULL,
        OrderQuantity     INT           NOT NULL,
        UnitPrice         DECIMAL(18,2) NOT NULL,
        SalesAmount       DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_FactInternetSales PRIMARY KEY (SalesOrderNumber, SalesOrderLineNumber),
        CONSTRAINT FK_FIS_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES dbo.DimCustomer(CustomerKey),
        CONSTRAINT FK_FIS_DimProduct  FOREIGN KEY (ProductKey) REFERENCES dbo.DimProduct(ProductKey),
        CONSTRAINT FK_FIS_DimDate     FOREIGN KEY (OrderDateKey) REFERENCES dbo.DimDate(DateKey)
    );
END

-- Idempotent seed (only insert if empty)
IF NOT EXISTS (SELECT 1 FROM dbo.DimCustomer)
BEGIN
    INSERT INTO dbo.DimCustomer (CustomerKey, FirstName, LastName, EmailAddress, City, StateProvince, CountryRegion)
    VALUES
    (11000,'Jon','Yang','jon.yang@adventure-works.com','Seattle','Washington','United States'),
    (11001,'Eugene','Huang','eugene.huang@adventure-works.com','Bellevue','Washington','United States'),
    (11002,'Ruben','Torres','ruben.torres@adventure-works.com','Portland','Oregon','United States'),
    (11003,'Christy','Zhu','christy.zhu@adventure-works.com','San Francisco','California','United States'),
    (11004,'Catherine','Abel','catherine.abel@adventure-works.com','Austin','Texas','United States');
END

IF NOT EXISTS (SELECT 1 FROM dbo.DimProduct)
BEGIN
    INSERT INTO dbo.DimProduct (ProductKey, EnglishProductName, Color, Size, StandardCost, ListPrice, ProductSubcategory, ProductCategory)
    VALUES
    (214,'Long-Sleeve Logo Jersey','Red','M',27.25,49.99,'Jerseys','Clothing'),
    (215,'Long-Sleeve Logo Jersey','Blue','L',27.25,49.99,'Jerseys','Clothing'),
    (216,'Mountain Bottle Cage','Silver',NULL,2.50,4.99,'Bottles and Cages','Accessories'),
    (217,'Road Tire Tube',NULL,NULL,1.20,3.99,'Tires and Tubes','Accessories'),
    (218,'HL Mountain Frame','Black','52',136.50,249.99,'Frames','Bikes');
END

IF NOT EXISTS (SELECT 1 FROM dbo.DimDate)
BEGIN
    INSERT INTO dbo.DimDate (DateKey, FullDateAlternateKey, CalendarYear, CalendarQuarter, MonthNumberOfYear, EnglishMonthName)
    VALUES
    (20140101,'2014-01-01',2014,1,1,'January'),
    (20140215,'2014-02-15',2014,1,2,'February'),
    (20140630,'2014-06-30',2014,2,6,'June'),
    (20140704,'2014-07-04',2014,3,7,'July'),
    (20141231,'2014-12-31',2014,4,12,'December');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FactInternetSales)
BEGIN
    INSERT INTO dbo.FactInternetSales
      (SalesOrderNumber, SalesOrderLineNumber, OrderDateKey, CustomerKey, ProductKey, OrderQuantity, UnitPrice, SalesAmount)
    VALUES
      ('SO43659',1,20140101,11000,214,2,49.99,99.98),
      ('SO43659',2,20140101,11000,216,1,4.99,4.99),
      ('SO43660',1,20140215,11001,215,1,49.99,49.99),
      ('SO43661',1,20140630,11002,218,1,249.99,249.99),
      ('SO43662',1,20140704,11003,217,3,3.99,11.97),
      ('SO43663',1,20141231,11004,214,1,49.99,49.99);
END

-- Helpful indexes
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FIS_OrderDateKey' AND object_id = OBJECT_ID('dbo.FactInternetSales'))
    CREATE INDEX IX_FIS_OrderDateKey ON dbo.FactInternetSales(OrderDateKey);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FIS_CustomerKey' AND object_id = OBJECT_ID('dbo.FactInternetSales'))
    CREATE INDEX IX_FIS_CustomerKey ON dbo.FactInternetSales(CustomerKey);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FIS_ProductKey' AND object_id = OBJECT_ID('dbo.FactInternetSales'))
    CREATE INDEX IX_FIS_ProductKey ON dbo.FactInternetSales(ProductKey);
