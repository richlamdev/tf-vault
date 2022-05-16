ssh -D 8080 -C2qNf -i ~/.ssh/id_ed25519_tf_acg ec2-user@ <ec2-public-domain-name>

curl -s checkip.dyndns.org --socks5-hostname 127.0.0.1:8080 | perl -F: -lne 'print $F[1]'
