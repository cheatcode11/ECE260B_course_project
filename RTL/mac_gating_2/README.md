# MAC Gating Implementation

## Overview

This project implements clock gating for a MAC (Multiply-Accumulate) array using a dedicated clock gate file (`clk_gate.v`). The modifications ensure efficient power management by enabling clock gating at the negative edge.

## Key Modifications

### MAC Array Testing
The output of the entire MAC array is verified using the pre-existing `fullchip_tb` testbench.

All necessary files have been updated to accommodate the gated versions of `mac_8in` and `mac_col`.

### Extra Pipeline for mac_col (col_id = 1)
An additional pipeline stage is added before sending data into `mac_col`.

This is required for:
- Generating the `q_zero` signal, which indicates if any element is zero.
- Ensuring correct timing alignment so that the `is_zero` signal arrives before the data signal.

### Clock Gating Enablement
The above modifications facilitate enabling clock gating on the negative edge of the clock.

### Updated Wrapper Modules
`mac_wrapper` now includes:
- The extra pipeline stage.
- The modified `mac_array_gated`, which incorporates clock-gated elements.
- `mac_array_wrapper` serves as a direct replacement for the original `mac_array`, ensuring seamless integration.

## MAC Gating Diagram
![MAC Gating Diagram](./mac_gating.png)

## File Structure
- `clk_gate.v` - Implements clock gating.
- `mac_8in_gated.v` - Modified MAC unit with clock gating.
- `mac_col_gated.v` - Modified column unit with clock gating.
- `mac_array_gated.v` - Full MAC array with gated elements.
- `mac_wrapper.v` - Wrapper that integrates the new gated MAC array.
- `mac_array_wrapper.v` - Direct replacement for the original `mac_array`.
- `fullchip_gated_tb.v` - Testbench for full-chip verification.

## Usage
Ensure that all gated versions of the modules are included in the design before running simulations or synthesis. The `fullchip_gated_tb` can be used to validate the correctness of the implementation.

Important to note: The testbench has been modified. 
- The pipeline increases the result latency by 1 cycle, which means the new MAC array needs to run for one more cycle.
- The result compared is no longer one cycle behind, it is two cycles behind.

## Conclusion
This implementation optimizes power usage by gating the clock in the MAC array. The additional pipeline ensures correct timing and functionality while maintaining compatibility with the existing architecture.

