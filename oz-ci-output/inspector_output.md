# Findings


[low]
### Usage of `delegatecall` Inside a Loop

Using `delegatecall` with value transfers inside loops should generally be avoided due to potential security risks.

In `3-MultiCall.sol`, the [for loop](/home/gianfranco/GitHub/Tenderly-war-room-games-EthCC-7-solutions/src/3-MultiCall.sol:99:111) contains a `delegatecall` with value transfer. For instance:

- In [line 99 within the for loop](/home/gianfranco/GitHub/Tenderly-war-room-games-EthCC-7-solutions/src/3-MultiCall.sol:99:111).

Consider avoiding using `delegatecall` with value transfer inside loops.

----
 Contract Inspector version: 2.11.0
 Scanner versions:
 - zast@2.5.1
