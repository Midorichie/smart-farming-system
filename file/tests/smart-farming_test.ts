// smart-farming_test.ts
import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types,
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure contract owner can register a new sensor",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const sensor = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "smart-farming",
        "register-sensor",
        [types.principal(sensor.address)],
        deployer.address
      ),
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});

Clarinet.test({
  name: "Ensure only authorized sensors can record data",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const sensor = accounts.get("wallet_1")!;
    const unauthorizedSensor = accounts.get("wallet_2")!;
    
    // Register sensor first
    let block = chain.mineBlock([
      Tx.contractCall(
        "smart-farming",
        "register-sensor",
        [types.principal(sensor.address)],
        deployer.address
      ),
    ]);
    
    // Authorized sensor should succeed
    block = chain.mineBlock([
      Tx.contractCall(
        "smart-farming",
        "record-sensor-data",
        [
          types.uint(1),    // sensor-id
          types.int(25),    // temperature
          types.uint(60),   // moisture
          types.uint(85),   // health-index
        ],
        sensor.address
      ),
    ]);
    assertEquals(block.receipts[0].result.expectOk(), true);
    
    // Unauthorized sensor should fail
    block = chain.mineBlock([
      Tx.contractCall(
        "smart-farming",
        "record-sensor-data",
        [
          types.uint(2),
          types.int(25),
          types.uint(60),
          types.uint(85),
        ],
        unauthorizedSensor.address
      ),
    ]);
    assertEquals(block.receipts[0].result.expectErr(), "u2");
  },
});
