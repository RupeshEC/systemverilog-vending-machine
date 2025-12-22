# SystemVerilog Vending Machine (FSM Based)

## Overview
FSM-based vending machine implemented in SystemVerilog.
Supports 5 trays with 5 products each and dispenses products
only after successful UPI payment verification.

## Design Highlights
- FSM-based control logic
- Handshake abstraction for UPI payment
- Counter-based spring motor abstraction
- Synthesizable RTL (always_ff / always_comb)
- SystemVerilog assertions for verification

## FSM States
IDLE → SELECT → WAIT_PAYMENT → SPRING_MOVE → DISPENSE

## Tools
ModelSim / Questa / Xcelium

## Author
Rupesh Singh


