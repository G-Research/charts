module.exports = async ({ core, exec, context }, token) => {
  const { Octokit } = require("@octokit/core")
  const octokit = new Octokit({ auth: token })
  const checkoutPageDir = "gh-pages"
  const helm = {
    owner: process.env.OWNER,
    repo: process.env.REPO,
    ref: process.env.REF,
    charts: JSON.parse(process.env.CHARTS)
  }

  const headerToken_b64 = Buffer.from(`x-access-token:${token}`).toString('base64')
  core.setSecret(headerToken_b64)

  try {
    // Verify status and set git config
    await exec.exec('git', ['remote', '-v'], { cwd: checkoutPageDir })
    await exec.exec('git', ['status'], { cwd: checkoutPageDir })
    await exec.exec('git', ['config', '--local', '--unset-all', 'http.https://github.com/.extraheader'], { cwd: checkoutPageDir })
    await exec.exec('git', ['config', '--local', 'http.https://github.com/.extraheader', `AUTHORIZATION: basic ${headerToken_b64}`], { cwd: checkoutPageDir })
    await exec.exec('git', ['config', '--local', 'user.name', 'G-Research charts'], { cwd: checkoutPageDir })
    await exec.exec('git', ['config', '--local', 'user.email', 'charts@gr-oss.io'], { cwd: checkoutPageDir })

    // Update index and stage charts
    await exec.exec('helm', ['repo', 'index', '.'], { cwd: checkoutPageDir })
    await exec.exec('git', ['add', 'index.yaml'], { cwd: checkoutPageDir })

    // Commit and push files
    await exec.exec('git', ['status'], { cwd: checkoutPageDir })
    await exec.exec('git', ['commit', '-m', `Publish helm chart to ${context.payload.repository.owner.login}/${context.payload.repository.name}`, '--verbose'], { cwd: checkoutPageDir }) 
    await exec.exec('git', ['push', 'origin', checkoutPageDir, '--verbose'], { cwd: checkoutPageDir })
  } catch (error) {
    return core.setFailed(`Unable to push ${checkoutPageDir}/${helm.charts.destination} to ljubon/charts@${checkoutPageDir}\nError: ${error}`)
  } finally {
    // API: https://docs.github.com/en/rest/reference/apps#revoke-an-installation-access-token
    console.log(`Revoking the token...`)
    await octokit.request('DELETE /installation/token', {})  }
}
