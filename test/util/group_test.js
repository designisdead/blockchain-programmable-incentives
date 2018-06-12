const groupTest = (accounts, controller, contractRegistry) => {
  describe('Group creation & membership', () => {
    it('Should create a new group', async () => {
      await controller.createGroup("Test", "")
      group = controller.getUser(accounts[0])
      group = group[5][0]
      let res = await controller.getGroup(group)
      assert.equal(res[0], "Test", "Name not equal or no contract found")
      assert.equal(res[2], accounts[0], "The owner should be accounts[0]")
      console.info(res)
    })
    it('throws when the creator requests membership', async () => {
      assertError(controller.requestMembership(group, {from: accounts[0]}))
    })
    it('Lets accounts[0] create a bounty', async () => {
      await controller.createBounty(group, "TestBounty", "https://test.com", "qm20202", 152846577819 ,50)
      let res = await controller.getUser(accounts[0])
      group = res[5][0]
      console.info(await controller.getBounty(group, "https://test.com"))
      //assert.equal(res[0], "TestBounty", "Bounty not found")
    })
    it('should let accounts[1] request membership', async () => {
      await controller.requestMembership(group, {from: accounts[1]})
      let res = await controller.getGroup(group)
      assert(res[4].length == 1, "accounts1 is pending")
      assert.equal(res[4][0], accounts[1], "pending member is not accounts1")
    })
    it('lets accounts[0] accept the membership', async () => {
      await controller.acceptMembership(group, accounts[1], {from: accounts[0]})
      let res = await controller.getGroup(group)
      assert(res[4].length == 0, "pending should be empty")
      assert(res[3].length == 2, "Should have two members now")
      assert.equal(res[3][0], accounts[0], "First member should be accounts [0]")
      assert.equal(res[3][1], accounts[1], "Second member should be accounts[1]")
    })
  })
}

module.exports = groupTest
