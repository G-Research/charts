## Install

With Quickstart values:

```bash
helm repo add gresearch https://g-research.github.io/charts
kubectl create namespace siembol
helm upgrade --install siembol -n siembol -f https://raw.githubusercontent.com/G-Research/charts/0ac159d72a4fe842e3034834c3e8a9f7a5b47989/src/siembol/quickstart-values.yaml gresearch/siembol
```