pragma solidity ^0.4.23;

library TimesheetInterface {
  struct Period {
    uint start;
    uint end;
    bool closed;
    bool processed;
  }

  struct Periods {
    Period[] periods;
  }

  struct Timesheet {
    mapping (address => Periods) timesheet;
    mapping (address => bool) admins;
  }

    function processPeriod(Timesheet storage _timesheet, address _user, uint _start, uint _end, bool _closed) external;
    function getPeriod(Timesheet storage _timesheet, address _user, uint _index) external view returns (uint, uint, bool, bool);
    function getPeriodCount(Timesheet storage _timesheet, address _user) external view returns (uint);
    function addAdmin(Timesheet storage _timesheet, address _user) external;
    function removeAdmin(Timesheet storage _timesheet, address _user) external;
    function isAdmin(Timesheet storage _timesheet, address _user) external view returns (bool);
}
