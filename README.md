# OneToken (ONE)

基于 OpenZeppelin v5 的 ERC-20，Foundry 工程。

- 部署时给 owner 铸造初始供应（脚本默认 1,000,000 ONE）
- 总量上限 `cap`（脚本默认 10,000,000 ONE），超出即 revert `ERC20ExceededCap`
- 只有 owner 能 `mint`；任何持有人可 `burn` 自己的币，或凭授权 `burnFrom`

## 使用

```bash
forge build
forge test -vv
```

本地链部署：

```bash
anvil
# 另开终端；私钥为 anvil 默认账户 0
forge script script/DeployOneToken.s.sol --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

部署地址写在 `broadcast/DeployOneToken.s.sol/31337/run-latest.json`，之后可用 `cast call` / `cast send` 交互。
