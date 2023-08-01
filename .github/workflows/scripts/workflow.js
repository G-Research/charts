module.exports = async ({ core, context, fetch }, token) => {
  const { Octokit } = require("@octokit/core")
  const octokit = new Octokit({ auth: token, request: { fetch: fetch } });

  const owner = 'G-Research'
  const repo = 'charts'
  const ref = 'master'
  const workflow_name = 'Push'
  let version = context.payload.workflow_run.head_branch || context.payload.ref
  if (context.payload.workflow_run.head_branch) {
    version = `refs/tags/${version}`;
  }
  core.notice(`Version: ${version}`)

  const { data: repo_workflows } = await octokit.request('GET /repos/{owner}/{repo}/actions/workflows', {
    owner: owner,
    repo: repo,
  })

  let push_workflow_id = ''
  for (const workflow of repo_workflows.workflows) {
    if (workflow.name === workflow_name) {
      push_workflow_id = workflow.id
    }
  }
  if (push_workflow_id === '') {
    core.setFailed(`Unable to find workflow called "Push" on ${owner}/${repo}`)
  }

  try {
    await octokit.request('POST /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches', {
      owner: owner,
      repo: repo,
      ref: ref,
      workflow_id: push_workflow_id, // must be workflow_id
      inputs: {
        owner: context.payload.repository.owner.login,
        repo: context.payload.repository.name,
        ref: version
      },
    })

  } catch (error) {
    return core.setFailed(`Unable to trigger workflow dispatch on ${owner}/${repo}.\n${error}`)
  } finally {
    // API: https://docs.github.com/en/rest/reference/apps#revoke-an-installation-access-token
    core.notice('Revoking the token...')
    await octokit.request('DELETE /installation/token', {})
  }

}