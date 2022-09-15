# development / testing with HashiCorp Vault.

## Requirements:

Based on the github modules located here:

https://github.com/TerryHowe/ansible-modules-hashivault


## Quick Start

1) Generate a SSH keypair, named ```id_ed25519_tf_acg``` and ensure the pair is available in your home directory .ssh. IE:\
```/home/<your_username/.ssh/id_ed25519_tf_acg``` and\
```/home/<your_username/.ssh/id_ed25519_tf_acg.pub```

2) Install Ansible Modules Hashivault from above github repo:
```pip install ansible-modules-hashivault```

3) Install sshuttle (assuming Debian/Ubuntu based distribution)
```sudo apt install sshuttle```

4) Deploy resources to AWS via Terraform.  Assumes you have an AWS account to launch to.  This was built with
temporary sandboxes via acloudguru.com.
Under the terraform/ directory execute:\
```terraform init```\
```terraform plan```\
```terraform apply```

5) connect to the EC2 instance via poor man's VPN - sshuttle with the login script located under terraform/ directory
```./connect.sh```

6) deploy ansible roles from the ansible/ directory
```./deploy.sh```


### Notes:

These are horrible practices here.  Not meant for production at all.  (unseal and root tokens saved to local disk)

This is meant purely to learn/practice with vault with an ephemeral instance.  (an alternative, use dev mode locally to practice with HashiCorp Vault)
