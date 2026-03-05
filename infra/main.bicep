@description('Deployment location')
param location string = 'centralus'

@description('Name for the Azure SQL logical server (must be globally unique).')
@minLength(1)
param sqlServerName string

@description('Administrator login name for the Azure SQL logical server.')
param adminLogin string

@secure()
@description('Administrator password for the Azure SQL logical server.')
param adminPassword string

@description('Database name.')
param databaseName string = 'AdventureWorksDW'

@description('SKU name for the database (ex: Basic, S0, S1, GP_S_Gen5_1).')
param skuName string = 'S1'

@description('Max database size in bytes (default 5GB).')
param maxSizeBytes int = 5368709120

@description('Optional client IPv4 address to allow (e.g. 203.0.113.10). Leave blank to skip creating this firewall rule.')
param clientIp string = ''

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
  }
}

resource db 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    maxSizeBytes: maxSizeBytes
    sampleName: 'AdventureWorksLT'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
  }
}

resource fwAllowAll 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource fwClient 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = if (!empty(clientIp)) {
  parent: sqlServer
  name: 'ClientIp'
  properties: {
    startIpAddress: clientIp
    endIpAddress: clientIp
  }
}

output sqlServerFqdn string = '${sqlServerName}.database.windows.net'
output database string = db.name
output adminUser string = adminLogin
