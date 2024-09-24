<div align="center">
  <img src="https://raw.githubusercontent.com/blthazr/area0/main/docs/src/assets/k8s_logo.png" width="144px" height="144px"/>
  <img src="https://raw.githubusercontent.com/blthazr/area0/main/docs/src/assets/talos_logo.png" width="144px" height="144px"/>

### My Home Operations Repository :zap:

_powered by Talos Linux and Kubernetes_
<br>
_managed with Flux, Renovate, GitHub Actions_ 🤖
</div>

<div align="center">

[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Ftalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://talos.dev)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Fkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://kubernetes.io)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/blthazr/area0/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/blthazr/area0/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Fcluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Fcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Fcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Fcluster_pod_count&style=flat-square&label=Pods)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Fcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Memory-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fmetrics.theburnh.am%2Fcluster_memory_usage&style=flat-square&label=Memory)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;

</div>

---

## 📖 Overview
This is a mono repository for my home infrastructure, Kubernetes cluster, and apps. I try to adhere to Infrastructure as Code (IaC) and GitOps practices using tools like [Ansible](https://www.ansible.com/), [Terraform](https://www.terraform.io/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate), and [GitHub Actions](https://github.com/features/actions).

### Directories

The structure of the repo is as follows:

```sh
📁 .github
📁 .taskfiles
📁 .vscode
📁 infrastructure
├── 📁 ansible        # ansible components
└── 📁 config         # infrastructure configuration
└── 📁 talos          # talos configuration
└── 📁 terraform      # terraform components
📁 kubernetes
├── 📁 apps           # applications
├── 📁 bootstrap      # bootstrap procedures
├── 📁 flux           # core flux configuration
└── 📁 templates      # re-useable components
```
