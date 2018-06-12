pragma solidity ^0.4.23;

import '../interface/timesheet-interface.sol';

library TimesheetLib {
  event closePeriod(address indexed user, uint start, uint end, bool accepted);

  function processPeriod(TimesheetInterface.Timesheet storage _timesheet, address _user, uint _start, uint _end, bool _closed) external {
    require(_start < now);
    TimesheetInterface.Period memory p;
    p.start = _start;
    p.end = _end;
    p.closed= _closed;
    p.processed = true;
    _timesheet.timesheet[_user].periods.push(p);
    emit closePeriod(_user, _start, _end, _closed);
  }

  function getPeriod(TimesheetInterface.Timesheet storage _timesheet, address _user, uint _index) external view returns (uint, uint, bool, bool) {
      return (_timesheet.timesheet[_user].periods[_index].start, _timesheet.timesheet[_user].periods[_index].end, _timesheet.timesheet[_user].periods[_index].closed, _timesheet.timesheet[_user].periods[_index].processed);
  }

  function getPeriodCount(TimesheetInterface.Timesheet storage _timesheet, address _user) external view returns (uint) {
    return _timesheet.timesheet[_user].periods.length;
  }

  function addAdmin(TimesheetInterface.Timesheet storage _timesheet, address _user) external {
      _timesheet.admins[_user] = true;
  }

  function removeAdmin(TimesheetInterface.Timesheet storage _timesheet, address _user) external {
      _timesheet.admins[_user] = false;
  }

  function isAdmin(TimesheetInterface.Timesheet storage _timesheet, address _user) external view returns (bool) {
    return _timesheet.admins[_user];
  }
}
