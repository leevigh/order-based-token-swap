// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract OrderSwap is ReentrancyGuard {
    
    uint256 orderId;

    /* note: I'm writing the comments for myself or readers to understand my code better. */

    struct Order {
        address tokenOffered; // token depositor is offering for requested
        uint256 amountOffered; // amount depositor is giving for requested token
        address tokenRequested; // token depositor wants for offer
        uint256 amountRequested; // amount of the token the depositor wants
        address depositor; // order creator
        uint256 orderTime; // time when order was created
        bool fulfilled;
        bool isCancelled; // for implementing cancellation
    }

    mapping(uint256 => Order) orders;

    event OrderCreationSuccessful(
        address indexed depositor,
        address indexed tokenDeposit, 
        uint256 indexed amountDeposit, 
        address tokenRequest, 
        uint256 amountRequest
    );
    event OrderFulfilmentSuccessful(
        address indexed purchaser,
        uint256 indexed orderId,
        address indexed tokenPurchased,
        uint256 amountPurchased
    );
    event OrderCancelled(address depositor, uint256 orderId);

    error AddressZeroDetected();
    error ZeroValueNotAllowed();
    error InsufficientFunds();


    function createOrder(
        address _tokenDeposit, 
        uint256 _amountDeposit, 
        address _tokenRequest, 
        uint256 _amountRequest
    ) external nonReentrant {
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

    
    function fulfillOrder(uint256 _orderId, uint256 _fulfillAmount) external nonReentrant {
        require(_orderId > 0, "Invalid ID");
        if(_fulfillAmount <= 0) {
            revert ZeroValueNotAllowed();
        }

        Order storage order = orders[_orderId];
        require(!order.fulfilled, "Order fulfilled");
        require(order.amountRequested == _fulfillAmount, "Invalid fulfilment amount");
        require(!order.isCancelled, "Order cancelled");
        
        uint256 _userTokenBalance = IERC20(order.tokenRequested).balanceOf(msg.sender);

        if(_userTokenBalance < _fulfillAmount) {
            revert InsufficientFunds();
        }

        order.fulfilled = true;

        // transfer requested token from order to the depositor
        IERC20(order.tokenRequested).transferFrom(msg.sender, address(order.depositor), order.amountRequested);

        // transfer offered token amount to purchaser
        IERC20(order.tokenOffered).transfer(msg.sender, order.amountOffered);

        emit OrderFulfilmentSuccessful(msg.sender, _orderId, order.tokenOffered, order.amountOffered);

    }

    function cancelOrder(uint256 _orderId) external nonReentrant {
        require(_orderId > 0, "Invalid ID");

        Order storage order = orders[_orderId];
        require(!order.fulfilled, "Order fulfilled");
        require(msg.sender == address(order.depositor), "Invalid depositor");
        require(!order.isCancelled, "Already cancelled");

        order.isCancelled = true;

        // transfer deposit token amount back to depositor
        IERC20(order.tokenOffered).transfer(msg.sender, order.amountOffered);

        emit OrderCancelled(msg.sender, _orderId);
    }
}
