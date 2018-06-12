module.exports = async promise => {
  try {
    await promise
    assert.fail('Expected error not received')
  } catch (error) {
    const rev = error.message.search('revert') >= 0
    assert(rev, `Expected "revert", got ${error.message} instead`)
  } 
}
