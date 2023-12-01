#{source}

try {
  const args = #{args}
  // const output = JSON.stringify(['ok', #{func}(...args), []])
  // process.stdout.write(output)
  Promise.resolve(#{func}(...args)).then(result => {
    const output = JSON.stringify(['ok', result, []])
    process.stdout.write(output)
  })
} catch (err) {
  process.stdout.write(JSON.stringify(['err', '' + err, err.stack]))
}
