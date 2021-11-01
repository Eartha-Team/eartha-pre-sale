const EarthaToken = artifacts.require('EarthaToken')
const PreSales2 = artifacts.require('PreSales2')

module.exports = async function (deployer, network, accounts) {
  process.env.NETWORK = network

  //1EAR = $0.0075
  const rate = web3.utils.toWei('133.333333333333333333', 'ether')
  //0xcCB112b3d03BD82e555cB91b15322457D8a61862
  const wallet = accounts[0]
  const cap = web3.utils.toWei('10000000', 'ether')
  //1635757200 2021年11月01日	09:00:00
  const openingTime = 1635757200
  //1643673599 2022年01月31日	23:59:59
  const closingTime = 1643673599
  let USDAddress = '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419'
  if (network == 'kovan') {
    USDAddress = '0x9326BFA02ADD2366b30bacB125260Af641031331'
  } else if (network == 'rinkeby') {
    USDAddress = '0x8A753747A1Fa494EC906cE90E9f37563A8AF630e'
  } else if (network == 'bsctestnet') {
    USDAddress = '0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526'
  } else if (network == 'bsc') {
    USDAddress = '0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE'
  }

  return deployer
    .then(() => {
      return deployer.deploy(PreSales2, rate, wallet, EarthaToken.address, cap, openingTime, closingTime, USDAddress)
    })
    .then(async (instance) => {
      ;(await EarthaToken.deployed()).transfer(instance.address, cap)
    })
}
