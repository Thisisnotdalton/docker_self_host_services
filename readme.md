# Script Kitties Club House
This is a repository to simplify the process of deploying a series of docker containers serving applications with a common identity provider. All applications are served behind a Traefik reverse proxy and use OAuth2 to authenticate users, which managed by Keycloak.

## Usage

To use this repository, follow these steps:

1. Clone the repository
2. Configure the environment variables in the novops folder:
    * 2.1. [traefik.yml](novops/stages/prod/traefik.yml)
    * 2.2. [keycloak.yml](novops/stages/prod/keycloak.yml)
    * 2.3. [oauth2_proxy.yml](novops/stages/prod/oauth2_proxy.yml)
    * 2.4. [smtp_settings.yml](novops/stages/prod/smtp_settings.yml)
    * 2.5. [vaultwarden.yml](novops/stages/prod/vaultwarden.yml)
3. Modify the tof_variables.auto.tfvars file to suit your needs if you would like to integrate other services behind the reverse proxy. See the [variables.tofu](services/auth/identity/keycloak_configuration_tofu/tofu_modules/variables.tofu) file for a list of variables.
4. Deploy the stack using make: `make deploy`. Use `make help` for other commands.
