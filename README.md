# bicep-shoten16
This repository has source code of the documents written by zukakosan in the Book 'Azure Mix Book' sold at '技術書展 16'.

# deployment procedure

You can deploy the bicep file by following the steps bellow.
```bash
// create resource group
$ az group create -n <RESOURCE_GROUP_NAME> -l <LOCATION>

// deploy bicep template
$ az deployment group create -g <RESOURCE_GROUP_NAME> --template-file <PATH_TO_TEMPLATE> [--parameters <PATH_TO_PARAMETER_FILE>]
```