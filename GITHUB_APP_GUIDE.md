# Create GitHub App

### Required CLI tools
  - `smallstep` [link](https://smallstep.com/docs/step-cli/installation)
  - `jq` [link](https://stedolan.github.io/jq/download/)
  - `curl` 

## Create GitHub App

1. Go to your profile / organization settings by clicking to the link below:

   - Organization https://github.com/organizations/ORG_NAME/settings/apps
     - Replace `ORG_NAME` with the name of your organization
   - Personal https://github.com/settings/apps

2. Click to `New GitHub App`
3. Set the name for your GitHub App (e.g. push-bot)
4. As we don't host your app set `http://example.com` for `Homepage URL`
5. Disable `Webhook` by unchecking `Active` button
6. Change following permissions

   - Repository permissions
     - `Actions` => Read & Write
     - `Contents ` => Read-only
     - `Metadata ` => Read-only
     - `Secrets ` => Read-only
     - `Pages` => Read-only
   - Organization permissions
     - `No access` for allgit 
   - User permissions
     - `No access` for all

7. For option `Where can this GitHub App be installed` please select `Only on this account`
8. At the end click to `Create GitHub app`

## Install app and generate private key

1. Go to https://github.com/settings/apps/APP_NAME
   - replace `APP_NAME` at the end of URL with your GitHub app name (e.g. push-bot)
   - this will be your `GitHub app settings page`
2. Go to section `Private keys` and click `Generate a private key`
   - your browser will automatically download `*.pem` file for your app
   - save it locally
3. Go to `Install App` tab in your GitHub application navigation.
4. Click to `Install`
   - We strongly suggest giving access to your app only to repositories it will use - Click `Only select repositories` option after which you will select repositories
   - `All repositories` will apply to all current and future repositories

## Enable workflow authentication

1. Go to `Install App` tab in your GitHub application navigation
2. Generating secrets for the workflow

   - Go to `Install App` tab in your GitHub application navigation.
   - Save/copy `App ID` (e.g. 175388)
   - Open your terminal and go to a folder where you saved your `pem` file (10th step)
   - Run following commands

     ```
     APP_ID=<APP_ID> # App ID you copied step earlier
     PEM_PATH=<PEM_ABSOLUTE_PATH> # absolute location of PEM file for your app

     APP_TOKEN=$(step crypto jwt sign --key $PEM_PATH --issuer $APP_ID --expiration $(date --date '+5 min' +'%s') --subtle </dev/null)

     curl -s -X GET -H "Authorization: Bearer $APP_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app/installations | jq '.[].id'
     ```

     **Last command will produce 8 digit number which is called Installation ID**

3. Final step

   - We strongly recommend to save `APP_ID`, `PEM` file (content of the pem file) and `INSTALLADION_ID` to your repositories as secrets.

   _Once they are added as secrets you can just use them with `${{ secrets.APP_ID }}` syntax_

### Summary:

- With a .pem file we can generate valid token which will be used as authentication for your application
- Got `APP_ID` from step 14
- Got `INSTALLADION_ID` which will be used to authenticate and run actions/jobs as your GitHub app
- We strongly recommend to save `APP_ID`, `PEM` file (content of the pem file) and `INSTALLADION_ID` to your repositories as secrets.
