import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const OrderSwapModule = buildModule("OrderSwapModule", (m) => {

  const orderSwap = m.contract("OrderSwap", []);

  return { orderSwap };
});

export default OrderSwapModule;
