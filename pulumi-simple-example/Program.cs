using Pulumi;
using Pulumi.AzureNative.Resources;
using Pulumi.AzureNative.Storage;
using Pulumi.AzureNative.Storage.Inputs;
using System.Collections.Generic;

return await Pulumi.Deployment.RunAsync(() =>
{
    var config = new Pulumi.Config();

    // Create an Azure resource (Storage Account)
    var storageAccount = new StorageAccount(config.Get("storageAccountName"), new StorageAccountArgs
    {
        ResourceGroupName = config.Get("resourceGroupName"),
        Sku = new SkuArgs
        {
            Name = SkuName.Standard_LRS
        },
        Kind = Kind.StorageV2
    });

    // Export the primary key of the Storage Account
    return new Dictionary<string, object?>
    {
        ["storageId"] = storageAccount.Id
    };
});