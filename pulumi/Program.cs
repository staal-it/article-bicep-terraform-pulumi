using Pulumi.AzureNative.Resources;
using System.Collections.Generic;

return await Pulumi.Deployment.RunAsync(() =>
{
    var resourceGroup = new ResourceGroup("rg-pulumi-article");

    var app = new AppService("pulumi-article", new AppServiceArgs
    {
        ResourceGroupName = resourceGroup.Name
    });

    return new Dictionary<string, object?>
    {
        ["AppServiceEndpoint"] = app.AppServiceEndpoint
    };
});