# Learn Hardhat

這是一個以 Hardhat 開發模組為核心的 Solidity 實作練習，理論可至
https://yanrusu.github.io/categories/blockchain/ 閱讀，主題包含但不限於：

- 基礎 ERC20 與部署
- 地址與雜湊（`checkaddr`、`keccak256`、`abi encode/decode`）
- fallback/receive 與事件
- 介面識別（`interfaceId`）
- ERC20 + Vault / Bank
- 重入攻擊示範
- ERC721（含 metadata）

## 開發環境

- Node.js v22.21.0
- npm 11.6.2


## 部署
### Arbitrum Sepolia
部署於 Arbitrum Sepolia Testnet

`hardhat.config.js` 目前使用 Hardhat 的 `vars.get(...)` 讀取參數，請先設定：

```bash
npx hardhat vars set ALCHEMY_API_KEY
npx hardhat vars set ARBITRUM_SEPOLIA_PRIVATE_KEY
```

設定完成後可部署 Arbitrum Sepolia：
```bash
npx hardhat run scripts/deploy.js --network arbitrumSepolia
```

## 專案結構

```text
.
├─ contracts/        # Solidity 合約
├─ scripts/          # 部署與腳本
├─ test/             # Hardhat 測試
├─ ignition/         # Hardhat Ignition 部署輸出
├─ hardhat.config.js # Hardhat 設定
└─ package.json      # 套件與依賴
```

## 學習

- `contracts/1`: 基礎 `Token`
- `contracts/3`: 地址檢查
- `contracts/5`: `keccak256`
- `contracts/6`: ABI encode/decode
- `contracts/8`: `fallback` / `receive` / sender
- `contracts/9`: interface ID
- `contracts/10`: ERC20 + Vault
- `contracts/11`: ERC20 + SimpleBank
- `contracts/12`: Reentrancy 攻擊與防禦示範
- `contracts/13`: ERC721（metadata）

## 備註

