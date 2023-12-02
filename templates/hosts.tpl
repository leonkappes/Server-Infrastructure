[masters]
%{ for ip in masters ~}
${ip}
%{ endfor ~}

[nodes]
%{ for ip in nodes ~}
${ip}
%{ endfor ~}

[k3s_cluster:children]
masters
nodes