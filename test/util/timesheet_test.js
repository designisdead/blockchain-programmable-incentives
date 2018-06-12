const timesheetTest = (accounts) => {
  const assertRevert = require('./assertRevert')
  describe('Timesheet & admins', () => {
    it('Lets the owner (accounts[0]) add himself as admin', async () => {
      await timesheet.addAdmin(accounts[0], {from: accounts[0]})
      assert.equal(await timesheet.isAdmin(accounts[0]), true, "Must be an admin")
    })
    it('Lets an admin add a period for a user', async () => {
      await timesheet.processPeriod(accounts[0], 1, 100, true, accounts[0])
      let res = await timesheet.getPeriod(accounts[0], 0)
      assert.equal(res[3], true, "Processed should equal true")
    })
  })
}

module.exports = timesheetTest
