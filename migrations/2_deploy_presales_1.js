const EarthaToken = artifacts.require('EarthaToken')
const PreSales = artifacts.require('PreSales')

module.exports = async function (deployer, network, accounts) {
  process.env.NETWORK = network

  //1EAR = $0.007
  const rate = web3.utils.toWei('142.857142857142857142', 'ether')
  //0xcCB112b3d03BD82e555cB91b15322457D8a61862
  const wallet = accounts[0]
  const cap = web3.utils.toWei('14285714', 'ether')
  //1627344000 7/27 00:00+UTC0
  const openingTime = 1627344000
  //1635724799 10/31 23:59:59+UTC0
  const closingTime = 1635724799
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
      return deployer.deploy(PreSales, rate, wallet, EarthaToken.address, cap, openingTime, closingTime, USDAddress)
    })
    .then(async (instance) => {
      ;(await EarthaToken.deployed()).transfer(instance.address, cap)
    })
}
