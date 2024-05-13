#{source}

/**
 * This file overrides the original node_runner.js from the node-runner gem
 * in order to handle promises (the original does not)
 * */
try {
  const args = #{args}
    Promise.resolve(#{func}(...args)).then(result => {
    const output = JSON.stringify(['ok', result, []])
    process.stdout.write(output)
  })
} catch (err) {
  process.stdout.write(JSON.stringify(['err', '' + err, err.stack]))
}
