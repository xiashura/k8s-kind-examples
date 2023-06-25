
helm upgrade --install \
  --wait \
  --create-namespace \
  --namespace loki \
  --repo https://grafana.github.io/helm-charts \
  --values ./charts/loki/value.yml loki loki 