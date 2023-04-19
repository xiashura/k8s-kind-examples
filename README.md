

### Setup cluster 
Before need exec to dev-shell and install requirements only docker
```bash
nix-shell
```
#### Create cluster
Then you can chose clusters multi or single master nodes </br>
create multi master nodes cluster 
``` bash
kind-cluster-multi-install
```
create single master node cluster 
```bash
kind-cluster-single-install
```
#### Install charts 
```bash
init-cilium
init-metallb
init-nginx
update-cilium
```
