const EarthaToken = artifacts.require("EarthaToken");
const PreSales = artifacts.require("PreSales");

module.exports = async function (deployer, network, accounts) {
    process.env.NETWORK = network;

    const now = Date.now()+(1000*60)
    const rate = 100;
    const wallet = accounts[0];
    const capDecimals = web3.utils.toBN(18 + 10);
    const goalDecimals = web3.utils.toBN(18 + 7);
    const capDecimalPowed = web3.utils.toBN(10).pow(capDecimals);
    const goalDecimalPowed = web3.utils.toBN(10).pow(goalDecimals);
    const cap = web3.utils.toBN(1).mul(capDecimalPowed);
    const goal = web3.utils.toBN(3).mul(goalDecimalPowed);
    //1621036800 5/15 00:00+UTC0
    const openingTime = Math.floor(now / 1000);
    //1627689600 7/31 00:00+UTC0
    const closingTime = Math.floor(now / 1000) + (60 * 60 * 24);
    //1635638400 10/30 00:00+UTC0
    const tokenUnlockTime = Math.floor(now / 1000) + (60 * 60 * 24) + (60 * 5);
    let USDAddress = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419";
    if (network == "kovan") {
        USDAddress = "0x9326BFA02ADD2366b30bacB125260Af641031331";
    } else if (network == "rinkeby") {
        USDAddress = "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e";
    }

    return deployer.then(() => {
        return deployer.deploy(
            PreSales,
            rate,
            wallet,
            EarthaToken.address,
            cap,
            openingTime,
            closingTime,
            tokenUnlockTime,
            goal,
            USDAddress
        );
    })
}
