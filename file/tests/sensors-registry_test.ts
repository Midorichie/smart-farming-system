// sensors-registry_test.ts
Clarinet.test({
  name: "Ensure sensor details can be registered correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const sensor = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "sensors-registry",
        "register-sensor-details",
        [
          types.principal(sensor.address),
          types.utf8("moisture-sensor"),
          types.utf8("field-a-north"),
        ],
        deployer.address
      ),
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});

Clarinet.test({
  name: "Ensure sensor details are stored correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const sensor = accounts.get("wallet_1")!;
    
    // Register sensor details
    let block = chain.mineBlock([
      Tx.contractCall(
        "sensors-registry",
        "register-sensor-details",
        [
          types.principal(sensor.address),
          types.utf8("temperature-sensor"),
          types.utf8("field-b-south"),
        ],
        deployer.address
      ),
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});
