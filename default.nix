with (import <nixpkgs> { });
let
  kind-cluster-multi-install =
    pkgs.writeShellScriptBin "kind-cluster-multi-install" ''
      kind create cluster --name=k8s-multi-metallb-ingress \
        --config=clusters/kind-multi-master-nodes.yml
    '';

  kind-cluster-single-install =
    pkgs.writeShellScriptBin "kind-cluster-single-install" ''
      kind create cluster --name=k8s-single-metallb-ingress \
        --config=clusters/kind-single-master-node.yml
    '';

  init-cilium = pkgs.writeShellScriptBin "init-cilium" ''
    source env/kind.env
    sed -i "s/KIND_LOAD_BALANCER/$KIND_LOAD_BALANCER/g" charts/cilium/value.yml
    helm upgrade --install --namespace kube-system \
      --repo https://helm.cilium.io cilium cilium \
      --values charts/cilium/value.yml
    sed -i "s/$KIND_LOAD_BALANCER/KIND_LOAD_BALANCER/g" charts/cilium/value.yml
    cilium status --wait
  '';

  init-metallb = pkgs.writeShellScriptBin "init-metallb" ''
        source env/kind.env
        source env/metallb.env
        helm upgrade --install --wait --namespace metallb-system --create-namespace --repo https://metallb.github.io/metallb metallb metallb
        kubectl apply -f - << EOF
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: example
      namespace: metallb-system
    spec:
      addresses:
      - $METALLB_IP_RANGE
    ---
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: empty
      namespace: metallb-system
    EOF
  '';

  init-nginx = pkgs.writeShellScriptBin "init-nginx" ''
    helm upgrade --install --wait --namespace ingress-nginx \
    --create-namespace --repo https://kubernetes.github.io/ingress-nginx \
    ingress-nginx ingress-nginx --values charts/ingress-nginx/value.yml
  '';

  update-cilium = pkgs.writeShellScriptBin "update-cilium" ''
      source env/lb.env
      helm upgrade --namespace kube-system \
        --repo https://helm.cilium.io cilium cilium --reuse-values \
        --values - <<EOF
    hubble:
      ui:
        enabled: true
        ingress:
          enabled: true
          annotations:
            kubernetes.io/ingress.class: nginx
          hosts:
            - hubble-ui.$LB_IP.nip.io
    EOF
  '';

  kind-clusters-delete = pkgs.writeShellScriptBin "kind-cluster-delete" ''
    kind delete clusters k8s-multi-metallb-ingress 
    kind delete clusters  k8s-single-metallb-ingress
  '';

in stdenv.mkDerivation {

  KUBECONFIG = "config.yml";

  name = "k8s-metallb-ingress";
  buildInputs = [
    kind
    terraform
    kubectl
    cilium-cli
    kubernetes-helm-wrapped
    kind-cluster-multi-install
    kind-cluster-single-install
    init-cilium
    init-metallb
    init-nginx
    update-cilium
    kind-clusters-delete
  ];
}
