pragma solidity ^0.4.23;

import '../interface/timesheet-interface.sol';
import '../registry/enabled.sol';
import '../util/Ownable.sol';

contract Timesheet is Ownable, Enabled {
  using TimesheetInterface for TimesheetInterface.Timesheet;
  TimesheetInterface.Timesheet timesheet;

  modifier admin(address _sender) {
    require(timesheet.admins[_sender]);
      _;
  }
  event closePeriod(address indexed user, uint start, uint end, bool accepted);

  function addAdmin(address _user) onlyOwner external {
      return timesheet.addAdmin(_user);
  }

  function isAdmin(address _user) external view returns (bool) {
    return timesheet.isAdmin(_user);
  }

  function removeAdmin(address _user) onlyOwner external {
      return timesheet.removeAdmin(_user);
  }

  function processPeriod(address _user, uint _start, uint _end, bool _closed, address _sender) admin(_sender) external isEnabled("controller") {
      return timesheet.processPeriod(_user, _start, _end, _closed);
  }

  function getPeriod(address _user, uint _index) external view isEnabled("controller") returns (uint, uint, bool, bool) {
      return timesheet.getPeriod(_user, _index);
  }

  function getPeriodCount(address _user) external view isEnabled("controller") returns (uint) {
    return timesheet.getPeriodCount(_user);
  }
}
