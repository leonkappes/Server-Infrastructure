[masters]
%{ for ip in masters ~}
${ip}
%{ endfor ~}

[nodes]
%{ for ip in nodes ~}
${ip}
%{ endfor ~}