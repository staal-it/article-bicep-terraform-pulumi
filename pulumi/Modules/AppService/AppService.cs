using System.Collections.Generic;
using Pulumi;
using Pulumi.AzureNative.Web;
using Pulumi.AzureNative.Web.Inputs;

class AppService : Pulumi.ComponentResource
{

    [Output("AppServiceEndpoint")]
    public Output<string> AppServiceEndpoint { get; private set; }

    public AppService(string name, AppServiceArgs args, ComponentResourceOptions? opts = null)
        : base("azure:custom:appservice", name, opts)
    {
        var appServicePlan = new AppServicePlan($"asp-{name}", new AppServicePlanArgs
        {
            ResourceGroupName = args.ResourceGroupName,
            Kind = "App",
            Sku = new SkuDescriptionArgs
            {
                Tier = "Basic",
                Name = "B1",
            },
        }, new Pulumi.CustomResourceOptions { Parent = this });

        var app = new WebApp($"app-{name}", new WebAppArgs
        {
            ResourceGroupName = args.ResourceGroupName,
            ServerFarmId = appServicePlan.Id
        }, new Pulumi.CustomResourceOptions { Parent = this });

        AppServiceEndpoint = app.DefaultHostName;

        var domainVerification = new Pulumi.Cloudflare.Record("domain-verification", new Pulumi.Cloudflare.RecordArgs
        {
            Name = "asuid.pulumi-demo.staal-it.nl",
            ZoneId = "72e0e6d795ec809b9158033c4a4c73d3",
            Type = "TXT",
            Value = app.CustomDomainVerificationId,
            Ttl = 3600,
        }, new Pulumi.CustomResourceOptions { Parent = this });

        var record = new Pulumi.Cloudflare.Record("record", new Pulumi.Cloudflare.RecordArgs
        {
            Name = "pulumi-demo",
            ZoneId = "72e0e6d795ec809b9158033c4a4c73d3",
            Type = "CNAME",
            Value = app.DefaultHostName,
            Ttl = 3600,
        }, new Pulumi.CustomResourceOptions { Parent = this });


        var exampleCustomHostnameBinding = new WebAppHostNameBinding("exampleCustomHostnameBinding", new()
        {
            HostName = "pulumi-demo.staal-it.nl",
            Name = app.Name,
            ResourceGroupName = args.ResourceGroupName,
        }, new CustomResourceOptions { DependsOn = { domainVerification, record }, Parent = this });

        this.RegisterOutputs();
    }
}