\# Variables Terraform requises



Avant d'exécuter `terraform plan` ou `terraform apply`, définir les variables suivantes :



```bash

export TF\_VAR\_namespace="wordpress"

export TF\_VAR\_db\_username="admin"

read -rsp "Mot de passe RDS : " TF\_VAR\_db\_password

echo

export TF\_VAR\_db\_password

```



Le mot de passe est saisi de manière masquée et n'est pas enregistré dans le dépôt.

