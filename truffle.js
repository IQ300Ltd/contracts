module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      // host: "localhost", // Connect to geth on the specified
      host: "144.76.81.182", // Connect to geth on the specified
      port: 9545,
      // port: 8545,
      from: "0x7d1039DD3984FB252D9D95177fDf0DcdB1661aec", // default address to use for any transaction Truffle makes during migrations
      network_id: 4,
      gas: 4612388 // Gas limit used for deploys
    }
  }
};
