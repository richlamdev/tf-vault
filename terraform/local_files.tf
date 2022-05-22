################## Create connection file via sshuttle #####################

resource "local_file" "sshuttle" {
  filename = "connect.sh"
  content  = <<EOF
sshuttle -r ec2-user@${aws_instance.public_test[0].public_dns} 10.0.0.0/16 --ssh-cmd 'ssh -i ~/.ssh/id_ed25519_tf_acg -o StrictHostKeyChecking=no' -v $@
EOF
}
################## Create connection file via sshuttle #####################

resource "local_file" "ssh_connection" {
  filename = "ssh_connect.sh"
  content  = <<EOF
ssh -i ~/.ssh/id_ed25519_tf_acg -o StrictHostKeyChecking=no ec2-user@${aws_instance.private_test[0].private_ip}
EOF
}

################### START OUTPUT INVENTORY FOR ANSIBLE ###################
resource "local_file" "inventory" {
  filename = "../ansible/inventory"
  content  = <<EOF
[vault]
${aws_instance.private_test[0].private_ip}

[multi:children]
vault

[multi:vars]
ansible_become=True
ansible_become_method=sudo
ansible_become_user=root
ansible_python_interpreter=/usr/bin/python3
EOF
}
################### END OUTPUT INVENTORY FOR ANSIBLE ###################

########################### CREATE ANSIBLE VARS FILE #######################
resource "local_file" "ansible_vars" {
  filename = "../ansible/tf_ansible_vars/ansible_vars.yml"
  content  = <<EOF
vault_ip: ${aws_instance.private_test[0].private_ip}
EOF
}
########################### CREATE ANSIBLE VARS FILE ######################
