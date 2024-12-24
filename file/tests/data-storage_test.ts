// data-storage_test.ts
Clarinet.test({
  name: "Ensure historical data can be stored",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "data-storage",
        "store-historical-data",
        [
          types.uint(1),    // sensor-id
          types.int(25),    // temperature
          types.uint(60),   // moisture
          types.uint(85),   // health-index
        ],
        deployer.address
      ),
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});

Clarinet.test({
  name: "Ensure data counter increments correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    // Store first data point
    let block = chain.mineBlock([
      Tx.contractCall(
        "data-storage",
        "store-historical-data",
        [
          types.uint(1),
          types.int(25),
          types.uint(60),
          types.uint(85),
        ],
        deployer.address
      ),
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), true);
    
    // Store second data point
    block = chain.mineBlock([
      Tx.contractCall(
        "data-storage",
        "store-historical-data",
        [
          types.uint(1),
          types.int(26),
          types.uint(62),
          types.uint(87),
        ],
        deployer.address
      ),
    ]);
