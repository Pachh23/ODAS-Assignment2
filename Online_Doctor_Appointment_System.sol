// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DoctorBooking {
    // โครงสร้างข้อมูลการจอง
    struct Reservation {
        uint256 doctorId;
        address patient;
        uint256 timeSlot;
        uint256 price;
        string doctorName;
    }

    // ตัวแปรเก็บข้อมูล
    mapping(uint256 => Reservation) public reservations;
    mapping(uint256 => mapping(uint256 => bool)) public doctorSchedule; // doctorId => timeSlot => isBooked
    mapping(address => uint256[]) public patientReservations;
    
    uint256 public nextReservationId = 1;
    address public owner;
    
    event ReservationCreated(
        uint256 indexed reservationId,
        uint256 indexed doctorId,
        address indexed patient,
        uint256 timeSlot,
        string doctorName
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function reserveAppointment(uint256 doctorId) external payable {
        require(msg.value == 0.0001 ether, "Incorrect payment amount");
        require(!doctorSchedule[doctorId][block.timestamp], "Time slot already booked");
        
        uint256 reservationId = nextReservationId++;
        
        reservations[reservationId] = Reservation({
            doctorId: doctorId,
            patient: msg.sender,
            timeSlot: block.timestamp,
            price: msg.value,
            doctorName: getDoctorName(doctorId)
        });

        doctorSchedule[doctorId][block.timestamp] = true;
        patientReservations[msg.sender].push(reservationId);

        emit ReservationCreated(
            reservationId,
            doctorId,
            msg.sender,
            block.timestamp,
            getDoctorName(doctorId)
        );
    }

    function getAllReservations() external view returns (
        uint256[] memory times,
        string[] memory doctors,
        address[] memory patients
    ) {
        uint256 totalReservations = nextReservationId - 1;
        times = new uint256[](totalReservations);
        doctors = new string[](totalReservations);
        patients = new address[](totalReservations);

        for (uint256 i = 1; i <= totalReservations; i++) {
            Reservation storage res = reservations[i];
            times[i-1] = res.timeSlot;
            doctors[i-1] = res.doctorName;
            patients[i-1] = res.patient;
        }

        return (times, doctors, patients);
    }

    function getDoctorName(uint256 doctorId) internal pure returns (string memory) {
        if (doctorId == 1) return unicode"Dr. Han Ji-yu";
        if (doctorId == 2) return unicode"Dr. Zhang Wu-ji";
        if (doctorId == 3) return unicode"Dr. Yu Hye-jung";
        if (doctorId == 4) return unicode"Dr. Jeon Won-woo";
        if (doctorId == 5) return unicode"Dr. Sahara";
        if (doctorId == 6) return unicode"Dr. Kim Soo-kyun";
        return "Unknown Doctor";
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}