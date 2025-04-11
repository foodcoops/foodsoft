
After opening the workspace, follow these steps to complete the setup:

1. Login using the default credentials: `admin/secret`

1. Change the admin password, just in case.

1. Optionally, load an initial database (here seeded with `small.en`) by running

```
    docker-compose -f docker-compose-dev.yml run --rm foodsoft \
      bundle exec rake db:schema:load db:seed:small.en
```

> Note: The gitpod env is setup to open the front-ends using a preview browser built into the workspace. You can also open these in browser tabs by clicking the icon next to address bar. Refer gitpod.io docs about [whitelisting workspaces](https://www.gitpod.io/docs/configure/browser-settings#browser-settings) to prevent pop-up blockers from blocking these tabs.

The main configuration of the Gitpod workspace is in [/.gippod.yml](/.gitpod.yml). Check out https://www.gitpod.io/docs/config-gitpod-file for more information. 
