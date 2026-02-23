# Script Kitties Club House
This is a repository to simplify the process of deploying a series of docker containers serving applications with a common identity provider. All applications are served behind a Traefik reverse proxy and use OAuth2 to authenticate users, which are managed by Keycloak.

## Usage

To use this repository, follow these steps:

1. Clone the repository and cd into the directory.
2. Configure the environment variables in the novops folder. Some external API/credential requirements worth noting:
    * 2.1. [traefik.yml](novops/stages/prod/traefik.yml)
      * TRAEFIK_ACME_dns_api_secret: Cloudflare API key for DNS/acme challenges.
    * 2.2. [smtp_settings.yml](novops/stages/prod/smtp_settings.yml)
      * SMTP_USERNAME/SMTP_PASSWORD: login information for SMTP service.
3. Modify the [tofu_variables.auto.tfvars.json](tofu_variables.auto.tfvars.json) file to suit your needs if you would like to integrate other services behind the reverse proxy. See the [variables.tofu](services/auth/identity/keycloak_configuration_tofu/tofu_modules/variables.tofu) file for a list of variables.
4. If wanting to deploy with the `prod` environment, set the environment variable STAGE=prod: `export STAGE=prod`
5. Load Novops secrets in shell from Bitwarden using the nix flake: `nix develop`. Enter your Bitwarden password when prompted.
6. Deploy the stack using make: `make deploy`. Use `make help` for other commands.
