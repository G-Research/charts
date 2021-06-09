module.exports = async ({ core, context }, token) => {
  const { Octokit } = require("@octokit/core")
  const octokit = new Octokit({ auth: token })

  const owner = `ljubon` // TODO: Change to G-Research
  const repo = `charts` // TODO: Change to charts
  const ref = `INTERNAL-master` // TODO: Change to chart's default branch (master)
  const workflow_name = `Push` // NOTE: Workflow name in chart repo must be named `Push` (push.yaml in this code)

  const { data: repo_workflows } = await octokit.request('GET /repos/{owner}/{repo}/actions/workflows', {
    owner: owner,
    repo: repo,
  })

  let push_workflow_id = ''
  for (const workflow of repo_workflows.workflows) {
    if (workflow.name == workflow_name) {
      push_workflow_id = workflow.id
    }
  }
  if (push_workflow_id == '') {
    core.setFailed(`Unable to find workflow called "Push" on ${context.payload.repository.owner.login}/${context.payload.repository.name}`)
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
        ref: context.payload.ref
      },
    })

  } catch (error) {
    return core.setFailed(`Unable to trigger workflow dispatch on ${owner}/${repo}.\n${error}`)
  } finally {
    // API: https://docs.github.com/en/rest/reference/apps#revoke-an-installation-access-token
    console.log(`Revoking the token...`)
    await octokit.request('DELETE /installation/token', {})
  }

}