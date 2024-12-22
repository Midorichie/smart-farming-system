# Smart Farming IoT System

## Overview
A blockchain-based IoT system for agricultural monitoring, built on the Stacks blockchain. This system enables secure and transparent recording of soil moisture, temperature, and crop health data.

## Project Structure
```
smart-farming-iot/
├── contracts/
│   ├── smart-farming.clar       # Main contract
│   ├── sensors-registry.clar    # Sensor management
│   └── data-storage.clar        # Data storage logic
├── tests/
│   ├── smart-farming_test.ts
│   ├── sensors-registry_test.ts
│   └── data-storage_test.ts
├── settings/
│   └── Devnet.toml
├── Clarinet.toml
├── .gitignore
└── README.md
```

## Installation & Setup
1. Install Clarinet: `curl -L https://clarity.tools/install | sh`
2. Clone repository: `git clone https://github.com/your-username/smart-farming-iot`
3. Initialize project: `clarinet new smart-farming-iot`
4. Install dependencies: `clarinet install`

## Smart Contract Architecture

### 1. Main Contract (smart-farming.clar)
- System configuration
- Access control
- Core business logic
- Event management

### 2. Sensors Registry (sensors-registry.clar)
- Sensor registration
- Authentication
- Status management
- Maintenance tracking

### 3. Data Storage (data-storage.clar)
- Data structures
- Storage patterns
- Historical data management
- Query interfaces
