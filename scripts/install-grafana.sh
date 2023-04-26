#!/usr/bin/env bash

helm upgrade --install \
  --wait \
  --create-namespace \
  --namespace grafana \
  --repo https://grafana.github.io/helm-charts \
  --values ./charts/grafana/value.yml \ 
  grafana grafana 