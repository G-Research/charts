module.exports = async ({ core, exec }) => {
  const fs = require('fs');
  const checkoutPageDir = "gh-pages"
  const checkoutSourceDir = "source"
  const helmVersionReplaceFiles = ['Chart.yaml', 'values.yaml']
  // TODO: NOTE: Updating version in Chart.yml and values.yml will work only for Chart.yaml as values.yaml doesn't have version as pointer in json (packageChart.js line 33)

  // Envs are set in  validate chart step
  const helm = {
    owner: process.env.OWNER,
    repo: process.env.REPO,
    ref: process.env.REF,
    charts: JSON.parse(process.env.CHARTS)
  }
  core.debug(helm.charts)

  // Update chart version and stage files to git
  try {
    for (const chart of helm.charts) {

      // Check if source folder for chart exists  
      if (!fs.existsSync(`${checkoutSourceDir}/${chart.source}`)) {
        core.notice(chart)
        return core.setFailed(`Source directory ${checkoutSourceDir}/${chart.source} doesn't exist`);
      }

      // Check if destination folder for chart exists
      if (!fs.existsSync(`${checkoutPageDir}/${chart.destination}`)) {
        core.notice(`Destination directory ${checkoutPageDir}/${chart.destination} doesn't exist\nCreating new directory: ${checkoutPageDir}/${chart.destination}`)
        fs.mkdirSync(`${checkoutPageDir}/${chart.destination}`)
      }

      if (chart.use_ref_as_version) {
        // Update the chart versionx
        const version = helm.ref.replace(new RegExp(chart.use_ref_as_version.pattern), chart.use_ref_as_version.replacement)
        core.notice(`Packaging the ${chart.name} chart with the version ${version}`)
        try {
          for (const file of helmVersionReplaceFiles) {
            core.debug(`${checkoutSourceDir}/${chart.source}/${file}`)
            await exec.exec('yq', ['-i', `.version = "${version}"`, `${checkoutSourceDir}/${chart.source}/${file}`])
            await exec.exec('yq', ['-i', `.appVersion = "${version}"`, `${checkoutSourceDir}/${chart.source}/${file}`])
          }
        } catch (error) {
          core.notice(`${checkoutSourceDir}/${chart.source}/${file}\n Version: ${version}`)
          return core.setFailed(`The file ${checkoutSourceDir}/${chart.source}/${file} doesn't exist\n${error}`);
        }

        await exec.exec('helm', ['package', `${checkoutSourceDir}/${chart.source}`, '-d', `${checkoutPageDir}/${chart.destination}`])
      } else {
        core.notice(`Packaging the chart ${chart.name}`)
        await exec.exec('helm', ['package', `${checkoutSourceDir}/${chart.source}`, '-d', `${checkoutPageDir}/${chart.destination}`])
      }
      await exec.exec('git', ['add', `${chart.destination}`], { cwd: checkoutPageDir })
    }
  } catch (error) {
    console.error(error);
    return core.setFailed(`Unable to update the version and stage files with error: ${error}`)
  }

  let status = "";
  await exec.exec('git', ['status', '--porcelain=v1'], {
    cwd: checkoutPageDir,
    listeners: { 'stdout': data => { status += data.toString() }}
  })
  for (const line of status.split('\n')) {
    if (line.length > 0 && !line.startsWith('A')) {
      return core.setFailed(`Only new files to be added, but that's not the case: ${line}`)
    }
  }

}