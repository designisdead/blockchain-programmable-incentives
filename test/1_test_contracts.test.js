const PreReqs = require('./util/shared_instances')
const assertError = require('./util/assertRevert')
const utils = require('ethers').utils

var asciiToHex = function(str) {
    if(!str)
        return "0x00";
    var hex = "";
    for(var i = 0; i < str.length; i++) {
        var code = str.charCodeAt(i);
        var n = code.toString(16);
        hex += n.length < 2 ? '0' + n : n;
    }

    return "0x" + hex;
};

function stringToBytes32(text) {
    let result = utils.toUtf8Bytes(text)
    if (result.length > 32) { throw new Error('String too long') }
    result = utils.hexlify(result);
    while (result.length < 66) { result += '0'; }
    if (result.length !== 66) { throw new Error("invalid web3 implicit bytes32"); }
    return result;
}

contract('Test contracts', async (accounts) => {
  let controller, prerequisites, contractRegistry, token
  before(async() => {
    prerequisites = await PreReqs.preReqs(accounts)
    controller = prerequisites.controller
    contractRegistry = prerequisites.contractRegistry
    token = prerequisites.token
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
      await assertError(controller.registerUser('Dan', 'dan@eos.com', 'EOS', '', {from: accounts[1]}))
    })
  })
  describe('Group creation & membership', () => {
    it('Should create a new group', async () => {
      await controller.createGroup(asciiToHex("test"), "", {from:accounts[0]})
      group = await controller.getUser(accounts[0])
      group = group[5][0]
      let res = await controller.getGroup(group)
      assert.equal(utils.toUtf8String(res[0]).replace(/\u0000/g, ''), "test", "Name not equal or no contract found")
      assert.equal(res[0], stringToBytes32("test"), "Names should be equal")
      assert.equal(res[2], accounts[0], "The owner should be accounts[0]")
    })
    it('throws when the creator requests membership', async () => {
      await assertError(controller.requestMembership(group, {from:accounts[0]}))
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
  describe('Pull request creation & approval',() => {
    it('Gets the PRs for a group', async () => {
      assert(Array.isArray(await controller.getPRs(group)), "Should retrieve an empty array")
    })
    it('Should let a group member create a PR', async () => {
      await controller.createPR(group, "Test PR", "https://bitbucket.com", 152993)
      prs = await controller.getPRs(group)
      let pr = await controller.getPR(group, prs[0])
      assert.equal(pr[0], "Test PR", "PR title should be equal")
      assert.equal(pr[5], accounts[0], "Issuer should be accounts 0")
    })
    it('should retrieve a PR', async () => {
      let pr = await controller.getPR(group, prs[0])
      assert(pr !== undefined, "PR requested")
    })
    it('Should retrieve the reward from group', async () => {
      let rew = await controller.getReward(group)
      assert(rew !== undefined, "Reward requested")
    })
    it('Should let the group owner change the reward', async () => {
      await controller.changeReward(group, 500)
      assert.equal(await controller.getReward(group), 500, "Rewards not equal")
    })
    it('Throws when an unauthorized person tries to change the reward', async () => {
      await assertError(controller.changeReward(group, 500, {from: accounts[1]}))
    })
    it('Should let someone contribute', async () => {
      //starting balance 500 tokens on registration
      let contr = await contractRegistry.getContract('controller')
      await token.approve(contr, 200, {from: accounts[0]})
      assert.equal((await token.allowance(accounts[0], contr)).toString(10), 200 , "Should have 200 as allowance")
      await controller.contributePR(group, prs[0], 200, {from: accounts[0]})
      assert.equal((await controller.getContribution(group, prs[0], accounts[0])).toString(10), 200, "Contribution should be 200")
      assert.equal((await token.balanceOf(accounts[0])).toString(10), 300, "Remaining balance should be 300")
      assert.equal((await token.balanceOf(group)).toString(10), 200, "Group balance should be 200")
    })
    it('Throws when a non member tries to contribute', async () => {
      let contr = await contractRegistry.getContract('controller')
      await token.approve(contr, 10, {from: accounts[0]})
      assert.equal((await token.allowance(accounts[0], contr)).toString(10), 10 , "Should have 10 as allowance")
      await assertError(controller.contributePR(group , prs[0], 10, {from: accounts[2]}))
    })
    it('Throws when someone tries to contribute more than he approved', async () => {
      let contr = await contractRegistry.getContract('controller')
      await token.approve(contr, 10, {from: accounts[0]})
      assert.equal((await token.allowance(accounts[0], contr)).toString(10), 10 , "Should have 10 as allowance")
      await assertError(controller.contributePR(group, prs[0], 20, {from: accounts[0]}))
    })
    it('Throws when a non authorized person tries to approve the PR', async () => {
      await assertError(controller.approvePR(group, prs[0]))
    })
    it('Lets a member add a change request', async () => {
      await controller.requestPRChange(group, prs[0], "Change request", {from: accounts[1]})
      let change = await controller.getChangeRequest(group, prs[0], 0)
      let pr = await controller.getPR(group, prs[0])
      assert(pr[7] == 1, "Change count needs to be 1 Now")
      assert(change[0] == "Change request", "References need to be equal")
    })
    it('Lets an authorized member approve the PR', async () => {
      let grp = await controller.getGroup(group)
      assert.equal(accounts[1], grp[3][1], "accounts1 should be the second member at this point")
      await controller.approvePR(group, prs[0], {from: accounts[1]})
      let pr = await controller.getPR(group, prs[0])
      assert.equal(pr[4], 1, "Should be completed")
    })
    it('Should not be possible to approve a PR twice', async () => {
      await assertError(controller.approvePR(group, prs[0], {from:accounts[1]}))
    })
  })
  /*describe('Bounty creation & proposals', () => {
    it('Lets accounts[0] create a bounty', async () => {
      await controller.createBounty(group, "TestBounty", "qm20202", 152846577819 ,50)
      let res = await controller.getBounties(group)
      res = await controller.getBounty(group, res[0])
      assert.equal(res[0], "TestBounty", "Bounty not found")
    })
    it('throws when a non member tries to create a bounty', async () => {
        await assertError(controller.createBounty(group, "TestBounty2", "qm202022", 152846577819 ,50, {from: accounts[2]}))
    })
    it('Should let accounts1 add a proposal to the bounty', async() => {
      let bnty = await controller.getBounties(group)
      bnty = bnty[0]
      await controller.createProposal(group, bnty, "qm100000", {from: accounts[1]})
      let prpsl = await controller.getProposal(group, bnty, 0)
      assert.equal(prpsl[0], "qm100000", "references must be equal")
      assert.equal(prpsl[1], accounts[1], "author of proposal must be accounts1")
    })
    it('Should throw when someone who isnt a member tries to add a proposal', async () => {
      let bnty = await controller.getBounties(group)
      bnty = bnty[0]
        await assertError(controller.createProposal(group, bnty, "qm200000", {from: accounts[2]}))
    })
    it('Should throw when someone who is not the issuer tries to accept a bounty', async () => {
      let bnty = await controller.getBounties(group)
      bnty = bnty[0]
        await assertError(controller.acceptProposal(group, bnty, 0, {from: accounts[1]}))
    })
    it('Should let accounts0, the issuer of the bounty, accept the proposal', async () => {
      let bnty = await controller.getBounties(group)
      bnty = bnty[0]
      await controller.acceptProposal(group, bnty, 0, {from: accounts[0]})
      let prpsl = await controller.getProposal(group, bnty, 0)
      assert.equal(prpsl[2], true, "Proposal should be accepted now")
    })
  })
  */
})
