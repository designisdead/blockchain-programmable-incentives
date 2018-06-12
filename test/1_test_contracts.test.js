const PreReqs = require('./util/shared_instances')
const assertError = require('./util/assertRevert')


contract('Test contracts', async (accounts) => {
  let controller, prerequisites, contractRegistry
  before(async() => {
    prerequisites = await PreReqs.preReqs(accounts)
    controller = prerequisites.controller
    contractRegistry = prerequisites.contractRegistry
  })
  describe('Registry', PreReqs.preReqs(accounts))
  describe('People', () => {
    it('Should register a new user and retrieve it', async () => {
      await controller.registerUser("Nico", "nico@did.com", "Design is dead", "")
      let res = await controller.getUser(accounts[0])
      assert.equal(res[0], "Nico", "User not found")
    })
    it('Should update the user with attributes that are not empty', async () => {
      await controller.updateUser("Nico Vergauwen", "nico@designisdead.com", "Design Is Dead", "", {from: accounts[0]})
      let res = await controller.getUser(accounts[0])
      assert.equal(res[0], "Nico Vergauwen")
      assert.equal(res[1], "nico@designisdead.com")
    })
    it('Should register accounts1', async () => {
      await controller.registerUser('Dan', 'dan@eos.com', 'EOS', '', {from:accounts[1]})
      let res = await controller.getUser(accounts[1])
      assert.equal(res[0], 'Dan', 'User not found')
    })
    it('Throws trying to register an already registered user', async () => {
      assertError(controller.registerUser('Dan', 'dan@eos.com', 'EOS', '', {from: accounts[1]}))
    })
  })
  describe('Group creation & membership', () => {
    it('Should create a new group', async () => {
      await controller.createGroup("Test", "", {from:accounts[0]})
      group = await controller.getUser(accounts[0])
      group = group[5][0]
      let res = await controller.getGroup(group)
      assert.equal(res[0], "Test", "Name not equal or no contract found")
      assert.equal(res[2], accounts[0], "The owner should be accounts[0]")
    })
    it('throws when the creator requests membership', async () => {
      try {
        await controller.requestMembership(group, {from:accounts[0]})
      } catch (e) {
        console.info("Owner cant request membership again " + e)
      }
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
    it('Should add the group to accounts1 profile', async () => {
      let res = await controller.getUser(accounts[1])
      assert(res[5].length > 0 , "length greater than 0")
      assert.equal(res[5][0], group, "group addresses must be equal")
    })
    it('Should let a member leave a group', async () => {
      await controller.registerUser("Mark", "mark@facebook.com", "facebook", "", {from: accounts[2]})
      await controller.requestMembership(group, {from: accounts[2]})
      await controller.acceptMembership(group, accounts[2], {from: accounts[0]})
      let res = await controller.getGroup(group)
      assert.equal(res[3].pop(), accounts[2], "accounts2 must be a member now")
      await controller.leaveGroup(group, {from: accounts[2]})
      res = await controller.getGroup(group)
      assert(res[3].length < 3, "there should only be two members now")
      assert.notEqual(res[3].pop(), accounts[2], "accounts2 is not a member anymore")
    })
  })
  describe('Bounty creation & proposals', () => {
    it('Lets accounts[0] create a bounty', async () => {
      await controller.createBounty(group, "TestBounty", "https://test.com", "qm20202", 152846577819 ,50)
      let res = await controller.getBounties(group)
      res = await controller.getBounty(group, res[0])
      assert.equal(res[0], "TestBounty", "Bounty not found")
    })
    it('throws when a non member tries to create a bounty', async () => {
      try {
        await controller.createBounty(group, "TestBounty2", "https://test2.com", "qm202022", 152846577819 ,50, {from: accounts[2]})
      } catch (e) {
        console.info("A person that isn't a member can't create a bounty " +e)
      }
    })
    it('Should let accounts1 add a proposal to the bounty', async() => {
      let bnty = await controller.getBounties(group)
      bnty = bnty[0]
      await controller.createProposal(group, bnty, "qm100000", {from: accounts[1]})
      let prpsl = await controller.getProposal(group, bnty, 0)
      assert.equal(prpsl[0], "qm100000", "references must be equal")
      assert.equal(prpsl[1], accounts[1], "author of proposal must be accounts1")
    })
    it('Should let accounts0, the issuer of the bounty, accept the proposal', async () => {
      let bnty = await controller.getBounties(group)
      bnty = bnty[0]
      await controller.acceptProposal(group, bnty, 0, {from: accounts[0]})
      let prpsl = await controller.getProposal(group, bnty, 0)
      assert.equal(prpsl[2], true, "Proposal should be accepted now")
    })
  })
})
