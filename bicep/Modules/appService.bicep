param name string
param location string
param cloudFlareToken string

var record = 'bicep-article-demo'
var domain = 'staal-it.nl'

resource appServicePlan 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: 'asp-${name}'
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: 'app-${name}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id

    siteConfig: {
      netFrameworkVersion: 'v6.0'
    }
  }
}

output webApplicationUrl string = webApplication.properties.defaultHostName

resource cloudflare 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'cloudflare'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: '1'
    azPowerShellVersion: '8.3'
    arguments: '-hostname "${record}" -domain "${domain}" -destination "${webApplication.properties.defaultHostName}"'
    environmentVariables: [
      {
        name: 'CLOUDFLARE_API_TOKEN'
        secureValue: cloudFlareToken
      }
    ]
    scriptContent: '''
      param([string] $hostname, [string] $domain, [string] $destination)

      $zoneid = "72e0e6d795ec809b9158033c4a4c73d3"
      $url = "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records"
      
      $addresses = (
          ("awverify.$hostname.$domain", "awverify.$destination"),
          ("$hostname.$domain", "$destination")
      )
      
      foreach($address in $addresses)
      {
          $name = $address[0]
          $content = $address[1]
          $token = $Env:CLOUDFLARE_API_TOKEN
      
          $existingRecord = Invoke-RestMethod -Method get -Uri "$url/?name=$name" -Headers @{
              "Authorization" = "Bearer $token"
          }
      
          if($existingRecord.result.Count -eq 0)
          {
              $Body = @{
                  "type" = "CNAME"
                  "name" = $name
                  "content" = $content
                  "ttl" = "120"
              }
              
              $Body = $Body | ConvertTo-Json -Depth 10
              $result = Invoke-RestMethod -Method Post -Uri $url -Headers @{ "Authorization" = "Bearer $token" } -Body $Body -ContentType "application/json"
              
              Write-Output $result.result
          }
          else 
          {
              Write-Output "Record already exists"
          }
      }    
    '''
    supportingScriptUris: []
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

resource hostName 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  name: '${record}.${domain}'
  parent: webApplication

  dependsOn: [
    cloudflare
  ]
}
