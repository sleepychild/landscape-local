# landscape-local
Bosh managed virtual landscape.

## Bosh director 

### Deployment steps

```bash
cd bosh
source .bosh_logging_rc ### If you need to enable logging for bosh
./create-env.sh
./set-route-to-env.sh
./alias-env.sh

```
