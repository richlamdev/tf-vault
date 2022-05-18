resource "local_file" "inventory" {
  filename = "connect.sh"
  content  = <<EOF
sshuttle -r ec2-user@${aws_instance.public_test[0].public_dns} 10.0.0.0/16 --ssh-cmd 'ssh -i ~/.ssh/id_ed25519_tf_acg -o StrictHostKeyChecking=no' -v $@
EOF
}
#${aws_instance.public_test[0].public_dns}
#${aws_instance.public_test[1].public_dns}
########################### OUTPUT INVENTORY FOR ANSIBLE #########

########################### HOSTS FILE FOR EACH INSTANCE #########

#resource "local_file" "hosts_append" {
#filename = "../ansible/dnshosts/hosts_append"
#content  = <<EOF
#local-data: "syslog-0.tatooine.test.         IN        A      ${aws_instance.public_test[0].private_ip}"
#local-data: "syslog-1.tatooine.test.         IN        A      ${aws_instance.public_test[1].private_ip}"
#local-data: "dns.tatooine.test.              IN        A      ${aws_instance.public_test[2].private_ip}"
#local-data: "client.tatooine.test.           IN        A      ${aws_instance.public_test[3].private_ip}"
#local-data: "mirror.tatooine.test.           IN        A      ${aws_instance.public_test[4].private_ip}"
#
#local-data-ptr: "${aws_instance.public_test[0].private_ip}            syslog-0.tatooine.test."
#local-data-ptr: "${aws_instance.public_test[1].private_ip}            syslog-1.tatooine.test."
#local-data-ptr: "${aws_instance.public_test[2].private_ip}            dns.tatooine.test."
#local-data-ptr: "${aws_instance.public_test[3].private_ip}            client.tatooine.test."
#local-data-ptr: "${aws_instance.public_test[4].private_ip}            mirror.tatooine.test."
#EOF
#}

########################### CREATE ANSIBLE VARS FILE ##############
#resource "local_file" "ansible_vars" {
  #filename = "../ansible/tf_ansible_vars/ansible_vars.yml"
  #content  = <<EOF
#syslog_0: ${aws_instance.public_test[0].private_ip}
#syslog_1: ${aws_instance.public_test[1].private_ip}
#dns: ${aws_instance.public_test[2].private_ip}
#client: ${aws_instance.public_test[3].private_ip}
#mirror: ${aws_instance.public_test[4].private_ip}
#
#EOF
#}
########################### CREATE ANSIBLE VARS FILE ##############
