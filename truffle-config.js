module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 68719476635,
      gasLimit: 68719476735,
      gasPrice: 1
    },
    ganache: {
      host: "localhost",
      port: 7545,
      network_id: "5777",
      gasPrice: 1
    },
    clique: {
      host: "localhost",
      port: 8501,
      network_id: "999"
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
