module.exports = async ({ core, context }) => {
  const source = new Map(Object.entries(require('./config.json')))
  var input = (context.eventName == "workflow_dispatch") ? {
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
  const repo = Object.values(source.get(input.owner)).find(source => source.name == input.repo)
  if (!repo) {
    return core.setFailed(`Config not found for source ${input.owner}/${input.repo} with ref ${input.ref}`)
  }

  // Validate that ref is in expected format
  const validateRefs = repo.refs.some(r => {
    if (r.type == "regex") {
      const regex = new RegExp(r.ref)
      return regex.test(input.ref)
    } else if (r.type == "branch") {
      return r.ref == input.ref
    }
  })
  if (!validateRefs) {
    return core.setFailed(`Ref ${input.ref} is not allowed for source ${input.owner}/${input.repo}`)
  }

  core.exportVariable('REPO', input.repo)
  core.exportVariable('OWNER', input.owner)
  core.exportVariable('REF', input.ref)
  core.exportVariable('CHARTS', JSON.stringify(repo.helm_charts))
}