# Build Azure Pipeline agent image with Packer #

Get the Microsoft Packer script here
[https://github.com/Microsoft/azure-pipelines-image-generation](https://github.com/Microsoft/azure-pipelines-image-generation)

Execute the Packer command:

```bash
packer build -var-file="linux-conf.json" <json script>
```