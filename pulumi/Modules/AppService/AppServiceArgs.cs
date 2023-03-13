using Pulumi;

public sealed class AppServiceArgs : ResourceArgs
{
    [Input("resourceGroupName", true, false)]
    public Input<string> ResourceGroupName { get; set; }
}