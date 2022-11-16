module.exports = async ({ core }, owner, repo, tokenPermissions) => {
  const { App } = require("octokit")
  const app = new App({
    appId: process.env.APP_ID,
    privateKey: process.env.APP_PRIVATE_KEY,
  })

  const permissions = (tokenPermissions === undefined) ? {
    actions: "read",
  } : tokenPermissions

  for await (const { data: installations } of app.octokit.paginate.iterator(
    app.octokit.rest.apps.listInstallations
  )) {
    for (const installation of installations) {
      if (installation.account.login === owner) {
        const octokit = await app.getInstallationOctokit(installation.id)
        try {
          // https://docs.github.com/en/rest/reference/apps#create-an-installation-access-token-for-an-app
          const { data: response } = await octokit.request('POST /app/installations/{installation_id}/access_tokens', {
            installation_id: installation.id,
            repositories: [`${repo}`],
            permissions: permissions
          })
          core.debug(`Response: ${JSON.stringify(response)}`)
          return response.token

        } catch (error) {
          return core.setFailed(`Unable to generate token for ${owner}/${repo}\nPermission: ${JSON.stringify(permissions)}\n${error}`)
        }

      }
    }
  }
}