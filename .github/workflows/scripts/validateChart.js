module.exports = async ({ core, context }) => {
  const config = new Map(Object.entries(require('./self/.github/workflows/scripts/config.json')))
  var input = (context.eventName === "workflow_dispatch") ? {
    owner: context.payload.inputs.owner,
    repo: context.payload.inputs.repo,
    ref: context.payload.inputs.ref
  } : {
    owner: context.payload.repository.owner.login,
    repo: context.payload.repository.name,
    ref: context.payload.ref
  }
  core.debug(input)

  // Verify that repo exists in the config
  const repo = Object.values(config.get(input.owner)).find(repo => repo.name === input.repo)
  if (repo === undefined) {
    return core.setFailed(`Config not found for repo ${input.owner}/${input.repo}`)
  }

  // Validate that ref is in expected format
  const validateRefs = repo.refs.some(r => {
    if (r.type === "regex") {
      const regex = new RegExp(r.ref)
      return regex.test(input.ref)
    } else if (r.type === "branch") {
      return r.ref === input.ref
    }
  })
  if (!validateRefs) {
    return core.setFailed(`Ref ${input.ref} is not allowed for repo ${input.owner}/${input.repo}`)
  }

  core.exportVariable('REPO', input.repo)
  core.exportVariable('OWNER', input.owner)
  core.exportVariable('REF', input.ref)
  core.exportVariable('CHARTS', JSON.stringify(repo.helm_charts))
}