#!/usr/bin/env bash

export PROMETHEUS_SERVER=$(kubectl -n prometheus get svc prometheus-server -o jsonpath="{.spec.clusterIP}")

export LOKI_SERVER=$(kubectl -n loki get svc loki-gateway -o jsonpath="{.spec.clusterIP}")

sed -i "s/PROMETHEUS_SERVER/$PROMETHEUS_SERVER/g" charts/grafana/value.yml
sed -i "s/LOKI_SERVER/$LOKI_SERVER/g" charts/grafana/value.yml

helm upgrade --install \
  --wait \
  --create-namespace \
  --namespace grafana \
  --repo https://grafana.github.io/helm-charts \
  --values ./charts/grafana/value.yml \
  grafana grafana 


sed -i "s/$PROMETHEUS_SERVER/PROMETHEUS_SERVER/g" charts/grafana/value.yml
sed -i "s/$LOKI_SERVER/LOKI_SERVER/g" charts/grafana/value.yml
