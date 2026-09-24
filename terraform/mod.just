set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[doc('Initialize a Terraform stack')]
init stack:
    cd "{{ source_directory() }}/{{ stack }}" && terraform init

[doc('Show the plan for a Terraform stack')]
plan stack:
    cd "{{ source_directory() }}/{{ stack }}" && terraform plan

[confirm('Apply Terraform changes for ' + stack + ' [y|N] ?')]
[doc('Apply a Terraform stack')]
apply stack:
    cd "{{ source_directory() }}/{{ stack }}" && terraform apply
