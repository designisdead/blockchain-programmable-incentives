const peopleTest = (accounts, controller, contractRegistry) => {
  const assertError = require('./assertRevert')
  const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'
  describe('People', () => {
    it('Should register a new user and retrieve it', async () => {
      await controller.registerUser("Nico", "nico@did.com", "Design is dead", "")
      let res = await controller.getUser(accounts[0])
      assert.equal(res[0], "Nico", "User not found")
    })
    it('Should update the user with attributes that are not empty', async () => {
      await controller.updateUser("Nico Vergauwen", "nico@designisdead.com", "Design Is Dead", "")
      let res = await controller.getUser(accounts[0])
      assert.equal(res[0], "Nico Vergauwen")
      assert.equal(res[1], "nico@designisdead.com")
    })
    it('Should register accounts1', async () => {
      await controller.registerUser('Dan', 'dan@eos.com', 'EOS', '', {from:accounts[1]})
      let res = await controller.getUser(accounts[1])
      assert.equal(res[0], 'Dan', 'User not found')
    })
  })
}

module.exports = peopleTest
