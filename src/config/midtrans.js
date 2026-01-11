const midtransClient = require('midtrans-client');
const { MIDTRANS_SERVER_KEY, MIDTRANS_IS_PRODUCTION } = require('./constants');

class MidtransConfig {
  constructor() {
    this.snap = new midtransClient.Snap({
      isProduction: MIDTRANS_IS_PRODUCTION,
      serverKey: MIDTRANS_SERVER_KEY
    });

    this.core = new midtransClient.CoreApi({
      isProduction: MIDTRANS_IS_PRODUCTION,
      serverKey: MIDTRANS_SERVER_KEY
    });
  }

  getSnapInstance() {
    return this.snap;
  }

  getCoreInstance() {
    return this.core;
  }
}

module.exports = new MidtransConfig();