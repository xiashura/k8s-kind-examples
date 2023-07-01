#!/usr/bin/env bash

export LOKI_SERVER=$(kubectl -n loki get svc loki-gateway -o jsonpath="{.spec.clusterIP}")

sed -i "s/LOKI_SERVER/$LOKI_SERVER/g" charts/promtail/value.yml

helm upgrade \
  --install \
  --wait \
  --create-namespace \
  --namespace promtail \
  --repo https://grafana.github.io/helm-charts \
  --values ./charts/promtail/value.yml \
  promtail promtail 


sed -i "s/$LOKI_SERVER/LOKI_SERVER/g" charts/promtail/value.yml