pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./WadRayMath.sol";

import "hardhat/console.sol";


/**
* @title CoreLibrary library
* @author Aave
* @notice Defines the data structures of the reserves and the user data
**/
library CoreLibrary {
    using SafeMath for uint256;
    using WadRayMath for uint256;

    uint256 internal constant SECONDS_PER_YEAR = 365 days;

    struct ReserveData {
        /**
        * @dev refer to the whitepaper, section 1.1 basic concepts for a formal description of these properties.
        **/
        //the liquidity index. Expressed in ray
        uint256 lastLiquidityCumulativeIndex;
        //the current supply rate. Expressed in ray
        uint256 currentLiquidityRate;
        //the total borrows of the reserve at a stable rate. Expressed in the currency decimals
        uint256 totalBorrowsStable;
        //the total borrows of the reserve at a variable rate. Expressed in the currency decimals
        uint256 totalBorrowsVariable;
        //the current variable borrow rate. Expressed in ray
        uint256 currentVariableBorrowRate;
        //the current stable borrow rate. Expressed in ray
        uint256 currentStableBorrowRate;
        //the current average stable borrow rate (weighted average of all the different stable rate loans). Expressed in ray
        uint256 currentAverageStableBorrowRate;
        //variable borrow index. Expressed in ray
        uint256 lastVariableBorrowCumulativeIndex;
        //the ltv of the reserve. Expressed in percentage (0-100)
        uint256 baseLTVasCollateral;
        //the liquidation threshold of the reserve. Expressed in percentage (0-100)
        uint256 liquidationThreshold;
        //the liquidation bonus of the reserve. Expressed in percentage
        uint256 liquidationBonus;
        //the decimals of the reserve asset
        uint256 decimals;
        /**
        * @dev address of the aToken representing the asset
        **/
        address aTokenAddress;
        /**
        * @dev address of the interest rate strategy contract
        **/
        address interestRateStrategyAddress;
        uint40 lastUpdateTimestamp;
        // borrowingEnabled = true means users can borrow from this reserve
        bool borrowingEnabled;
        // usageAsCollateralEnabled = true means users can use this reserve as collateral
        bool usageAsCollateralEnabled;
        // isStableBorrowRateEnabled = true means users can borrow at a stable rate
        bool isStableBorrowRateEnabled;
        // isActive = true means the reserve has been activated and properly configured
        bool isActive;
        // isFreezed = true means the reserve only allows repays and redeems, but not deposits, new borrowings or rate swap
        bool isFreezed;
    }

    /**
    * @dev returns the ongoing normalized income for the reserve.
    * a value of 1e27 means there is no income. As time passes, the income is accrued.
    * A value of 2*1e27 means that the income of the reserve is double the initial amount.
    * @param _reserve the reserve object
    * @return the normalized income. expressed in ray
    **/
    function getNormalizedIncome(CoreLibrary.ReserveData storage _reserve)
    internal
    view
    returns (uint256)
    {
        uint256 cumulated = calculateLinearInterest(
            _reserve
            .currentLiquidityRate,
            _reserve
            .lastUpdateTimestamp
        )
        .rayMul(_reserve.lastLiquidityCumulativeIndex);

        return cumulated;

    }

    /**
    * @dev function to calculate the interest using a linear interest rate formula
    * @param _rate the interest rate, in ray
    * @param _lastUpdateTimestamp the timestamp of the last update of the interest
    * @return the interest rate linearly accumulated during the timeDelta, in ray
    **/

    function calculateLinearInterest(uint256 _rate, uint40 _lastUpdateTimestamp)
    internal
    view
    returns (uint256)
    {
        //solium-disable-next-line
        uint256 timeDifference = block.timestamp.sub(uint256(_lastUpdateTimestamp));

        uint256 timeDelta = timeDifference.wadToRay().rayDiv(SECONDS_PER_YEAR.wadToRay());

        return _rate.rayMul(timeDelta).add(WadRayMath.ray());
    }

    /**
    * @dev initializes a reserve
    * @param _self the reserve object
    * @param _aTokenAddress the address of the overlying atoken contract
    * @param _decimals the number of decimals of the underlying asset
    * @param _interestRateStrategyAddress the address of the interest rate strategy contract
    **/
    function init(
        ReserveData storage _self,
        address _aTokenAddress,
        uint256 _decimals,
        address _interestRateStrategyAddress
    ) external {
        require(_self.aTokenAddress == address(0), "Reserve has already been initialized");

        if (_self.lastLiquidityCumulativeIndex == 0) {
            //if the reserve has not been initialized yet
            _self.lastLiquidityCumulativeIndex = WadRayMath.ray();
        }

        if (_self.lastVariableBorrowCumulativeIndex == 0) {
            _self.lastVariableBorrowCumulativeIndex = WadRayMath.ray();
        }

        _self.aTokenAddress = _aTokenAddress;
        _self.decimals = _decimals;

        _self.interestRateStrategyAddress = _interestRateStrategyAddress;
        _self.isActive = true;
        _self.isFreezed = false;

    }
}
