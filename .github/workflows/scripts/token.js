module.exports = async ({ core, fetch }, owner, repo, tokenPermissions) => {
  const { Octokit } = await import("@octokit/core");
  const { createAppAuth } = await import("@octokit/auth-app");

  const permissions = tokenPermissions === undefined
    ? { actions: "read" }
    : tokenPermissions;

  try {
    // Get all installations accessible to the app
    const octokit = new Octokit({
      authStrategy: createAppAuth,
      auth: {
        appId: process.env.APP_ID,
        privateKey: process.env.APP_PRIVATE_KEY,
      },
      request: { fetch: fetch } // Pass the 'fetch' function here as well
    });

    const { data: installations } = await octokit.request("GET /app/installations");

    for (const installation of installations) {
      if (installation.account.login === owner) {
        // Use the app's JWT to authenticate as the app
        const appOctokit = new Octokit({
          authStrategy: createAppAuth,
          auth: {
            appId: process.env.APP_ID,
            privateKey: process.env.APP_PRIVATE_KEY,
            installationId: installation.id,
          },
          request: { fetch: fetch }
        });

        try {
          // Create an installation access token for the app
          // https://docs.github.com/en/rest/reference/apps#create-an-installation-access-token-for-an-app
          const { data: response } = await appOctokit.request('POST /app/installations/{installation_id}/access_tokens', {
            installation_id: installation.id,
            repositories: [`${repo}`],
            permissions: permissions
          });

          core.debug(`Response: ${JSON.stringify(response)}`);
          return response.token;

        } catch (error) {
          return core.setFailed(`Unable to generate token for ${owner}/${repo}\nPermission: ${JSON.stringify(permissions)}\n${error}`);
        }
      }
    }
  } catch (error) {
    return core.setFailed(`Error retrieving installations for ${owner}/${repo}\n${error}`);
  }
}
