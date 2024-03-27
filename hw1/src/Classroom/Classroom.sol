// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* Problem 1 Interface & Contract */
contract StudentV1 {
    uint256 public studentCount = 1877;
    function register() external returns (uint256) {
    
        studentCount = studentCount-877;
        return studentCount;
    }
}

/* Problem 2 Interface & Contract */
interface IClassroomV2 {
    function isEnrolled() external view returns (bool);
}
contract StudentV2 {
    function register() external view returns (uint256) {
        if (IClassroomV2(msg.sender).isEnrolled()){
            return 123;
        }
        else return 1000;
    }
    
}

/* Problem 3 Interface & Contract */
contract StudentV3 {
    function register() external view returns (uint256) {
        if(gasleft() >= 7000){
            return 1000;
        }else{
            return 123;
        }
}
}
