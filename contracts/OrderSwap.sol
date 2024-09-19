// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderSwap {
    
    uint256 orderId;

    struct Order {
        address tokenOffered;
        uint256 amountOffered;
        address tokenRequested;
        uint256 amountRequested;
        address depositor;
        uint256 orderTime;
        bool fulfilled;
    }

    mapping(uint256 => Order) orders;

    event OrderCreationSuccessful(
        address indexed depositor,
        address indexed tokenDeposit, 
        uint256 indexed amountDeposit, 
        address tokenRequest, 
        uint256 amountRequest
    );

    error AddressZeroDetected();
    error ZeroValueNotAllowed();
    error InsufficientFunds();


    function createOrder(
        address _tokenDeposit, 
        uint256 _amountDeposit, 
        address _tokenRequest, 
        uint256 _amountRequest
    ) external {
            if(msg.sender == address(0)) {
                revert AddressZeroDetected();
            }
            if(_tokenDeposit == address(0)) {
                revert AddressZeroDetected();
            }
            if(_tokenRequest == address(0)) {
                revert AddressZeroDetected();
            }

            if(_amountDeposit <= 0) {
                revert ZeroValueNotAllowed();
            }
            if(_amountRequest <= 0) {
                revert ZeroValueNotAllowed();
            }

            uint256 _userTokenBalance = IERC20(_tokenDeposit).balanceOf(msg.sender);

            if(_userTokenBalance < _amountDeposit) {
                revert InsufficientFunds();
            }

            orderId = orderId + 1;
            Order storage order = orders[orderId];
        
            order.tokenOffered = _tokenDeposit;
            order.amountOffered = _amountDeposit;
            order.tokenRequested = _tokenRequest;
            order.amountRequested = _amountRequest;
            order.depositor = msg.sender;
            order.orderTime = block.timestamp;


            IERC20(_tokenDeposit).transferFrom(msg.sender, address(this), _amountDeposit);

            emit OrderCreationSuccessful(msg.sender, _tokenDeposit, _amountDeposit, _tokenRequest, _amountRequest);
        }

    
    // Fulfilling an Order
    // Purchaser Process:
    // A purchaser finds an open order that they want to fulfill.
    // The purchaser needs to transfer the required amount of the counter-token to the contract.
    // The contract checks if the purchaser’s token amount matches the requested amount of the counter-token.
    // If valid, the contract swaps the tokens:
    // Transfer the depositor’s locked tokens to the purchaser.
    // Transfer the purchaser’s tokens to the depositor.
    // Once the order is fulfilled, mark it as closed or remove it from the list of open orders.
    // Emit an event indicating the successful swap, including details of both parties.
//     function fulfillOrder(uint256 _orderId, uint256 _fulfillAmount) external {
//         require(_orderId > 0, "Invalid ID");
//         if(_fulfillAmount <= 0) {
//             revert ZeroValueNotAllowed();
//         }
// // address tokenOffered;
// //         uint256 amountOffered;
// //         address tokenRequested;
// //         uint256 amountRequested;
// //         address depositor;
// //         uint256 orderTime;
// //         bool fulfilled;
//         Order storage order = orders[_orderId];
//         require(!order.fulfilled, "Order fulfilled");

//         // transfer o
//         IERC20(_tokenDeposit).transferFrom(msg.sender, address(this), _amountDeposit);




//     }
}
