const ContractRegistry = artifacts.require('ContractRegistry')
const Controller = artifacts.require('Controller');
const PeopleProxy = artifacts.require('PeopleProxy')
const PeopleLib = artifacts.require('PeopleLib')
const People = artifacts.require('People')
const GroupProxy = artifacts.require('GroupProxy')
const GroupLib = artifacts.require('GroupLib')
const BountyLib = artifacts.require('BountyLib')
const BountyProxy = artifacts.require('BountyProxy')
const Group = artifacts.require('Group')
const TimesheetProxy = artifacts.require('TimesheetProxy')
const TimesheetLib = artifacts.require('TimesheetLib')
const Timesheet = artifacts.require('Timesheet')

const preReqs = exports.preReqs = async (accounts) => {
  const contractRegistry = await ContractRegistry.new()
    it('Should have ContractRegistry deployed', async () => {
      assert(contractRegistry !== undefined, "contractRegistry is deployed")
    })
    const peopleLib = await PeopleLib.new()
    it('Should have peopleLib deployed', async () => {
      assert(peopleLib !== undefined, "peopleLib is deployed")
    })
    await contractRegistry.addLibrary("people", peopleLib.address)
    it("Should have added peopleLib to the contractRegistry", async () => {
      assert.equal(await contractRegistry.getLibrary("people"), peopleLib.address, "Addresses must be equal")
    })
    const peopleProxy = await PeopleProxy.new()
    it("SHould have deployed peopleProxy", async () => {
      assert(peopleProxy !== undefined, "peopleProxy is deployed")
    })
    await contractRegistry.addContract("people-proxy", peopleProxy.address)
    it("Should have added peopleProxy to the contractRegistry", async () => {
      assert.equal(await contractRegistry.getContract("people-proxy"), peopleProxy.address, "Addresses must be equal")
    })
    const groupLib = await GroupLib.new()
    it('Should have deployed groupLib', async () => {
      assert(groupLib !== undefined, "groupLib is deployed")
    })
    await contractRegistry.addLibrary("group", groupLib.address)
    it('Should have added groupLib to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getLibrary('group'), groupLib.address, "Addresses must be equal")
    })
    const groupProxy = await GroupProxy.new()
    it('Should have deployed groupProxy', async () => {
      assert(groupProxy !== undefined, "groupProxy deployed")
    })
    await contractRegistry.addContract("group-proxy", groupProxy.address)
    it('Should have added groupProxy to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getContract("group-proxy"), groupProxy.address, "Addresses must be equal")
    })
    const bountyLib = await BountyLib.new()
    it('Should have deployed bountyLib', () => {
      assert(bountyLib !== undefined, "BountyLib deployed")
    })
    await contractRegistry.addLibrary("bounty", bountyLib.address)
    it('Should have added bountyLib to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getLibrary('bounty'), bountyLib.address, "Addresses must be equal")
    })
    const bountyProxy = await BountyProxy.new()
    it('Should have deployed bountyProxy', () => {
      assert(bountyProxy !== undefined, "bountyProxy deployed")
    })
    await contractRegistry.addContract("bounty-proxy", bountyProxy.address)
    it('Should have added bountyProxy to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getContract('bounty-proxy'), bountyProxy.address, "Addresses must be equal")
    })
    const timesheetLib = await TimesheetLib.new()
    it('Should have deployed timesheetLib', () => {
      assert(timesheetLib !== undefined, "timesheetLib deployed")
    })
    await contractRegistry.addLibrary('timesheet', timesheetLib.address)
    it('Should have added timesheetLib to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getLibrary('timesheet'), timesheetLib.address, "Addresses must be equal")
    })
    const timesheetProxy = await TimesheetProxy.new()
    it('Should have deployed timesheetProxy', () => {
      assert(timesheetProxy !== undefined, "timesheetProxy deployed")
    })
    await contractRegistry.addContract('timesheet-proxy', timesheetProxy.address)
    it('Should have added timesheetProxy to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getContract('timesheet-proxy'), timesheetProxy.address, "Addresses must be equal")
    })
    People.link('PeopleInterface', peopleProxy.address)
    Controller.link({GroupInterface: groupProxy.address, BountyInterface: bountyProxy.address})
    Group.link({GroupInterface: groupProxy.address, BountyInterface: bountyProxy.address})
    Timesheet.link('TimesheetInterface', timesheetProxy.address)
    const controller = await Controller.new()
    it('Should have deployed Controller', async () => {
      assert(controller !== undefined, "controller is deployed")
    })
    await contractRegistry.addContract("controller", controller.address)
    it('Should have added controller to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getContract("controller"), controller.address, "Addresses must be equal")
    })
    const people = await People.new()
    it('Should have deployed people-storage', () => {
      assert(people !== undefined, "people-storage deployed")
    })
    await contractRegistry.addContract("people-storage", people.address)
    it('Should have added people-storage to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getContract('people-storage'), people.address, "Addresses must be equal")
    })
    const timesheet = await Timesheet.new()
    it('Should have deployed timesheet-storage', () => {
      assert(timesheet !== undefined, 'timesheet-storage deployed')
    })
    await contractRegistry.addContract('timesheet-storage', timesheet.address)
    it('Should have added timesheet-storage to the contractRegistry', async () => {
      assert.equal(await contractRegistry.getContract('timesheet-storage'), timesheet.address, "Addresses must be equal")
    })
    return { contractRegistry, controller, timesheet }
}
